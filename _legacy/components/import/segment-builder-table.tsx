'use client'

import { Plus, Trash2 } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { cn } from '@/lib/utils'
import type { DraftStation } from '@/lib/types/import'
import type { TrackPoint } from '@/lib/gpx-parser'

type Props = {
  stations: DraftStation[]
  trackPoints: TrackPoint[]
  selectedId: string | null
  validationErrors: Record<string, string>
  onSelect: (id: string) => void
  onChange: (id: string, field: keyof DraftStation, value: unknown) => void
  onRemove: (id: string) => void
  onAdd: () => void
}

function computeSegmentElev(track: TrackPoint[], fromKm: number, toKm: number) {
  const pts = track.filter(p => p.cumKm >= fromKm && p.cumKm <= toKm)
  let gainM = 0, lossM = 0
  for (let i = 1; i < pts.length; i++) {
    const diff = pts[i].ele - pts[i - 1].ele
    if (diff > 0) gainM += diff
    else lossM += Math.abs(diff)
  }
  return { gainM: Math.round(gainM), lossM: Math.round(lossM) }
}

const SERVICES = [
  { value: 'full',    label: 'Full' },
  { value: 'water',   label: 'Water' },
  { value: 'medical', label: 'Medical' },
]

export function SegmentBuilderTable({
  stations,
  trackPoints,
  selectedId,
  validationErrors,
  onSelect,
  onChange,
  onRemove,
  onAdd,
}: Props) {
  const sorted = [...stations].sort((a, b) => a.distanceKm - b.distanceKm)

  return (
    <div className="space-y-3">
      <div className="overflow-x-auto rounded-lg border">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b bg-muted/40 text-xs text-muted-foreground">
              <th className="px-3 py-2 text-left font-medium">#</th>
              <th className="px-3 py-2 text-left font-medium">Name</th>
              <th className="px-3 py-2 text-left font-medium">Dist (km)</th>
              <th className="px-3 py-2 text-center font-medium">Crew</th>
              <th className="px-3 py-2 text-center font-medium">Drop bag</th>
              <th className="px-3 py-2 text-left font-medium">Services</th>
              <th className="px-3 py-2 text-left font-medium">Cutoff</th>
              <th className="px-3 py-2 text-right font-medium">↑ Gain</th>
              <th className="px-3 py-2 text-right font-medium">↓ Loss</th>
              <th className="px-3 py-2" />
            </tr>
          </thead>
          <tbody>
            {sorted.map((s, rowIdx) => {
              const prev = sorted[rowIdx - 1]
              const { gainM, lossM } = prev
                ? computeSegmentElev(trackPoints, prev.distanceKm, s.distanceKm)
                : { gainM: 0, lossM: 0 }
              const isLocked = s.isStart || s.isFinish
              const hasError = !!validationErrors[s.id]

              return (
                <tr
                  key={s.id}
                  onClick={() => onSelect(s.id)}
                  className={cn(
                    'border-b transition-colors last:border-0',
                    s.id === selectedId ? 'bg-primary/8 ring-inset ring-1 ring-primary/20' : 'hover:bg-muted/30',
                    hasError && 'bg-red-50/50',
                  )}
                >
                  <td className="px-3 py-2 text-muted-foreground">
                    {rowIdx + 1}
                  </td>

                  <td className="px-3 py-2">
                    <div className="space-y-0.5">
                      <Input
                        value={s.name}
                        onChange={e => onChange(s.id, 'name', e.target.value)}
                        onClick={e => e.stopPropagation()}
                        placeholder={s.isStart ? 'Start' : s.isFinish ? 'Finish' : 'Station name'}
                        className={cn('h-7 min-w-[120px] text-xs', hasError && 'border-red-400')}
                      />
                      {hasError && <p className="text-xs text-red-600">{validationErrors[s.id]}</p>}
                    </div>
                  </td>

                  <td className="px-3 py-2">
                    <Input
                      type="number"
                      min={0}
                      step={0.1}
                      value={s.distanceKm}
                      disabled={isLocked}
                      onChange={e => onChange(s.id, 'distanceKm', parseFloat(e.target.value) || 0)}
                      onClick={e => e.stopPropagation()}
                      className="h-7 w-20 text-xs disabled:opacity-60"
                    />
                  </td>

                  <td className="px-3 py-2 text-center">
                    <input
                      type="checkbox"
                      checked={s.crewAccess}
                      onChange={e => onChange(s.id, 'crewAccess', e.target.checked)}
                      onClick={e => e.stopPropagation()}
                      className="cursor-pointer"
                    />
                  </td>

                  <td className="px-3 py-2 text-center">
                    <input
                      type="checkbox"
                      checked={s.dropBag}
                      onChange={e => onChange(s.id, 'dropBag', e.target.checked)}
                      onClick={e => e.stopPropagation()}
                      className="cursor-pointer"
                    />
                  </td>

                  <td className="px-3 py-2">
                    <select
                      value={s.services}
                      onChange={e => onChange(s.id, 'services', e.target.value)}
                      onClick={e => e.stopPropagation()}
                      className="h-7 rounded-md border border-input bg-background px-2 text-xs focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
                    >
                      {SERVICES.map(o => (
                        <option key={o.value} value={o.value}>{o.label}</option>
                      ))}
                    </select>
                  </td>

                  <td className="px-3 py-2">
                    <Input
                      placeholder="HH:MM"
                      value={s.cutoffTime}
                      onChange={e => onChange(s.id, 'cutoffTime', e.target.value)}
                      onClick={e => e.stopPropagation()}
                      className="h-7 w-20 text-xs"
                      pattern="\d{1,2}:\d{2}"
                    />
                  </td>

                  <td className="px-3 py-2 text-right text-muted-foreground">
                    {rowIdx > 0 ? <span className="text-green-700">{gainM > 0 ? `+${gainM}` : '–'}</span> : '–'}
                  </td>

                  <td className="px-3 py-2 text-right text-muted-foreground">
                    {rowIdx > 0 ? <span className="text-red-600">{lossM > 0 ? `-${lossM}` : '–'}</span> : '–'}
                  </td>

                  <td className="px-3 py-2">
                    {!isLocked && (
                      <Button
                        variant="ghost"
                        size="icon"
                        className="h-6 w-6 text-muted-foreground hover:text-destructive"
                        onClick={e => { e.stopPropagation(); onRemove(s.id) }}
                        title="Remove station"
                      >
                        <Trash2 className="h-3.5 w-3.5" />
                      </Button>
                    )}
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>

      <Button variant="outline" size="sm" onClick={onAdd} className="gap-1.5">
        <Plus className="h-3.5 w-3.5" />
        Add station
      </Button>
    </div>
  )
}
