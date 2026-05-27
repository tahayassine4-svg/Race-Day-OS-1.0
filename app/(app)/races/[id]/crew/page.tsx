import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { aidStations, crewAssignments, crewMembers, races } from '@/lib/db/schema'
import { and, eq, inArray } from 'drizzle-orm'
import { notFound } from 'next/navigation'
import { CrewRoster } from '@/components/crew/crew-roster'
import { StationAssignments } from '@/components/crew/station-assignments'
import { CrewLinkBanner } from '@/components/crew/crew-link-banner'

export default async function CrewPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id: raceId } = await params
  const session = await auth()

  const race = await db.query.races.findFirst({
    where: and(eq(races.id, raceId), eq(races.userId, session!.user.id)),
    columns: { id: true, crewToken: true },
  })
  if (!race) notFound()

  const [memberRows, crewStationRows] = await Promise.all([
    db.select().from(crewMembers).where(eq(crewMembers.raceId, raceId)),
    db
      .select({ id: aidStations.id, name: aidStations.name, distanceKm: aidStations.distanceKm })
      .from(aidStations)
      .where(and(eq(aidStations.raceId, raceId), eq(aidStations.crewAccess, true))),
  ])

  const memberIds = memberRows.map((m) => m.id)
  const assignmentRows =
    memberIds.length > 0
      ? await db
          .select()
          .from(crewAssignments)
          .where(inArray(crewAssignments.crewMemberId, memberIds))
      : []

  const memberNameById = Object.fromEntries(memberRows.map((m) => [m.id, m.name]))

  const assignments = assignmentRows.map((a) => ({
    id: a.id,
    stationId: a.stationId,
    memberId: a.crewMemberId,
    memberName: memberNameById[a.crewMemberId] ?? 'Unknown',
    role: a.role,
  }))

  return (
    <div className="space-y-8">
      <CrewLinkBanner raceId={raceId} crewToken={race.crewToken ?? null} />
      <CrewRoster raceId={raceId} members={memberRows} />
      <div className="border-t pt-6">
        <StationAssignments
          raceId={raceId}
          crewStations={crewStationRows}
          members={memberRows.map((m) => ({ id: m.id, name: m.name }))}
          assignments={assignments}
        />
      </div>
    </div>
  )
}
