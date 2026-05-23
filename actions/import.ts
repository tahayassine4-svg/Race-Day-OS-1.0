'use server'

import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { races } from '@/lib/db/schema'
import { and, eq } from 'drizzle-orm'
import type { TrackPoint, ParsedStation } from '@/lib/gpx-parser'

export async function saveImportData(
  raceId: string,
  trackPoints: TrackPoint[],
  stations: ParsedStation[],
  source: 'gpx' | 'gpx+excel',
): Promise<{ error: string } | void> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }

  const race = await db.query.races.findFirst({
    where: and(eq(races.id, raceId), eq(races.userId, session.user.id)),
    columns: { id: true },
  })
  if (!race) return { error: 'Race not found' }

  const totalKm = trackPoints.length > 0 ? trackPoints[trackPoints.length - 1].cumKm : null

  // Recompute elevation gain from sampled points (approximate)
  let elevGainM = 0
  for (let i = 1; i < trackPoints.length; i++) {
    const diff = trackPoints[i].ele - trackPoints[i - 1].ele
    if (diff > 0) elevGainM += diff
  }

  await db
    .update(races)
    .set({
      gpxTrackPoints: trackPoints,
      importedStations: stations,
      importSource: source,
      ...(totalKm != null ? { distanceKm: totalKm.toFixed(2) } : {}),
      ...(elevGainM > 0 ? { elevationGainM: Math.round(elevGainM) } : {}),
      updatedAt: new Date(),
    })
    .where(eq(races.id, raceId))
}

export async function clearImportData(raceId: string): Promise<void> {
  await db
    .update(races)
    .set({ importedStations: null, updatedAt: new Date() })
    .where(eq(races.id, raceId))
}
