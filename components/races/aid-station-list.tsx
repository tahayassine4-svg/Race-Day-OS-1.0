'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createStation, updateStation, deleteStation, type StationData } from '@/actions/aid-stations'
import { AidStationForm } from './aid-station-form'
import { Button } from '@/components/ui/button'
import { MapPin, Pencil, Plus, Trash2 } from 'lucide-react'

type Station = {
  id: string
  name: string
  distanceKm: string
  crewAccess: boolean
  pacerAccess: boolean
  dropBag: boolean
  services: string
  sortOrder: number
}

const SERVICE_LABELS: Record<string, string> = {
  full: 'Full aid',
  water: 'Water only',
  medical: 'Medical',
}

export function AidStationList({
  raceId,
  stations,
}: {
  raceId: string
  stations: Station[]
}) {
  const router = useRouter()
  const [showAdd, setShowAdd] = useState(stations.length === 0)
  const [editingId, setEditingId] = useState<string | null>(null)
  const [deletingId, setDeletingId] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleCreate = async (data: StationData) => {
    setLoading(true)
    setError(null)
    try {
      const result = await createStation(raceId, data)
      if ('error' in result) { setError(result.error); return }
      setShowAdd(false)
      router.refresh()
    } catch {
      setError('Something went wrong')
    } finally {
      setLoading(false)
    }
  }

  const handleUpdate = async (stationId: string, data: StationData) => {
    setLoading(true)
    setError(null)
    try {
      const result = await updateStation(stationId, raceId, data)
      if ('error' in result) { setError(result.error); return }
      setEditingId(null)
      router.refresh()
    } catch {
      setError('Something went wrong')
    } finally {
      setLoading(false)
    }
  }

  const handleDelete = async (stationId: string) => {
    setLoading(true)
    setError(null)
    try {
      const result = await deleteStation(stationId, raceId)
      if ('error' in result) { setError(result.error); return }
      setDeletingId(null)
      router.refresh()
    } catch {
      setError('Something went wrong')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="flex items-center gap-2 text-lg font-semibold">
          <MapPin className="h-5 w-5" />
          Aid Stations
          <span className="text-sm font-normal text-muted-foreground">({stations.length})</span>
        </h2>
        {!showAdd && editingId === null && (
          <Button size="sm" onClick={() => setShowAdd(true)}>
            <Plus className="mr-1.5 h-4 w-4" />
            Add Station
          </Button>
        )}
      </div>

      {error && (
        <p className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-600">
          {error}
        </p>
      )}

      {stations.length === 0 && !showAdd && (
        <div className="rounded-lg border border-dashed p-8 text-center text-sm text-muted-foreground">
          No aid stations yet. Add your first station to get started.
        </div>
      )}

      <div className="space-y-2">
        {stations.map((station) =>
          editingId === station.id ? (
            <AidStationForm
              key={station.id}
              initial={{ ...station, id: station.id }}
              onSubmit={(data) => handleUpdate(station.id, data)}
              onCancel={() => setEditingId(null)}
              loading={loading}
            />
          ) : deletingId === station.id ? (
            <div
              key={station.id}
              className="flex items-center justify-between rounded-lg border border-red-200 bg-red-50 p-4"
            >
              <p className="text-sm text-red-700">
                Delete <strong>{station.name}</strong>? Adjacent segments will be recalculated.
              </p>
              <div className="ml-4 flex shrink-0 gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setDeletingId(null)}
                  disabled={loading}
                >
                  Cancel
                </Button>
                <Button
                  variant="destructive"
                  size="sm"
                  onClick={() => handleDelete(station.id)}
                  disabled={loading}
                >
                  {loading ? 'Deleting...' : 'Delete'}
                </Button>
              </div>
            </div>
          ) : (
            <div
              key={station.id}
              className="flex items-center justify-between gap-4 rounded-lg border bg-card px-4 py-3"
            >
              <div className="flex min-w-0 items-center gap-3">
                <span className="w-16 shrink-0 tabular-nums text-sm text-muted-foreground">
                  {parseFloat(station.distanceKm).toFixed(1)} km
                </span>
                <div className="min-w-0">
                  <p className="truncate text-sm font-medium">{station.name}</p>
                  <div className="mt-0.5 flex flex-wrap items-center gap-1.5">
                    <span className="text-xs text-muted-foreground">
                      {SERVICE_LABELS[station.services] ?? station.services}
                    </span>
                    {station.crewAccess && (
                      <span className="rounded bg-blue-100 px-1.5 py-0.5 text-xs text-blue-700">
                        Crew
                      </span>
                    )}
                    {station.pacerAccess && (
                      <span className="rounded bg-green-100 px-1.5 py-0.5 text-xs text-green-700">
                        Pacer
                      </span>
                    )}
                    {station.dropBag && (
                      <span className="rounded bg-orange-100 px-1.5 py-0.5 text-xs text-orange-700">
                        Drop bag
                      </span>
                    )}
                  </div>
                </div>
              </div>
              <div className="flex shrink-0 items-center gap-1">
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => setEditingId(station.id)}
                  disabled={loading}
                >
                  <Pencil className="h-4 w-4" />
                </Button>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => setDeletingId(station.id)}
                  disabled={loading}
                >
                  <Trash2 className="h-4 w-4 text-red-500" />
                </Button>
              </div>
            </div>
          )
        )}
      </div>

      {showAdd && (
        <AidStationForm
          onSubmit={handleCreate}
          onCancel={() => setShowAdd(false)}
          loading={loading}
        />
      )}

      {!showAdd && stations.length > 0 && editingId === null && (
        <Button variant="outline" size="sm" onClick={() => setShowAdd(true)} disabled={loading}>
          <Plus className="mr-1.5 h-4 w-4" />
          Add another station
        </Button>
      )}
    </div>
  )
}
