import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { races } from '@/lib/db/schema'
import { and, eq } from 'drizzle-orm'
import { notFound, redirect } from 'next/navigation'
import { BuilderClient } from '@/components/import/builder-client'
import type { TrackPoint, ParsedStation } from '@/lib/gpx-parser'

export default async function BuilderPage({ params }: { params: Promise<{ id: string }> }) {
  const { id: raceId } = await params
  const session = await auth()

  const race = await db.query.races.findFirst({
    where: and(eq(races.id, raceId), eq(races.userId, session!.user.id)),
    columns: { id: true, gpxTrackPoints: true, importedStations: true },
  })
  if (!race) notFound()

  const trackPoints = (race.gpxTrackPoints as TrackPoint[] | null) ?? []
  if (trackPoints.length === 0) redirect(`/races/${raceId}/import`)

  const importedStations = (race.importedStations as ParsedStation[] | null) ?? []

  return (
    <div className="max-w-4xl">
      <BuilderClient
        raceId={raceId}
        trackPoints={trackPoints}
        importedStations={importedStations}
      />
    </div>
  )
}
