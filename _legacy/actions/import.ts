'use server'

import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { aidStations, races, segments } from '@/lib/db/schema'
import { and, eq } from 'drizzle-orm'
import type { TrackPoint, ParsedStation } from '@/lib/gpx-parser'

type ConfirmStation = {
  name: string
  distanceKm: number
  crewAccess: boolean
  dropBag: boolean
  services: string
  cutoffTime: string  // HH:MM from race start, '' = none
}

type TrackPt = { cumKm: number; ele: number }

function parseCutoffSeconds(cutoffTime: string): number | null {
  const m = cutoffTime.match(/^(\d{1,2}):(\d{2})$/)
  if (!m) return null
  return parseInt(m[1]) * 3600 + parseInt(m[2]) * 60
}

function segmentElev(track: TrackPt[], fromKm: number, toKm: number) {
  const pts = track.filter(p => p.cumKm >= fromKm && p.cumKm <= toKm)
  let gainM = 0, lossM = 0
  for (let i = 1; i < pts.length; i++) {
    const diff = pts[i].ele - pts[i - 1].ele
    if (diff > 0) gainM += diff
    else lossM += Math.abs(diff)
  }
  return { gainM: Math.round(gainM), lossM: Math.round(lossM) }
}

export async function confirmImport(
  raceId: string,
  draftStations: ConfirmStation[],
): Promise<{ error: string } | void> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }

  const race = await db.query.races.findFirst({
    where: and(eq(races.id, raceId), eq(races.userId, session.user.id)),
    columns: { id: true, gpxTrackPoints: true },
  })
  if (!race) return { error: 'Race not found' }

  const track = (race.gpxTrackPoints as TrackPt[] | null) ?? []
  const sorted = [...draftStations].sort((a, b) => a.distanceKm - b.distanceKm)

  try {
    await db.transaction(async (tx) => {
      // Delete existing stations — cascades to segments, pacePlans, fuelPlans, checklists
      await tx.delete(aidStations).where(eq(aidStations.raceId, raceId))

      // Insert new stations and collect their IDs
      const inserted: Array<{ id: string; distanceKm: string }> = []
      for (let i = 0; i < sorted.length; i++) {
        const s = sorted[i]
        const [row] = await tx
          .insert(aidStations)
          .values({
            raceId,
            name: s.name,
            distanceKm: s.distanceKm.toFixed(2),
            crewAccess: s.crewAccess,
            pacerAccess: false,
            dropBag: s.dropBag,
            services: s.services,
            cutoffSeconds: parseCutoffSeconds(s.cutoffTime),
            sortOrder: i,
          })
          .returning({ id: aidStations.id, distanceKm: aidStations.distanceKm })
        inserted.push(row)
      }

      // Insert segments between consecutive stations
      if (inserted.length >= 2) {
        let totalElevGainM = 0
        const segVals = inserted.slice(0, -1).map((from, i) => {
          const to = inserted[i + 1]
          const fromKm = parseFloat(from.distanceKm)
          const toKm = parseFloat(to.distanceKm)
          const { gainM, lossM } = segmentElev(track, fromKm, toKm)
          totalElevGainM += gainM
          return {
            raceId,
            fromStationId: from.id,
            toStationId: to.id,
            distanceKm: Math.max(0, toKm - fromKm).toFixed(2),
            elevGainM: gainM,
            elevLossM: lossM,
            sortOrder: i,
          }
        })
        await tx.insert(segments).values(segVals)

        const totalKm = parseFloat(inserted[inserted.length - 1].distanceKm)
        await tx
          .update(races)
          .set({
            importedStations: null,
            distanceKm: totalKm.toFixed(2),
            elevationGainM: totalElevGainM,
            updatedAt: new Date(),
          })
          .where(eq(races.id, raceId))
      } else {
        await tx
          .update(races)
          .set({ importedStations: null, updatedAt: new Date() })
          .where(eq(races.id, raceId))
      }
    })
  } catch {
    return { error: 'Failed to save course data. Please try again.' }
  }
}

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
