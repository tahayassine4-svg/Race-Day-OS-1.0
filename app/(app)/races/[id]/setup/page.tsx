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

  const hasStations = stationRows.length > 0

  return (
    <div className="space-y-8">
      {!hasStations && (
        <div className="rounded-lg border bg-muted/30 p-5 space-y-4">
          <div>
            <p className="text-sm font-semibold">Getting started</p>
            <p className="text-xs text-muted-foreground mt-0.5">Complete these steps to unlock pacing, fueling, and your crew link.</p>
          </div>
          <ol className="space-y-2 text-sm">
            <li className="flex items-start gap-2">
              <span className="mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-green-100 text-xs font-bold text-green-700">✓</span>
              <span className="text-muted-foreground line-through">Create your race</span>
            </li>
            <li className="flex items-start gap-2">
              <span className="mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-primary text-xs font-bold text-primary-foreground">2</span>
              <span>
                <strong>Add your aid stations</strong>
                <span className="block text-xs text-muted-foreground">Use the form below, or{' '}
                  <Link href={`/races/${raceId}/import`} className="underline underline-offset-2">import a GPX file</Link>
                  {' '}for automatic station placement.
                </span>
              </span>
            </li>
            <li className="flex items-start gap-2 opacity-50">
              <span className="mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded-full border text-xs font-bold">3</span>
              <span>
                Set your goal time in <strong>Pacing</strong>
              </span>
            </li>
            <li className="flex items-start gap-2 opacity-50">
              <span className="mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded-full border text-xs font-bold">4</span>
              <span>
                Generate and share your <strong>Crew link</strong>
              </span>
            </li>
          </ol>
        </div>
      )}
      <div className="flex items-center justify-end">
        <Link
          href={`/races/${raceId}/import`}
          className="flex items-center gap-1.5 text-sm text-muted-foreground underline-offset-4 hover:text-foreground hover:underline"
        >
          <Upload className="h-3.5 w-3.5" />
          Import from GPX / Excel
        </Link>
      </div>
      <AidStationList raceId={raceId} stations={stationRows} crewByStation={crewByStation} />
      <SegmentList raceId={raceId} segments={segmentRows} stations={stationRows} />
    </div>
  )
}
