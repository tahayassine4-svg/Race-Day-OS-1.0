import { db } from '@/lib/db'
import { aidStations, crewAssignments, crewMembers, pacePlans, races, segments, stationEvents, users } from '@/lib/db/schema'
import { and, asc, eq, inArray } from 'drizzle-orm'
import { notFound } from 'next/navigation'
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

  const race = await db.query.races.findFirst({
    where: eq(races.crewToken, token),
    columns: { id: true, name: true, startTime: true, userId: true, activeScenario: true },
  })
  if (!race) notFound()

  const [runner, stationRows, memberRows, eventRows] = await Promise.all([
    db.query.users.findFirst({
      where: eq(users.id, race.userId),
      columns: { name: true, email: true },
    }),
    db.select().from(aidStations).where(eq(aidStations.raceId, race.id)).orderBy(asc(aidStations.distanceKm)),
    db.select().from(crewMembers).where(eq(crewMembers.raceId, race.id)),
    db.select().from(stationEvents).where(eq(stationEvents.raceId, race.id)),
  ])

  const stationIds = stationRows.map((s) => s.id)

  // Pacing: get projectedArrivalTime per toStationId
  const [segmentRows, pacingRows] = await Promise.all([
    db.select({ id: segments.id, toStationId: segments.toStationId })
      .from(segments).where(eq(segments.raceId, race.id)),
    stationIds.length > 0
      ? db.select({ segmentId: pacePlans.segmentId, projectedArrivalTime: pacePlans.projectedArrivalTime })
          .from(pacePlans)
          .where(and(eq(pacePlans.raceId, race.id), eq(pacePlans.scenario, race.activeScenario)))
      : Promise.resolve([]),
  ])

  const pacingBySegment = Object.fromEntries(
    pacingRows.map((p) => [p.segmentId, p.projectedArrivalTime?.toISOString() ?? null])
  )
  const segmentByToStation = Object.fromEntries(segmentRows.map((s) => [s.toStationId, s.id]))
  const projectedByStation: Record<string, string | null> = Object.fromEntries(
    stationIds.map((id) => [id, pacingBySegment[segmentByToStation[id]] ?? null])
  )

  const eventByStation = Object.fromEntries(
    eventRows.map((e) => [
      e.stationId,
      {
        actualArrival: e.actualArrival?.toISOString() ?? null,
        projectedArrival: projectedByStation[e.stationId] ?? null,
      },
    ])
  )

  // "Your stations" via ?crew=Alice
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

  const yourStations = stationRows.filter((s) => yourStationIds.has(s.id))
  const allStations = stationRows

  const stationCard = (station: typeof stationRows[number], isYours = false) => (
    <CrewStationCard
      key={station.id}
      station={{ id: station.id, name: station.name, distanceKm: station.distanceKm, crewAccess: station.crewAccess }}
      event={eventByStation[station.id] ?? { actualArrival: null, projectedArrival: projectedByStation[station.id] ?? null }}
      crewToken={token}
      isYourStation={isYours}
    />
  )

  return (
    <div className="space-y-6">
      <div className="text-center space-y-1 pb-4 border-b">
        <p className="text-xs uppercase tracking-widest text-muted-foreground font-medium">Race Day OS</p>
        <h1 className="text-2xl font-bold">{race.name}</h1>
        <div className="flex items-center justify-center gap-1.5 text-sm text-muted-foreground">
          <CalendarDays className="h-4 w-4" />
          {new Date(race.startTime).toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}
          {' · '}
          {new Date(race.startTime).toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })}
        </div>
        {runner && (
          <p className="text-sm text-muted-foreground">Runner: <strong>{runner.name ?? runner.email}</strong></p>
        )}
      </div>

      {yourStations.length > 0 && (
        <div className="space-y-3">
          <h2 className="text-sm font-semibold uppercase tracking-wide text-muted-foreground">
            Your Stations — {crewName}
          </h2>
          <div className="space-y-3">
            {yourStations.map((s) => stationCard(s, true))}
          </div>
        </div>
      )}

      <div className="space-y-3">
        <h2 className="text-sm font-semibold uppercase tracking-wide text-muted-foreground">All Stations</h2>
        {allStations.length === 0 ? (
          <p className="text-sm text-muted-foreground text-center py-4">No stations set up yet.</p>
        ) : (
          <div className="space-y-3">
            {allStations.map((s) => stationCard(s, yourStationIds.has(s.id)))}
          </div>
        )}
      </div>
    </div>
  )
}
