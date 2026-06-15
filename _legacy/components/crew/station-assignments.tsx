'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { saveAssignment, removeAssignment } from '@/actions/crew'
import { Button } from '@/components/ui/button'
import { MapPin, X } from 'lucide-react'

const ROLES = ['Driver', 'Main Handler', 'Pacer', 'Photographer', 'Support']

type Station = { id: string; name: string; distanceKm: string }
type Member = { id: string; name: string }
type Assignment = { id: string; stationId: string; memberId: string; memberName: string; role: string | null }

type Props = {
  raceId: string
  crewStations: Station[]
  members: Member[]
  assignments: Assignment[]
}

export function StationAssignments({ raceId, crewStations, members, assignments }: Props) {
  const router = useRouter()
  const [addingStationId, setAddingStationId] = useState<string | null>(null)
  const [selectedMember, setSelectedMember] = useState('')
  const [selectedRole, setSelectedRole] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const byStation = crewStations.reduce<Record<string, Assignment[]>>((acc, s) => {
    acc[s.id] = assignments.filter((a) => a.stationId === s.id)
    return acc
  }, {})

  const handleAdd = async (stationId: string) => {
    if (!selectedMember) { setError('Select a crew member'); return }
    setLoading(true); setError(null)
    const result = await saveAssignment(raceId, stationId, selectedMember, selectedRole || null)
    setLoading(false)
    if ('error' in result) { setError(result.error); return }
    setAddingStationId(null); setSelectedMember(''); setSelectedRole('')
    router.refresh()
  }

  const handleRemove = async (assignmentId: string) => {
    setLoading(true)
    await removeAssignment(assignmentId, raceId)
    setLoading(false)
    router.refresh()
  }

  if (crewStations.length === 0) {
    return (
      <div className="rounded-lg border border-dashed p-6 text-center text-sm text-muted-foreground">
        No crew-accessible stations. Mark stations as crew-accessible in the Setup tab.
      </div>
    )
  }

  if (members.length === 0) {
    return (
      <div className="rounded-lg border border-dashed p-6 text-center text-sm text-muted-foreground">
        Add crew members above before assigning them to stations.
      </div>
    )
  }

  return (
    <div className="space-y-3">
      <h2 className="flex items-center gap-2 text-lg font-semibold">
        <MapPin className="h-5 w-5" /> Station Assignments
      </h2>
      {error && <p className="text-sm text-red-600 rounded-md bg-red-50 border border-red-200 px-3 py-2">{error}</p>}
      <div className="space-y-3">
        {crewStations.map((station) => {
          const stationAssignments = byStation[station.id] ?? []
          const assignedIds = new Set(stationAssignments.map((a) => a.memberId))
          const available = members.filter((m) => !assignedIds.has(m.id))
          const isAdding = addingStationId === station.id

          return (
            <div key={station.id} className="rounded-lg border bg-card p-3">
              <div className="flex items-center justify-between mb-2">
                <div>
                  <span className="font-medium text-sm">{station.name}</span>
                  <span className="ml-2 text-xs text-muted-foreground">{parseFloat(station.distanceKm).toFixed(1)} km</span>
                </div>
                {!isAdding && available.length > 0 && (
                  <Button variant="outline" size="sm" className="h-7 text-xs" onClick={() => { setAddingStationId(station.id); setError(null) }}>
                    + Assign
                  </Button>
                )}
              </div>
              <div className="flex flex-wrap gap-1.5">
                {stationAssignments.map((a) => (
                  <span key={a.id} className="inline-flex items-center gap-1 rounded-full bg-purple-100 px-2.5 py-1 text-xs text-purple-800">
                    {a.memberName}{a.role ? ` · ${a.role}` : ''}
                    <button onClick={() => handleRemove(a.id)} disabled={loading} className="hover:text-red-600">
                      <X className="h-3 w-3" />
                    </button>
                  </span>
                ))}
                {stationAssignments.length === 0 && !isAdding && (
                  <span className="text-xs text-muted-foreground">No crew assigned</span>
                )}
              </div>
              {isAdding && (
                <div className="mt-2 flex flex-wrap items-end gap-2">
                  <select
                    value={selectedMember}
                    onChange={(e) => setSelectedMember(e.target.value)}
                    className="h-8 rounded-md border border-input bg-background px-2 text-sm"
                  >
                    <option value="">Select member…</option>
                    {available.map((m) => <option key={m.id} value={m.id}>{m.name}</option>)}
                  </select>
                  <select
                    value={selectedRole}
                    onChange={(e) => setSelectedRole(e.target.value)}
                    className="h-8 rounded-md border border-input bg-background px-2 text-sm"
                  >
                    <option value="">Role (optional)</option>
                    {ROLES.map((r) => <option key={r} value={r}>{r}</option>)}
                  </select>
                  <Button size="sm" className="h-8" onClick={() => handleAdd(station.id)} disabled={loading}>Add</Button>
                  <Button variant="outline" size="sm" className="h-8" onClick={() => { setAddingStationId(null); setError(null) }}>Cancel</Button>
                </div>
              )}
            </div>
          )
        })}
      </div>
    </div>
  )
}
