'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { saveOverride, clearOverride } from '@/actions/pacing'
import { formatPace, formatDuration, formatArrivalTime, parsePace } from '@/lib/pacing'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'

type Scenario = 'optimistic' | 'base' | 'pessimistic'

type SegmentRow = {
  id: string
  distanceKm: string
  elevGainM: number
  elevLossM: number
  fromStation: { name: string } | null
  toStation: { name: string }
}

type PlanRow = {
  plannedPaceSecPerKm: number | null
  plannedDurationSec: number | null
  projectedArrivalTime: string | null
  isManualOverride: boolean
}

type Props = {
  raceId: string
  scenario: Scenario
  segments: SegmentRow[]
  planBySegment: Record<string, PlanRow>
}

export function PacingTable({ raceId, scenario, segments, planBySegment }: Props) {
  const router = useRouter()
  const [editingId, setEditingId] = useState<string | null>(null)
  const [editVal, setEditVal] = useState('')
  const [loading, setLoading] = useState(false)
  const [editError, setEditError] = useState<string | null>(null)

  const startEdit = (segId: string, plan: PlanRow | undefined) => {
    setEditingId(segId)
    setEditVal(plan?.plannedPaceSecPerKm ? formatPace(plan.plannedPaceSecPerKm) : '')
    setEditError(null)
  }

  const handleSave = async (segId: string) => {
    const pace = parsePace(editVal)
    if (!pace || pace < 60) { setEditError('Enter a valid pace like 8:30'); return }
    setLoading(true)
    const result = await saveOverride(raceId, segId, scenario, pace)
    setLoading(false)
    if ('error' in result) { setEditError(result.error); return }
    setEditingId(null)
    router.refresh()
  }

  const handleClear = async (segId: string) => {
    setLoading(true)
    await clearOverride(raceId, segId, scenario)
    setLoading(false)
    router.refresh()
  }

  return (
    <div className="overflow-x-auto rounded-lg border">
      <table className="w-full text-sm">
        <thead>
          <tr className="border-b bg-muted/40 text-left text-xs text-muted-foreground">
            <th className="px-3 py-2 font-medium">Segment</th>
            <th className="px-3 py-2 font-medium text-right">Dist</th>
            <th className="px-3 py-2 font-medium text-right">Elev</th>
            <th className="px-3 py-2 font-medium text-right">Pace /km</th>
            <th className="px-3 py-2 font-medium text-right">Time</th>
            <th className="px-3 py-2 font-medium text-right">Arrives</th>
            <th className="w-24 px-3 py-2" />
          </tr>
        </thead>
        <tbody className="divide-y">
          {segments.map((seg) => {
            const plan = planBySegment[seg.id]
            const from = seg.fromStation?.name ?? 'Start'
            const to = seg.toStation.name
            const isEditing = editingId === seg.id

            return (
              <tr key={seg.id} className="hover:bg-muted/20 transition-colors">
                <td className="px-3 py-2.5">
                  <span className="text-muted-foreground">{from}</span>
                  <span className="mx-1 text-muted-foreground">→</span>
                  <span className="font-medium">{to}</span>
                </td>
                <td className="px-3 py-2.5 text-right tabular-nums">
                  {parseFloat(seg.distanceKm).toFixed(1)} km
                </td>
                <td className="px-3 py-2.5 text-right tabular-nums text-muted-foreground text-xs">
                  {seg.elevGainM > 0 && <span>↑{seg.elevGainM}m</span>}
                  {seg.elevLossM > 0 && <span className="ml-1">↓{seg.elevLossM}m</span>}
                  {seg.elevGainM === 0 && seg.elevLossM === 0 && '—'}
                </td>
                <td className="px-3 py-2.5 text-right">
                  {isEditing ? (
                    <div className="flex items-center justify-end gap-1">
                      <Input
                        value={editVal}
                        onChange={(e) => setEditVal(e.target.value)}
                        onKeyDown={(e) => e.key === 'Enter' && handleSave(seg.id)}
                        className="w-20 h-7 text-sm text-right"
                        placeholder="8:30"
                        autoFocus
                      />
                    </div>
                  ) : (
                    <button
                      onClick={() => startEdit(seg.id, plan)}
                      className="tabular-nums hover:text-primary transition-colors"
                    >
                      {plan?.plannedPaceSecPerKm
                        ? formatPace(plan.plannedPaceSecPerKm)
                        : '—'}
                      {plan?.isManualOverride && (
                        <span className="ml-1 text-xs text-amber-600">✎</span>
                      )}
                    </button>
                  )}
                </td>
                <td className="px-3 py-2.5 text-right tabular-nums text-muted-foreground">
                  {plan?.plannedDurationSec ? formatDuration(plan.plannedDurationSec) : '—'}
                </td>
                <td className="px-3 py-2.5 text-right tabular-nums font-medium">
                  {plan?.projectedArrivalTime
                    ? formatArrivalTime(plan.projectedArrivalTime)
                    : '—'}
                </td>
                <td className="px-3 py-2.5">
                  <div className="flex items-center justify-end gap-1">
                    {isEditing ? (
                      <>
                        <Button size="sm" className="h-7 text-xs" onClick={() => handleSave(seg.id)} disabled={loading}>
                          Save
                        </Button>
                        <Button variant="outline" size="sm" className="h-7 text-xs" onClick={() => setEditingId(null)}>
                          ✕
                        </Button>
                      </>
                    ) : plan?.isManualOverride ? (
                      <Button variant="ghost" size="sm" className="h-7 text-xs text-muted-foreground" onClick={() => handleClear(seg.id)} disabled={loading}>
                        Clear
                      </Button>
                    ) : null}
                  </div>
                </td>
              </tr>
            )
          })}
        </tbody>
      </table>
      {editError && (
        <p className="px-3 py-2 text-xs text-red-600 border-t">{editError}</p>
      )}
    </div>
  )
}
