import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { aidStations, races, segments } from '@/lib/db/schema'
import { and, asc, eq } from 'drizzle-orm'
import { notFound } from 'next/navigation'
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

  const [stationRows, segmentRows] = await Promise.all([
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
  ])

  return (
    <div className="space-y-8">
      <AidStationList raceId={raceId} stations={stationRows} />
      <SegmentList raceId={raceId} segments={segmentRows} stations={stationRows} />
    </div>
  )
}
