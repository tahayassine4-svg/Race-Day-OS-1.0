'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { logArrival } from '@/actions/station-events'
import { Button } from '@/components/ui/button'
import { formatArrivalTime } from '@/lib/pacing'
import Link from 'next/link'

type Event = {
  actualArrival: string | null
  projectedArrival: string | null
}

type Station = {
  id: string
  name: string
  distanceKm: string
  crewAccess: boolean
}

function getStatus(projected: string, actual: string): 'ahead' | 'on-pace' | 'behind' {
  const diff = (new Date(actual).getTime() - new Date(projected).getTime()) / 60000
  if (diff < -5) return 'ahead'
  if (diff > 5) return 'behind'
  return 'on-pace'
}

const STATUS_STYLES = {
  ahead: 'bg-green-100 text-green-800',
  'on-pace': 'bg-yellow-100 text-yellow-800',
  behind: 'bg-red-100 text-red-800',
}
const STATUS_LABELS = { ahead: 'Ahead', 'on-pace': 'On Pace', behind: 'Behind' }

export function CrewStationCard({
  station,
  event,
  crewToken,
  isYourStation = false,
}: {
  station: Station
  event: Event
  crewToken: string
  isYourStation?: boolean
}) {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [arrivedAt, setArrivedAt] = useState(event.actualArrival)

  const handleArrived = async () => {
    setLoading(true)
    const result = await logArrival(crewToken, station.id)
    setLoading(false)
    if ('ok' in result) {
      setArrivedAt(new Date().toISOString())
      router.refresh()
    }
  }

  const status =
    arrivedAt && event.projectedArrival
      ? getStatus(event.projectedArrival, arrivedAt)
      : null

  return (
    <div
      className={`rounded-xl border p-4 space-y-2 ${
        isYourStation ? 'border-primary bg-primary/5' : 'bg-card'
      }`}
    >
      <div className="flex items-start justify-between gap-2">
        <div>
          <p className="font-semibold">{station.name}</p>
          <p className="text-xs text-muted-foreground">
            {parseFloat(station.distanceKm).toFixed(1)} km
            {station.crewAccess && (
              <span className="ml-1.5 rounded bg-blue-100 px-1.5 py-0.5 text-xs text-blue-700">
                Crew
              </span>
            )}
          </p>
        </div>
        <div className="text-right shrink-0">
          {event.projectedArrival && (
            <p className="text-sm font-medium">{formatArrivalTime(event.projectedArrival)}</p>
          )}
          {arrivedAt && status && (
            <span className={`rounded-full px-2 py-0.5 text-xs font-medium ${STATUS_STYLES[status]}`}>
              {STATUS_LABELS[status]}
            </span>
          )}
        </div>
      </div>

      {arrivedAt ? (
        <p className="text-xs text-green-700 font-medium">
          ✓ Arrived {formatArrivalTime(arrivedAt)}
        </p>
      ) : station.crewAccess ? (
        <Button
          size="sm"
          className="w-full h-11 text-sm"
          onClick={handleArrived}
          disabled={loading}
        >
          {loading ? 'Logging…' : 'Runner Arrived'}
        </Button>
      ) : null}

      <Link
        href={`/crew/${crewToken}/station/${station.id}`}
        className="block text-center text-xs text-muted-foreground underline-offset-2 hover:underline"
      >
        View station card →
      </Link>
    </div>
  )
}
