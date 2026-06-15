'use client'

import { useState, useRef, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { CheckCircle, XCircle, FileText, Table } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import { parseGPXToTrack } from '@/lib/gpx-parser'
import { parseStationFile } from '@/lib/excel-parser'
import { saveImportData } from '@/actions/import'
import type { GPXTrackResult, ParsedStation } from '@/lib/gpx-parser'
import type { ExcelParseResult } from '@/lib/excel-parser'

type Status = 'idle' | 'parsing' | 'success' | 'error'

function mergeStations(gpxStations: ParsedStation[], excelStations: ParsedStation[]): ParsedStation[] {
  if (!excelStations.length) return gpxStations
  if (!gpxStations.length) return excelStations
  const merged = [...gpxStations]
  for (const excel of excelStations) {
    let matchIdx = -1
    let minDist = 0.5
    for (let i = 0; i < merged.length; i++) {
      const d = Math.abs(merged[i].distanceKm - excel.distanceKm)
      if (d < minDist) { minDist = d; matchIdx = i }
    }
    if (matchIdx >= 0) {
      merged[matchIdx] = { ...merged[matchIdx], name: excel.name, crewAccess: excel.crewAccess, dropBag: excel.dropBag, services: excel.services, cutoffTime: excel.cutoffTime }
    } else {
      merged.push(excel)
    }
  }
  return merged.sort((a, b) => a.distanceKm - b.distanceKm)
}

type DropZoneProps = {
  label: string
  hint: string
  accept: string
  status: Status
  inputRef: React.RefObject<HTMLInputElement | null>
  onFile: (file: File) => void
  icon: React.ReactNode
  summary: React.ReactNode
  error: string | null
}

function DropZone({ label, hint, accept, status, inputRef, onFile, icon, summary, error }: DropZoneProps) {
  const [isDragging, setIsDragging] = useState(false)

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(false)
    const file = e.dataTransfer.files[0]
    if (file) onFile(file)
  }

  return (
    <div
      className={cn(
        'relative rounded-lg border-2 border-dashed p-5 transition-colors cursor-pointer select-none',
        isDragging && 'border-primary bg-primary/5',
        status === 'idle' && !isDragging && 'border-border hover:border-primary/50',
        status === 'parsing' && 'border-border',
        status === 'success' && 'border-green-400 bg-green-50/50',
        status === 'error' && 'border-red-300 bg-red-50/50',
      )}
      onDragOver={(e) => { e.preventDefault(); setIsDragging(true) }}
      onDragLeave={() => setIsDragging(false)}
      onDrop={handleDrop}
      onClick={() => inputRef.current?.click()}
      role="button"
      tabIndex={0}
      onKeyDown={(e) => e.key === 'Enter' && inputRef.current?.click()}
    >
      <input
        ref={inputRef}
        type="file"
        accept={accept}
        className="hidden"
        onChange={(e) => { const f = e.target.files?.[0]; if (f) onFile(f); e.target.value = '' }}
      />

      <div className="mb-3 flex items-center justify-between">
        <p className="text-sm font-medium">{label}</p>
        <p className="text-xs text-muted-foreground">{hint}</p>
      </div>

      {status === 'idle' && (
        <div className="flex flex-col items-center gap-2 py-5">
          {icon}
          <p className="text-sm text-muted-foreground">Drop here or click to browse</p>
        </div>
      )}

      {status === 'parsing' && (
        <div className="flex flex-col items-center gap-2 py-5">
          <div className="h-7 w-7 animate-spin rounded-full border-2 border-primary border-t-transparent" />
          <p className="text-sm text-muted-foreground">Parsing…</p>
        </div>
      )}

      {status === 'success' && (
        <div className="space-y-2">
          <div className="flex items-center gap-2">
            <CheckCircle className="h-4 w-4 shrink-0 text-green-600" />
            <p className="text-sm font-medium text-green-800">Parsed successfully</p>
          </div>
          {summary}
        </div>
      )}

      {status === 'error' && (
        <div className="space-y-2">
          <div className="flex items-center gap-2">
            <XCircle className="h-4 w-4 shrink-0 text-red-600" />
            <p className="text-sm font-medium text-red-800">Could not parse file</p>
          </div>
          {error && <p className="text-xs text-red-700">{error}</p>}
          <p className="text-xs text-muted-foreground">Click to try a different file</p>
        </div>
      )}
    </div>
  )
}

export function ImportClient({ raceId }: { raceId: string }) {
  const router = useRouter()
  const gpxInputRef = useRef<HTMLInputElement>(null)
  const excelInputRef = useRef<HTMLInputElement>(null)

  const [gpxStatus, setGpxStatus] = useState<Status>('idle')
  const [excelStatus, setExcelStatus] = useState<Status>('idle')
  const [gpxResult, setGpxResult] = useState<GPXTrackResult | null>(null)
  const [excelResult, setExcelResult] = useState<ExcelParseResult | null>(null)
  const [saving, setSaving] = useState(false)
  const [saveError, setSaveError] = useState<string | null>(null)

  const handleGpxFile = useCallback(async (file: File) => {
    if (!file.name.toLowerCase().endsWith('.gpx')) {
      setGpxStatus('error')
      setGpxResult({ points: [], stations: [], totalKm: 0, elevGainM: 0, error: 'Please upload a .gpx file.' })
      return
    }
    setGpxStatus('parsing')
    const text = await file.text()
    const result = parseGPXToTrack(text)
    setGpxResult(result)
    setGpxStatus(result.error && result.points.length === 0 ? 'error' : 'success')
  }, [])

  const handleExcelFile = useCallback(async (file: File) => {
    setExcelStatus('parsing')
    const result = await parseStationFile(file)
    setExcelResult(result)
    setExcelStatus(result.error ? 'error' : 'success')
  }, [])

  const handleContinue = async () => {
    if (!gpxResult || gpxStatus !== 'success') return
    setSaving(true)
    setSaveError(null)

    const excelStations = excelStatus === 'success' && excelResult ? excelResult.stations : []
    const merged = mergeStations(gpxResult.stations, excelStations)
    const source = excelStations.length > 0 ? 'gpx+excel' : 'gpx'

    const res = await saveImportData(raceId, gpxResult.points, merged, source)
    if (res?.error) {
      setSaveError(res.error)
      setSaving(false)
      return
    }
    router.push(`/races/${raceId}/import/builder`)
  }

  const mergedCount =
    gpxStatus === 'success' && excelStatus === 'success' && gpxResult && excelResult
      ? mergeStations(gpxResult.stations, excelResult.stations).length
      : null

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-lg font-semibold">Import Course Data</h2>
        <p className="mt-1 text-sm text-muted-foreground">
          Upload your GPX file to auto-fill distances and elevation. Add an aid station sheet to import station names and details.
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-2">
        <DropZone
          label="GPX File"
          hint="Required · .gpx"
          accept=".gpx"
          status={gpxStatus}
          inputRef={gpxInputRef}
          onFile={handleGpxFile}
          icon={<FileText className="h-8 w-8 text-muted-foreground" />}
          error={gpxResult?.error ?? null}
          summary={
            gpxResult && gpxStatus === 'success' ? (
              <div className="space-y-0.5 text-sm text-green-900">
                <p>
                  <span className="font-medium">{gpxResult.totalKm.toFixed(1)} km</span>
                  {' · '}
                  {gpxResult.elevGainM.toLocaleString()} m gain
                </p>
                <p className="text-xs text-green-700">
                  {gpxResult.stations.length > 0
                    ? `${gpxResult.stations.length} waypoints detected`
                    : 'No waypoints — station names from Excel sheet or manual entry'}
                </p>
              </div>
            ) : null
          }
        />

        <DropZone
          label="Aid Station Sheet"
          hint="Optional · .xlsx .xls .csv"
          accept=".xlsx,.xls,.csv"
          status={excelStatus}
          inputRef={excelInputRef}
          onFile={handleExcelFile}
          icon={<Table className="h-8 w-8 text-muted-foreground" />}
          error={excelResult?.error ?? null}
          summary={
            excelResult && excelStatus === 'success' ? (
              <div className="space-y-1.5 text-sm text-green-900">
                <p>
                  <span className="font-medium">{excelResult.stations.length} stations</span> found
                </p>
                <div className="flex flex-wrap gap-1">
                  {Object.keys(excelResult.columnMap).map((k) => (
                    <span key={k} className="rounded bg-green-100 px-1.5 py-0.5 text-xs text-green-800">
                      {excelResult.columnMap[k]}
                    </span>
                  ))}
                </div>
                {excelResult.unmappedHeaders.length > 0 && (
                  <p className="text-xs text-amber-700">
                    Ignored columns: {excelResult.unmappedHeaders.join(', ')}
                  </p>
                )}
              </div>
            ) : null
          }
        />
      </div>

      {mergedCount !== null && gpxResult && (
        <div className="rounded-lg border bg-muted/30 p-4 text-sm">
          <p className="font-medium">Ready to build</p>
          <p className="mt-0.5 text-muted-foreground">
            {mergedCount} stations · {gpxResult.totalKm.toFixed(1)} km · {gpxResult.elevGainM.toLocaleString()} m elevation gain
          </p>
        </div>
      )}

      {gpxStatus === 'success' && excelStatus === 'idle' && gpxResult && (
        <div className="rounded-lg border bg-muted/30 p-4 text-sm">
          <p className="font-medium">GPX loaded</p>
          <p className="mt-0.5 text-muted-foreground">
            {gpxResult.stations.length > 0
              ? `${gpxResult.stations.length} stations from waypoints · ${gpxResult.totalKm.toFixed(1)} km`
              : `${gpxResult.totalKm.toFixed(1)} km track · add an Excel sheet to name your stations`}
          </p>
        </div>
      )}

      {saveError && <p className="text-sm text-destructive">{saveError}</p>}

      {gpxStatus === 'idle' && (
        <p className="text-sm text-muted-foreground">
          GPX file is required to generate the elevation profile and segment distances.
        </p>
      )}

      <div className="flex items-center justify-between pt-2">
        <Link
          href={`/races/${raceId}/setup`}
          className="text-sm text-muted-foreground underline-offset-4 hover:text-foreground hover:underline"
        >
          Skip — enter manually
        </Link>
        <Button onClick={handleContinue} disabled={gpxStatus !== 'success' || saving}>
          {saving ? 'Saving…' : 'Continue to Segment Builder →'}
        </Button>
      </div>
    </div>
  )
}
