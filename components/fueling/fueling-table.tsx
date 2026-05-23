'use client'

import React, { useState } from 'react'
import { useRouter } from 'next/navigation'
import { saveSegmentOverride, clearSegmentOverride, saveStationNotes } from '@/actions/fueling'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { formatDuration } from '@/lib/pacing'

export type FuelRow = {
  segmentId: string
  fromName: string
  toName: string
  durationSec: number
  calPerH: number
  fluidPerH: number
  sodiumPerH: number
  calories: number
  fluid: number
  sodium: number
  cumulativeCal: number
  cumulativeFluid: number
  itemNotes: string | null
  isManualOverride: boolean
}

type EditState = { cal: string; fluid: string; sodium: string }

export function FuelingTable({ raceId, rows }: { raceId: string; rows: FuelRow[] }) {
  const router = useRouter()
  const [editingId, setEditingId] = useState<string | null>(null)
  const [editVals, setEditVals] = useState<EditState>({ cal: '', fluid: '', sodium: '' })
  const [loading, setLoading] = useState(false)

  const startEdit = (row: FuelRow) => {
    setEditingId(row.segmentId)
    setEditVals({
      cal: String(row.calPerH),
      fluid: String(row.fluidPerH),
      sodium: String(row.sodiumPerH),
    })
  }

  const handleSaveOverride = async (segmentId: string) => {
    const cal = parseInt(editVals.cal) || 0
    const fluid = parseInt(editVals.fluid) || 0
    const sodium = parseInt(editVals.sodium) || 0
    setLoading(true)
    const result = await saveSegmentOverride(raceId, segmentId, cal, fluid, sodium)
    setLoading(false)
    if ('error' in result) return
    setEditingId(null)
    router.refresh()
  }

  const handleClearOverride = async (segmentId: string) => {
    setLoading(true)
    await clearSegmentOverride(raceId, segmentId)
    setLoading(false)
    router.refresh()
  }

  const handleNoteBlur = async (segmentId: string, notes: string) => {
    await saveStationNotes(raceId, segmentId, notes)
  }

  if (rows.length === 0) return null

  return (
    <div className="space-y-2">
      <div className="overflow-x-auto rounded-lg border">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b bg-muted/40 text-left text-xs text-muted-foreground">
              <th className="px-3 py-2 font-medium">Segment</th>
              <th className="px-3 py-2 font-medium text-right">Time</th>
              <th className="px-3 py-2 font-medium text-right">Cal</th>
              <th className="px-3 py-2 font-medium text-right">Fluid</th>
              <th className="px-3 py-2 font-medium text-right">Sodium</th>
              <th className="px-3 py-2 font-medium text-right">∑Cal</th>
              <th className="px-3 py-2 font-medium text-right">∑Fluid</th>
              <th className="w-28 px-3 py-2" />
            </tr>
          </thead>
          <tbody className="divide-y">
            {rows.map((row) => {
              const isEditing = editingId === row.segmentId
              return (
                <React.Fragment key={row.segmentId}>
                  <tr className="hover:bg-muted/20 transition-colors">
                    <td className="px-3 py-2.5">
                      <span className="text-muted-foreground text-xs">{row.fromName}</span>
                      <span className="mx-1 text-muted-foreground">→</span>
                      <span className="font-medium">{row.toName}</span>
                    </td>
                    <td className="px-3 py-2.5 text-right tabular-nums text-muted-foreground">
                      {formatDuration(row.durationSec)}
                    </td>
                    <td className="px-3 py-2.5 text-right tabular-nums font-medium">
                      {row.calories}
                      {row.isManualOverride && (
                        <span className="ml-1 text-xs text-amber-500">✎</span>
                      )}
                    </td>
                    <td className="px-3 py-2.5 text-right tabular-nums">
                      {row.fluid >= 1000
                        ? `${(row.fluid / 1000).toFixed(1)}L`
                        : `${row.fluid}ml`}
                    </td>
                    <td className="px-3 py-2.5 text-right tabular-nums text-muted-foreground">
                      {row.sodium}mg
                    </td>
                    <td className="px-3 py-2.5 text-right tabular-nums text-muted-foreground">
                      {row.cumulativeCal.toLocaleString()}
                    </td>
                    <td className="px-3 py-2.5 text-right tabular-nums text-muted-foreground">
                      {row.cumulativeFluid >= 1000
                        ? `${(row.cumulativeFluid / 1000).toFixed(1)}L`
                        : `${row.cumulativeFluid}ml`}
                    </td>
                    <td className="px-3 py-2.5">
                      <div className="flex items-center justify-end gap-1">
                        {isEditing ? (
                          <>
                            <Button size="sm" className="h-7 text-xs" onClick={() => handleSaveOverride(row.segmentId)} disabled={loading}>Save</Button>
                            <Button variant="outline" size="sm" className="h-7 text-xs" onClick={() => setEditingId(null)}>✕</Button>
                          </>
                        ) : row.isManualOverride ? (
                          <>
                            <Button variant="ghost" size="sm" className="h-7 text-xs" onClick={() => startEdit(row)}>Edit</Button>
                            <Button variant="ghost" size="sm" className="h-7 text-xs text-muted-foreground" onClick={() => handleClearOverride(row.segmentId)} disabled={loading}>Clear</Button>
                          </>
                        ) : (
                          <Button variant="ghost" size="sm" className="h-7 text-xs" onClick={() => startEdit(row)}>Override</Button>
                        )}
                      </div>
                    </td>
                  </tr>
                  {isEditing && (
                    <tr key={`${row.segmentId}-edit`} className="bg-muted/10">
                      <td colSpan={8} className="px-3 pb-3">
                        <div className="flex items-end gap-3 pt-2">
                          <div className="space-y-1">
                            <label className="text-xs text-muted-foreground">Cal/h</label>
                            <Input value={editVals.cal} onChange={(e) => setEditVals(v => ({ ...v, cal: e.target.value }))} className="w-20 h-7" type="number" min="0" />
                          </div>
                          <div className="space-y-1">
                            <label className="text-xs text-muted-foreground">Fluid ml/h</label>
                            <Input value={editVals.fluid} onChange={(e) => setEditVals(v => ({ ...v, fluid: e.target.value }))} className="w-24 h-7" type="number" min="0" />
                          </div>
                          <div className="space-y-1">
                            <label className="text-xs text-muted-foreground">Sodium mg/h</label>
                            <Input value={editVals.sodium} onChange={(e) => setEditVals(v => ({ ...v, sodium: e.target.value }))} className="w-24 h-7" type="number" min="0" />
                          </div>
                        </div>
                      </td>
                    </tr>
                  )}
                  <tr key={`${row.segmentId}-notes`} className="border-b-0">
                    <td colSpan={8} className="px-3 pb-2">
                      <input
                        defaultValue={row.itemNotes ?? ''}
                        onBlur={(e) => handleNoteBlur(row.segmentId, e.target.value)}
                        placeholder={`Notes for ${row.toName}…`}
                        className="w-full text-xs text-muted-foreground bg-transparent outline-none placeholder:text-muted-foreground/40 border-b border-transparent focus:border-border transition-colors py-0.5"
                      />
                    </td>
                  </tr>
                </React.Fragment>
              )
            })}
          </tbody>
        </table>
      </div>
    </div>
  )
}
