'use server'

import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { aidStations, races, segments } from '@/lib/db/schema'
import { and, asc, eq, sql } from 'drizzle-orm'

type DbTx = Parameters<Parameters<typeof db.transaction>[0]>[0]

export type StationData = {
  name: string
  distanceKm: string
  crewAccess: boolean
  pacerAccess: boolean
  dropBag: boolean
  services: string
}

async function verifyOwnership(raceId: string, userId: string) {
  return db.query.races.findFirst({
    where: and(eq(races.id, raceId), eq(races.userId, userId)),
    columns: { id: true },
  })
}

async function recomputeSegments(raceId: string, tx: DbTx) {
  const ordered = await tx
    .select()
    .from(aidStations)
    .where(eq(aidStations.raceId, raceId))
    .orderBy(asc(aidStations.distanceKm))

  await tx.delete(segments).where(eq(segments.raceId, raceId))

  if (ordered.length < 2) return

  await tx.insert(segments).values(
    ordered.slice(0, -1).map((from, i) => ({
      raceId,
      fromStationId: from.id,
      toStationId: ordered[i + 1].id,
      distanceKm: String(
        Math.max(0, Number(ordered[i + 1].distanceKm) - Number(from.distanceKm))
      ),
      elevGainM: 0,
      elevLossM: 0,
      sortOrder: i,
    }))
  )
}

export async function createStation(
  raceId: string,
  data: StationData
): Promise<{ ok: true } | { error: string }> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }
  if (!(await verifyOwnership(raceId, session.user.id))) return { error: 'Race not found' }

  const [{ count }] = await db
    .select({ count: sql<number>`count(*)` })
    .from(aidStations)
    .where(eq(aidStations.raceId, raceId))

  try {
    await db.transaction(async (tx) => {
      await tx.insert(aidStations).values({
        raceId,
        name: data.name.trim(),
        distanceKm: data.distanceKm,
        crewAccess: data.crewAccess,
        pacerAccess: data.pacerAccess,
        dropBag: data.dropBag,
        services: data.services,
        sortOrder: Number(count),
      })
      await recomputeSegments(raceId, tx)
    })
    return { ok: true }
  } catch {
    return { error: 'Failed to add station' }
  }
}

export async function updateStation(
  stationId: string,
  raceId: string,
  data: StationData
): Promise<{ ok: true } | { error: string }> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }
  if (!(await verifyOwnership(raceId, session.user.id))) return { error: 'Race not found' }

  try {
    await db.transaction(async (tx) => {
      await tx
        .update(aidStations)
        .set({
          name: data.name.trim(),
          distanceKm: data.distanceKm,
          crewAccess: data.crewAccess,
          pacerAccess: data.pacerAccess,
          dropBag: data.dropBag,
          services: data.services,
        })
        .where(and(eq(aidStations.id, stationId), eq(aidStations.raceId, raceId)))
      await recomputeSegments(raceId, tx)
    })
    return { ok: true }
  } catch {
    return { error: 'Failed to update station' }
  }
}

export async function deleteStation(
  stationId: string,
  raceId: string
): Promise<{ ok: true } | { error: string }> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }
  if (!(await verifyOwnership(raceId, session.user.id))) return { error: 'Race not found' }

  try {
    await db.transaction(async (tx) => {
      await tx
        .delete(aidStations)
        .where(and(eq(aidStations.id, stationId), eq(aidStations.raceId, raceId)))
      await recomputeSegments(raceId, tx)
    })
    return { ok: true }
  } catch {
    return { error: 'Failed to delete station' }
  }
}
