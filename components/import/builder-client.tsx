'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { ElevationChart } from './elevation-chart'
import { SegmentBuilderTable } from './segment-builder-table'
import { confirmImport } from '@/actions/import'
import type { TrackPoint, ParsedStation } from '@/lib/gpx-parser'
import type { DraftStation } from '@/lib/types/import'

function initDraftStations(imported: ParsedStation[], totalKm: number): DraftStation[] {
  const drafts: DraftStation[] = []

  const hasNearStart = imported.some(s => s.distanceKm < 0.5)
  if (!hasNearStart) {
    drafts.push({ id: crypto.randomUUID(), name: 'Start', distanceKm: 0, crewAccess: false, dropBag: false, services: 'full', cutoffTime: '', isStart: true, isFinish: false })
  }

  for (const s of imported) {
    drafts.push({
      id: crypto.randomUUID(),
      name: s.name,
      distanceKm: parseFloat(s.distanceKm.toFixed(1)),
      crewAccess: s.crewAccess,
      dropBag: s.dropBag,
      services: (s.services ?? 'full') as DraftStation['services'],
      cutoffTime: s.cutoffTime ?? '',
      isStart: false,
      isFinish: false,
    })
  }

  drafts.sort((a, b) => a.distanceKm - b.distanceKm)
  if (drafts.length > 0) drafts[0].isStart = true

  const roundedTotal = parseFloat(totalKm.toFixed(1))
  const hasNearFinish = drafts.some(s => Math.abs(s.distanceKm - roundedTotal) < 0.5)
  if (!hasNearFinish) {
    drafts.push({ id: crypto.randomUUID(), name: 'Finish', distanceKm: roundedTotal, crewAccess: false, dropBag: false, services: 'full', cutoffTime: '', isStart: false, isFinish: true })
  } else {
    drafts[drafts.length - 1].isFinish = true
  }

  return drafts
}

function validateDrafts(stations: DraftStation[]): Record<string, string> {
  const errors: Record<string, string> = {}
  const sorted = [...stations].sort((a, b) => a.distanceKm - b.distanceKm)
  for (let i = 0; i < sorted.length; i++) {
    const s = sorted[i]
    if (!s.name.trim()) { errors[s.id] = 'Name required'; continue }
    if (i > 0) {
      const prev = sorted[i - 1]
      if (s.distanceKm <= prev.distanceKm) {
        errors[s.id] = `Must be after ${prev.name} (${prev.distanceKm.toFixed(1)} km)`
      } else if (s.distanceKm - prev.distanceKm < 0.1) {
        errors[s.id] = `Must be at least 0.1 km after ${prev.name}`
      }
    }
  }
  return errors
}

type Props = {
  raceId: string
  trackPoints: TrackPoint[]
  importedStations: ParsedStation[]
}

export function BuilderClient({ raceId, trackPoints, importedStations }: Props) {
  const router = useRouter()
  const totalKm = trackPoints.length > 0 ? trackPoints[trackPoints.length - 1].cumKm : 0

  const [stations, setStations] = useState<DraftStation[]>(() =>
    initDraftStations(importedStations, totalKm)
  )
  const [selectedId, setSelectedId] = useState<string | null>(null)
  const [validationErrors, setValidationErrors] = useState<Record<string, string>>({})
  const [confirming, setConfirming] = useState(false)
  const [confirmError, setConfirmError] = useState<string | null>(null)

  const handleStationClick = (index: number) => {
    const sorted = [...stations].sort((a, b) => a.distanceKm - b.distanceKm)
    setSelectedId(sorted[index]?.id ?? null)
  }

  const handleChange = (id: string, field: keyof DraftStation, value: unknown) => {
    setStations(prev => prev.map(s => s.id === id ? { ...s, [field]: value } : s))
    if (validationErrors[id]) {
      setValidationErrors(prev => { const n = { ...prev }; delete n[id]; return n })
    }
  }

  const handleRemove = (id: string) => {
    setStations(prev => prev.filter(s => s.id !== id))
    if (selectedId === id) setSelectedId(null)
  }

  const handleAdd = () => {
    const sorted = [...stations].sort((a, b) => a.distanceKm - b.distanceKm)
    if (sorted.length < 2) return
    const last = sorted[sorted.length - 1]
    const secondLast = sorted[sorted.length - 2]
    const midKm = parseFloat(((secondLast.distanceKm + last.distanceKm) / 2).toFixed(1))
    const newStation: DraftStation = {
      id: crypto.randomUUID(),
      name: '',
      distanceKm: midKm,
      crewAccess: false,
      dropBag: false,
      services: 'full',
      cutoffTime: '',
      isStart: false,
      isFinish: false,
    }
    setStations(prev => [...prev, newStation].sort((a, b) => a.distanceKm - b.distanceKm))
    setSelectedId(newStation.id)
  }

  const handleConfirm = async () => {
    const errors = validateDrafts(stations)
    setValidationErrors(errors)
    if (Object.keys(errors).length > 0) return

    setConfirming(true)
    setConfirmError(null)

    const sorted = [...stations].sort((a, b) => a.distanceKm - b.distanceKm)
    const result = await confirmImport(raceId, sorted.map(s => ({
      name: s.name,
      distanceKm: s.distanceKm,
      crewAccess: s.crewAccess,
      dropBag: s.dropBag,
      services: s.services,
      cutoffTime: s.cutoffTime,
    })))

    if (result?.error) {
      setConfirmError(result.error)
      setConfirming(false)
      return
    }

    router.push(`/races/${raceId}/pacing`)
  }

  const sortedStations = [...stations].sort((a, b) => a.distanceKm - b.distanceKm)
  const hasErrors = Object.keys(validationErrors).length > 0

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <Link
          href={`/races/${raceId}/import`}
          className="flex items-center gap-1.5 text-sm text-muted-foreground underline-offset-4 hover:text-foreground hover:underline"
        >
          <ArrowLeft className="h-3.5 w-3.5" />
          Back to Import
        </Link>
        <p className="text-sm text-muted-foreground">
          {sortedStations.length} stations · {totalKm.toFixed(1)} km
        </p>
      </div>

      <div>
        <h2 className="text-lg font-semibold">Segment Builder</h2>
        <p className="mt-1 text-sm text-muted-foreground">
          Review station positions on the elevation profile. Edit names, distances, and details in the table below, then confirm to build your course.
        </p>
      </div>

      <ElevationChart
        trackPoints={trackPoints}
        stations={sortedStations}
        selectedId={selectedId}
        onStationClick={handleStationClick}
      />

      <SegmentBuilderTable
        stations={stations}
        trackPoints={trackPoints}
        selectedId={selectedId}
        validationErrors={validationErrors}
        onSelect={setSelectedId}
        onChange={handleChange}
        onRemove={handleRemove}
        onAdd={handleAdd}
      />

      {confirmError && (
        <p className="text-sm text-destructive">{confirmError}</p>
      )}

      {hasErrors && (
        <p className="text-sm text-destructive">
          Fix the errors above before confirming.
        </p>
      )}

      <div className="flex justify-end pt-2">
        <Button onClick={handleConfirm} disabled={confirming} size="lg">
          {confirming ? 'Saving…' : 'Confirm & Apply →'}
        </Button>
      </div>
    </div>
  )
}
