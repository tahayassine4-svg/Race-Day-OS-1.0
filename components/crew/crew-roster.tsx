'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { addCrewMember, updateCrewMember, deleteCrewMember } from '@/actions/crew'
import { CrewMemberForm } from './crew-member-form'
import { Button } from '@/components/ui/button'
import { Pencil, Plus, Trash2, Users } from 'lucide-react'

type Member = { id: string; name: string; phone: string | null }

export function CrewRoster({ raceId, members }: { raceId: string; members: Member[] }) {
  const router = useRouter()
  const [showAdd, setShowAdd] = useState(members.length === 0)
  const [editingId, setEditingId] = useState<string | null>(null)
  const [deletingId, setDeletingId] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const refresh = () => router.refresh()

  const handleAdd = async (data: { name: string; phone: string }) => {
    setLoading(true); setError(null)
    const result = await addCrewMember(raceId, data)
    setLoading(false)
    if ('error' in result) { setError(result.error); return }
    setShowAdd(false); refresh()
  }

  const handleUpdate = async (id: string, data: { name: string; phone: string }) => {
    setLoading(true); setError(null)
    const result = await updateCrewMember(id, raceId, data)
    setLoading(false)
    if ('error' in result) { setError(result.error); return }
    setEditingId(null); refresh()
  }

  const handleDelete = async (id: string) => {
    setLoading(true); setError(null)
    const result = await deleteCrewMember(id, raceId)
    setLoading(false)
    if ('error' in result) { setError(result.error); return }
    setDeletingId(null); refresh()
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="flex items-center gap-2 text-lg font-semibold">
          <Users className="h-5 w-5" />
          Crew Roster
          <span className="text-sm font-normal text-muted-foreground">({members.length})</span>
        </h2>
        {!showAdd && (
          <Button size="sm" onClick={() => setShowAdd(true)}>
            <Plus className="mr-1.5 h-4 w-4" /> Add Member
          </Button>
        )}
      </div>

      {error && (
        <p className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-600">{error}</p>
      )}

      <div className="space-y-2">
        {members.map((m) =>
          editingId === m.id ? (
            <CrewMemberForm
              key={m.id}
              initial={m}
              onSubmit={(data) => handleUpdate(m.id, data)}
              onCancel={() => setEditingId(null)}
              loading={loading}
              submitLabel="Update"
            />
          ) : deletingId === m.id ? (
            <div key={m.id} className="flex items-center justify-between rounded-lg border border-red-200 bg-red-50 p-3">
              <p className="text-sm text-red-700">Delete <strong>{m.name}</strong>? Their assignments will also be removed.</p>
              <div className="ml-4 flex gap-2 shrink-0">
                <Button variant="outline" size="sm" onClick={() => setDeletingId(null)} disabled={loading}>Cancel</Button>
                <Button variant="destructive" size="sm" onClick={() => handleDelete(m.id)} disabled={loading}>
                  {loading ? 'Deleting…' : 'Delete'}
                </Button>
              </div>
            </div>
          ) : (
            <div key={m.id} className="flex items-center justify-between rounded-lg border bg-card px-4 py-3">
              <div>
                <p className="font-medium text-sm">{m.name}</p>
                {m.phone && <p className="text-xs text-muted-foreground">{m.phone}</p>}
              </div>
              <div className="flex gap-1">
                <Button variant="ghost" size="sm" onClick={() => setEditingId(m.id)} disabled={loading}>
                  <Pencil className="h-4 w-4" />
                </Button>
                <Button variant="ghost" size="sm" onClick={() => setDeletingId(m.id)} disabled={loading}>
                  <Trash2 className="h-4 w-4 text-red-500" />
                </Button>
              </div>
            </div>
          )
        )}
      </div>

      {showAdd && (
        <CrewMemberForm
          onSubmit={handleAdd}
          onCancel={() => setShowAdd(false)}
          loading={loading}
          submitLabel="Add member"
        />
      )}

      {!showAdd && members.length > 0 && (
        <Button variant="outline" size="sm" onClick={() => setShowAdd(true)} disabled={loading}>
          <Plus className="mr-1.5 h-4 w-4" /> Add another member
        </Button>
      )}
    </div>
  )
}
