import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { aidStations, crewAssignments, crewMembers, races, segments } from '@/lib/db/schema'
import { and, asc, eq, inArray } from 'drizzle-orm'
import { notFound } from 'next/navigation'
import Link from 'next/link'
import { Upload } from 'lucide-react'
import { AidStationList } from '@/components/races/aid-station-list'
import { SegmentList } from '@/components/races/segment-list'

export default async function SetupPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id: raceId } = await params
  const session = await auth()

  const race = await db.query.races.findFirst({
    where: and(eq(races.id, raceId), eq(races.userId, session!.user.id)),
    columns: { id: true },
  })
  if (!race) notFound()

  const [stationRows, segmentRows, memberRows] = await Promise.all([
    db
      .select()
      .from(aidStations)
      .where(eq(aidStations.raceId, raceId))
      .orderBy(asc(aidStations.distanceKm)),
    db
      .select()
      .from(segments)
      .where(eq(segments.raceId, raceId))
      .orderBy(asc(segments.sortOrder)),
    db.select().from(crewMembers).where(eq(crewMembers.raceId, raceId)),
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

  const crewByStation: Record<string, string[]> = {}
  for (const a of assignmentRows) {
    if (!crewByStation[a.stationId]) crewByStation[a.stationId] = []
    crewByStation[a.stationId].push(memberNameById[a.crewMemberId] ?? 'Unknown')
  }

  return (
    <div className="space-y-8">
      <div className="flex items-center justify-end">
        <Link
          href={`/races/${raceId}/import`}
          className="flex items-center gap-1.5 text-sm text-muted-foreground underline-offset-4 hover:text-foreground hover:underline"
        >
          <Upload className="h-3.5 w-3.5" />
          Re-import from GPX / Excel
        </Link>
      </div>
      <AidStationList raceId={raceId} stations={stationRows} crewByStation={crewByStation} />
      <SegmentList raceId={raceId} segments={segmentRows} stations={stationRows} />
    </div>
  )
}
