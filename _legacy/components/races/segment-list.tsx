'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { updateSegmentElevation } from '@/actions/segments'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { ArrowRight } from 'lucide-react'

type Segment = {
  id: string
  distanceKm: string
  elevGainM: number
  elevLossM: number
  fromStationId: string | null
  toStationId: string
  sortOrder: number
}

type Station = {
  id: string
  name: string
}

export function SegmentList({
  raceId,
  segments,
  stations,
}: {
  raceId: string
  segments: Segment[]
  stations: Station[]
}) {
  const router = useRouter()
  const [editingId, setEditingId] = useState<string | null>(null)
  const [gainVal, setGainVal] = useState('')
  const [lossVal, setLossVal] = useState('')
  const [loading, setLoading] = useState(false)

  if (segments.length === 0) return null

  const stationMap = Object.fromEntries(stations.map((s) => [s.id, s.name]))

  const startEdit = (seg: Segment) => {
    setEditingId(seg.id)
    setGainVal(String(seg.elevGainM))
    setLossVal(String(seg.elevLossM))
  }

  const handleSave = async (segmentId: string) => {
    setLoading(true)
    const result = await updateSegmentElevation(
      segmentId,
      raceId,
      parseInt(gainVal) || 0,
      parseInt(lossVal) || 0
    )
    setLoading(false)
    if ('error' in result) return
    setEditingId(null)
    router.refresh()
  }

  return (
    <div className="space-y-4">
      <h2 className="text-lg font-semibold">Segments</h2>
      <div className="space-y-2">
        {segments.map((seg) => {
          const from = seg.fromStationId ? (stationMap[seg.fromStationId] ?? 'Unknown') : 'Start'
          const to = stationMap[seg.toStationId] ?? 'Unknown'
          const isEditing = editingId === seg.id

          return (
            <div key={seg.id} className="rounded-lg border bg-card px-4 py-3">
              <div className="flex items-center justify-between gap-4">
                <div className="flex min-w-0 items-center gap-2 text-sm">
                  <span className="truncate text-muted-foreground">{from}</span>
                  <ArrowRight className="h-3.5 w-3.5 shrink-0 text-muted-foreground" />
                  <span className="truncate font-medium">{to}</span>
                  <span className="ml-2 shrink-0 tabular-nums text-muted-foreground">
                    {parseFloat(seg.distanceKm).toFixed(1)} km
                  </span>
                </div>
                {!isEditing && (
                  <Button
                    variant="ghost"
                    size="sm"
                    className="shrink-0 text-xs"
                    onClick={() => startEdit(seg)}
                  >
                    {seg.elevGainM || seg.elevLossM
                      ? `↑${seg.elevGainM}m ↓${seg.elevLossM}m`
                      : 'Add elevation'}
                  </Button>
                )}
              </div>

              {isEditing && (
                <div className="mt-3 flex items-end gap-3 border-t pt-3">
                  <div className="space-y-1">
                    <label className="text-xs text-muted-foreground">Gain (m)</label>
                    <Input
                      type="number"
                      min="0"
                      value={gainVal}
                      onChange={(e) => setGainVal(e.target.value)}
                      className="w-24"
                    />
                  </div>
                  <div className="space-y-1">
                    <label className="text-xs text-muted-foreground">Loss (m)</label>
                    <Input
                      type="number"
                      min="0"
                      value={lossVal}
                      onChange={(e) => setLossVal(e.target.value)}
                      className="w-24"
                    />
                  </div>
                  <Button size="sm" onClick={() => handleSave(seg.id)} disabled={loading}>
                    Save
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setEditingId(null)}
                    disabled={loading}
                  >
                    Cancel
                  </Button>
                </div>
              )}
            </div>
          )
        })}
      </div>
    </div>
  )
}
