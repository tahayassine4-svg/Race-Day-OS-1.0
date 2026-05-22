'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { logArrival, logDeparture, saveConditionNotes } from '@/actions/station-events'
import { Button } from '@/components/ui/button'
import { formatArrivalTime } from '@/lib/pacing'

type Props = {
  crewToken: string
  stationId: string
  projectedArrival: string | null
  initialArrival: string | null
  initialDeparture: string | null
  initialNotes: string | null
}

export function StationEventForm({
  crewToken,
  stationId,
  projectedArrival,
  initialArrival,
  initialDeparture,
  initialNotes,
}: Props) {
  const router = useRouter()
  const [arrival, setArrival] = useState(initialArrival)
  const [departure, setDeparture] = useState(initialDeparture)
  const [notes, setNotes] = useState(initialNotes ?? '')
  const [loading, setLoading] = useState<'arrival' | 'departure' | 'notes' | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [notesSaved, setNotesSaved] = useState(false)

  const handleArrived = async () => {
    setLoading('arrival'); setError(null)
    const result = await logArrival(crewToken, stationId)
    setLoading(null)
    if ('error' in result) { setError(result.error); return }
    const now = new Date().toISOString()
    setArrival(now)
    router.refresh()
  }

  const handleDeparted = async () => {
    setLoading('departure'); setError(null)
    const result = await logDeparture(crewToken, stationId)
    setLoading(null)
    if ('error' in result) { setError(result.error); return }
    setDeparture(new Date().toISOString())
    router.refresh()
  }

  const handleSaveNotes = async () => {
    setLoading('notes'); setError(null); setNotesSaved(false)
    const result = await saveConditionNotes(crewToken, stationId, notes)
    setLoading(null)
    if ('error' in result) { setError(result.error); return }
    setNotesSaved(true)
    setTimeout(() => setNotesSaved(false), 2000)
  }

  return (
    <div className="space-y-4">
      {error && (
        <p className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-600">{error}</p>
      )}

      <div className="space-y-2">
        {arrival ? (
          <div className="rounded-lg border border-green-200 bg-green-50 px-4 py-3">
            <p className="text-sm font-medium text-green-800">
              ✓ Runner arrived at {formatArrivalTime(arrival)}
            </p>
            {projectedArrival && (
              <p className="text-xs text-green-700 mt-0.5">
                Projected: {formatArrivalTime(projectedArrival)}
              </p>
            )}
          </div>
        ) : (
          <Button
            className="w-full h-12 text-base font-semibold"
            onClick={handleArrived}
            disabled={loading !== null}
          >
            {loading === 'arrival' ? 'Logging…' : '✓ Runner Arrived'}
          </Button>
        )}

        {departure ? (
          <div className="rounded-lg border border-blue-200 bg-blue-50 px-4 py-3">
            <p className="text-sm font-medium text-blue-800">
              ✓ Runner departed at {formatArrivalTime(departure)}
            </p>
          </div>
        ) : arrival ? (
          <Button
            variant="outline"
            className="w-full h-12 text-base"
            onClick={handleDeparted}
            disabled={loading !== null}
          >
            {loading === 'departure' ? 'Logging…' : 'Runner Departed'}
          </Button>
        ) : null}
      </div>

      <div className="space-y-2">
        <label className="text-sm font-medium">Condition notes</label>
        <textarea
          value={notes}
          onChange={(e) => setNotes(e.target.value)}
          placeholder="e.g. Cramping, took extra salt, looking strong…"
          rows={3}
          className="w-full resize-none rounded-md border border-input bg-background px-3 py-2 text-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
        />
        <Button
          variant="outline"
          size="sm"
          className="w-full h-11"
          onClick={handleSaveNotes}
          disabled={loading !== null}
        >
          {loading === 'notes' ? 'Saving…' : notesSaved ? '✓ Saved' : 'Save Notes'}
        </Button>
      </div>
    </div>
  )
}
