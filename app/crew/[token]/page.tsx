import { db } from '@/lib/db'
import { aidStations, crewAssignments, crewMembers, pacePlans, races, segments, stationEvents, users } from '@/lib/db/schema'
import { and, asc, eq, inArray } from 'drizzle-orm'
import { notFound } from 'next/navigation'
import { recomputeProjections, getArrivalStatus, STATUS_STYLES, STATUS_LABELS } from '@/lib/live-projections'
import { formatArrivalTime } from '@/lib/pacing'
import { RealtimeProvider } from '@/components/realtime-provider'
import { CrewStationCard } from '@/components/crew/crew-station-card'
import { CalendarDays } from 'lucide-react'

export default async function CrewDashboardPage({
  params,
  searchParams,
}: {
  params: Promise<{ token: string }>
  searchParams: Promise<{ crew?: string }>
}) {
  const { token } = await params
  const { crew: crewName } = await searchParams

  const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
  if (!UUID_RE.test(token)) notFound()

  const race = await db.query.races.findFirst({
    where: eq(races.crewToken, token),
    columns: { id: true, name: true, startTime: true, userId: true, activeScenario: true },
  })
  if (!race) notFound()

  const [runner, stationRows, memberRows, eventRows, segmentRows] = await Promise.all([
    db.query.users.findFirst({ where: eq(users.id, race.userId), columns: { name: true, email: true } }),
    db.select().from(aidStations).where(eq(aidStations.raceId, race.id)).orderBy(asc(aidStations.distanceKm)),
    db.select().from(crewMembers).where(eq(crewMembers.raceId, race.id)),
    db.select().from(stationEvents).where(eq(stationEvents.raceId, race.id)),
    db.select({ id: segments.id, toStationId: segments.toStationId, distanceKm: segments.distanceKm, sortOrder: segments.sortOrder })
      .from(segments).where(eq(segments.raceId, race.id)).orderBy(asc(segments.sortOrder)),
  ])

  const stationIds = stationRows.map((s) => s.id)

  const pacingRows =
    segmentRows.length > 0
      ? await db
          .select({ segmentId: pacePlans.segmentId, plannedPaceSecPerKm: pacePlans.plannedPaceSecPerKm, projectedArrivalTime: pacePlans.projectedArrivalTime })
          .from(pacePlans)
          .where(and(eq(pacePlans.raceId, race.id), eq(pacePlans.scenario, race.activeScenario)))
      : []

  const pacingBySegment = Object.fromEntries(
    pacingRows.map((p) => [p.segmentId, { pace: p.plannedPaceSecPerKm ?? 0, originalArrival: p.projectedArrivalTime?.toISOString() ?? null }])
  )
  const segByToStation = Object.fromEntries(segmentRows.map((s) => [s.toStationId, s.id]))

  // Live projection recomputation
  const arrivals = eventRows.filter((e) => e.actualArrival).map((e) => ({
    stationId: e.stationId,
    actualArrival: e.actualArrival!,
  }))
  const projSegs = segmentRows.map((s) => ({
    id: s.id,
    toStationId: s.toStationId ?? '',
    distanceKm: Number(s.distanceKm),
    plannedPaceSecPerKm: pacingBySegment[s.id]?.pace ?? 0,
  }))
  const liveProjections = projSegs.some((s) => s.plannedPaceSecPerKm > 0)
    ? recomputeProjections({ startTime: race.startTime, segments: projSegs, arrivals, blendWeight: 0.8 })
    : []
  const liveByStation = Object.fromEntries(liveProjections.map((p) => [p.stationId, p]))
  const projectedFinish = liveProjections[liveProjections.length - 1]?.projectedArrival
  const eventByStation = Object.fromEntries(eventRows.map((e) => [e.stationId, e]))

  // Next crew station ETA
  const nextCrewStation = stationRows.find((s) => s.crewAccess && !eventByStation[s.id]?.actualArrival)
  const nextEtaMs = nextCrewStation && liveByStation[nextCrewStation.id]
    ? liveByStation[nextCrewStation.id].projectedArrival.getTime() - Date.now()
    : null
  const nextEtaMin = nextEtaMs && nextEtaMs > 0 ? Math.round(nextEtaMs / 60000) : null

  // "Your stations"
  let yourStationIds = new Set<string>()
  if (crewName) {
    const myMember = memberRows.find((m) => m.name.toLowerCase() === crewName.toLowerCase())
    if (myMember) {
      const myAssignments = await db
        .select({ stationId: crewAssignments.stationId })
        .from(crewAssignments)
        .where(eq(crewAssignments.crewMemberId, myMember.id))
      yourStationIds = new Set(myAssignments.map((a) => a.stationId))
    }
  }

  const makeEventProp = (stationId: string) => ({
    actualArrival: eventByStation[stationId]?.actualArrival?.toISOString() ?? null,
    projectedArrival: liveByStation[stationId]?.projectedArrival?.toISOString() ?? null,
  })

  return (
    <RealtimeProvider raceId={race.id}>
      <div className="space-y-6">
        <div className="border-b pb-4 text-center space-y-1">
          <p className="text-xs uppercase tracking-widest text-muted-foreground font-medium">Race Day OS</p>
          <h1 className="text-2xl font-bold">{race.name}</h1>
          <div className="flex items-center justify-center gap-1.5 text-sm text-muted-foreground">
            <CalendarDays className="h-4 w-4" />
            {new Date(race.startTime).toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}
            {' · '}
            {new Date(race.startTime).toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })}
          </div>
          {runner && <p className="text-sm text-muted-foreground">Runner: <strong>{runner.name ?? runner.email}</strong></p>}
          <div className="flex items-center justify-center gap-6 pt-1 text-sm">
            {projectedFinish && (
              <div className="text-center">
                <p className="text-xs text-muted-foreground">Projected finish</p>
                <p className="font-bold">{formatArrivalTime(projectedFinish.toISOString())}</p>
              </div>
            )}
            {nextEtaMin !== null && nextCrewStation && (
              <div className="text-center">
                <p className="text-xs text-muted-foreground">Next crew stop</p>
                <p className="font-bold">~{nextEtaMin} min</p>
              </div>
            )}
          </div>
        </div>

        {yourStationIds.size > 0 && (
          <div className="space-y-3">
            <h2 className="text-sm font-semibold uppercase tracking-wide text-muted-foreground">Your Stations — {crewName}</h2>
            <div className="space-y-3">
              {stationRows.filter((s) => yourStationIds.has(s.id)).map((s) => (
                <CrewStationCard
                  key={s.id}
                  station={{ id: s.id, name: s.name, distanceKm: s.distanceKm, crewAccess: s.crewAccess }}
                  event={makeEventProp(s.id)}
                  crewToken={token}
                  isYourStation
                />
              ))}
            </div>
          </div>
        )}

        <div className="space-y-3">
          <h2 className="text-sm font-semibold uppercase tracking-wide text-muted-foreground">All Stations</h2>
          {stationRows.length === 0 ? (
            <div className="rounded-lg border border-dashed p-6 text-center space-y-1">
              <p className="text-sm font-medium">Race plan not ready yet</p>
              <p className="text-sm text-muted-foreground">
                {runner?.name ?? 'The runner'} is still setting up the course. Check back closer to race day.
              </p>
            </div>
          ) : (
            <div className="space-y-3">
              {stationRows.map((s) => (
                <CrewStationCard
                  key={s.id}
                  station={{ id: s.id, name: s.name, distanceKm: s.distanceKm, crewAccess: s.crewAccess }}
                  event={makeEventProp(s.id)}
                  crewToken={token}
                  isYourStation={yourStationIds.has(s.id)}
                />
              ))}
            </div>
          )}
        </div>
      </div>
    </RealtimeProvider>
  )
}
