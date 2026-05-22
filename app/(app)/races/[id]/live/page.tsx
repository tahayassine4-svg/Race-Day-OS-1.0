import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { aidStations, pacePlans, races, segments, stationEvents } from '@/lib/db/schema'
import { and, asc, eq } from 'drizzle-orm'
import { notFound } from 'next/navigation'
import { recomputeProjections, getArrivalStatus, STATUS_STYLES, STATUS_LABELS } from '@/lib/live-projections'
import { formatArrivalTime, formatDuration } from '@/lib/pacing'
import { RealtimeProvider } from '@/components/realtime-provider'
import { Radio } from 'lucide-react'

export default async function LivePage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id: raceId } = await params
  const session = await auth()

  const race = await db.query.races.findFirst({
    where: and(eq(races.id, raceId), eq(races.userId, session!.user.id)),
    columns: { id: true, name: true, startTime: true, activeScenario: true },
  })
  if (!race) notFound()

  const [stationRows, segmentRows, pacingRows, eventRows] = await Promise.all([
    db.select().from(aidStations).where(eq(aidStations.raceId, raceId)).orderBy(asc(aidStations.distanceKm)),
    db.select({ id: segments.id, toStationId: segments.toStationId, distanceKm: segments.distanceKm, sortOrder: segments.sortOrder })
      .from(segments).where(eq(segments.raceId, raceId)).orderBy(asc(segments.sortOrder)),
    db.select({ segmentId: pacePlans.segmentId, plannedPaceSecPerKm: pacePlans.plannedPaceSecPerKm, projectedArrivalTime: pacePlans.projectedArrivalTime })
      .from(pacePlans).where(and(eq(pacePlans.raceId, raceId), eq(pacePlans.scenario, race.activeScenario))),
    db.select().from(stationEvents).where(eq(stationEvents.raceId, raceId)),
  ])

  const pacingBySegment = Object.fromEntries(
    pacingRows.map((p) => [p.segmentId, { pace: p.plannedPaceSecPerKm ?? 0, originalArrival: p.projectedArrivalTime?.toISOString() ?? null }])
  )

  const projSegs = segmentRows.map((s) => ({
    id: s.id,
    toStationId: s.toStationId ?? '',
    distanceKm: Number(s.distanceKm),
    plannedPaceSecPerKm: pacingBySegment[s.id]?.pace ?? 0,
  }))

  const arrivals = eventRows
    .filter((e) => e.actualArrival)
    .map((e) => ({ stationId: e.stationId, actualArrival: e.actualArrival! }))

  const liveProjections = recomputeProjections({ startTime: race.startTime, segments: projSegs, arrivals, blendWeight: 0.8 })
  const liveByStation = Object.fromEntries(liveProjections.map((p) => [p.stationId, p]))

  const eventByStation = Object.fromEntries(eventRows.map((e) => [e.stationId, e]))
  const projectedFinish = liveProjections[liveProjections.length - 1]?.projectedArrival

  const loggedCount = arrivals.length
  const totalStations = stationRows.length

  return (
    <RealtimeProvider raceId={raceId}>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="flex items-center gap-2 text-lg font-semibold">
              <Radio className="h-5 w-5 text-green-500 animate-pulse" />
              Live Monitoring
            </h2>
            <p className="text-sm text-muted-foreground mt-0.5">
              {loggedCount} of {totalStations} stations logged
            </p>
          </div>
          {projectedFinish && (
            <div className="text-right">
              <p className="text-xs text-muted-foreground">Projected finish</p>
              <p className="text-lg font-bold">{formatArrivalTime(projectedFinish.toISOString())}</p>
            </div>
          )}
        </div>

        {stationRows.length === 0 ? (
          <div className="rounded-lg border border-dashed p-8 text-center text-sm text-muted-foreground">
            No aid stations set up yet.
          </div>
        ) : !pacingRows.length ? (
          <div className="rounded-lg border border-dashed p-8 text-center text-sm text-muted-foreground">
            No pacing plan yet. Set your goal time in the Pacing tab first.
          </div>
        ) : (
          <div className="space-y-2">
            {stationRows.map((station) => {
              const live = liveByStation[station.id]
              const event = eventByStation[station.id]
              const origArrivalStr = pacingBySegment[segmentRows.find((s) => s.toStationId === station.id)?.id ?? '']?.originalArrival
              const origArrival = origArrivalStr ? new Date(origArrivalStr) : null
              const status = event?.actualArrival && origArrival
                ? getArrivalStatus(origArrival, event.actualArrival)
                : null

              const etaMs = live && !live.isActual ? live.projectedArrival.getTime() - Date.now() : null
              const etaMin = etaMs && etaMs > 0 ? Math.round(etaMs / 60000) : null

              return (
                <div key={station.id} className={`rounded-lg border px-4 py-3 flex items-center justify-between gap-4 ${live?.isActual ? 'bg-green-50 border-green-200' : 'bg-card'}`}>
                  <div className="min-w-0">
                    <div className="flex items-center gap-2">
                      <p className="font-medium text-sm truncate">{station.name}</p>
                      {live?.isActual && <span className="text-xs text-green-700 font-medium">✓ Logged</span>}
                    </div>
                    <p className="text-xs text-muted-foreground">{parseFloat(station.distanceKm).toFixed(1)} km</p>
                    {event?.conditionNotes && (
                      <p className="text-xs text-amber-700 mt-0.5 italic">"{event.conditionNotes}"</p>
                    )}
                  </div>
                  <div className="text-right shrink-0 space-y-1">
                    {live?.isActual && event?.actualArrival ? (
                      <>
                        <p className="text-sm font-semibold">{formatArrivalTime(event.actualArrival.toISOString())}</p>
                        {status && (
                          <span className={`rounded-full px-2 py-0.5 text-xs font-medium ${STATUS_STYLES[status]}`}>
                            {STATUS_LABELS[status]}
                          </span>
                        )}
                      </>
                    ) : live ? (
                      <>
                        <p className="text-sm text-muted-foreground">{formatArrivalTime(live.projectedArrival.toISOString())}</p>
                        {etaMin !== null && (
                          <p className="text-xs text-muted-foreground">ETA ~{etaMin}m</p>
                        )}
                      </>
                    ) : (
                      <p className="text-sm text-muted-foreground">—</p>
                    )}
                  </div>
                </div>
              )
            })}
          </div>
        )}
      </div>
    </RealtimeProvider>
  )
}
