'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '@/lib/supabase-client'

type ConnectionStatus = 'connected' | 'reconnecting' | 'error'

/**
 * Subscribes to station_events Realtime changes for a given race.
 * On any INSERT/UPDATE, calls router.refresh() so the server component
 * re-runs and pulls the latest projections. Shows a banner when disconnected.
 */
export function RealtimeProvider({
  raceId,
  children,
}: {
  raceId: string
  children: React.ReactNode
}) {
  const router = useRouter()
  const [status, setStatus] = useState<ConnectionStatus>('reconnecting')

  useEffect(() => {
    const channel = supabase
      .channel(`station-events-${raceId}`)
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'station_events',
          filter: `race_id=eq.${raceId}`,
        },
        () => {
          router.refresh()
        }
      )
      .subscribe((s) => {
        if (s === 'SUBSCRIBED') setStatus('connected')
        else if (s === 'CHANNEL_ERROR' || s === 'TIMED_OUT') setStatus('error')
        else setStatus('reconnecting')
      })

    return () => {
      supabase.removeChannel(channel)
    }
  }, [raceId, router])

  return (
    <>
      {status !== 'connected' && (
        <div className="mb-4 rounded-md border border-yellow-200 bg-yellow-50 px-3 py-2 text-sm text-yellow-800">
          {status === 'reconnecting' ? '⟳ Connecting to live updates…' : '⚠ Live update connection lost'}
        </div>
      )}
      {children}
    </>
  )
}
