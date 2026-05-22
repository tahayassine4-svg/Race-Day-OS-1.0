'use server'

import { db } from '@/lib/db'
import { aidStations, races, stationEvents } from '@/lib/db/schema'
import { and, eq } from 'drizzle-orm'

type Result = { ok: true } | { error: string }

async function resolveRace(crewToken: string) {
  return db.query.races.findFirst({
    where: eq(races.crewToken, crewToken),
    columns: { id: true },
  })
}

async function verifyStation(stationId: string, raceId: string) {
  return db.query.aidStations.findFirst({
    where: and(eq(aidStations.id, stationId), eq(aidStations.raceId, raceId)),
    columns: { id: true },
  })
}

async function getOrCreateEvent(stationId: string, raceId: string) {
  const existing = await db.query.stationEvents.findFirst({
    where: and(eq(stationEvents.stationId, stationId), eq(stationEvents.raceId, raceId)),
  })
  if (existing) return existing

  const [created] = await db
    .insert(stationEvents)
    .values({ stationId, raceId, loggedBy: 'crew' })
    .returning()
  return created
}

export async function logArrival(crewToken: string, stationId: string): Promise<Result> {
  const race = await resolveRace(crewToken)
  if (!race) return { error: 'Invalid crew link' }
  if (!(await verifyStation(stationId, race.id))) return { error: 'Station not found' }

  try {
    const event = await getOrCreateEvent(stationId, race.id)
    await db
      .update(stationEvents)
      .set({ actualArrival: new Date(), updatedAt: new Date() })
      .where(eq(stationEvents.id, event.id))
    return { ok: true }
  } catch {
    return { error: 'Failed to log arrival' }
  }
}

export async function logDeparture(crewToken: string, stationId: string): Promise<Result> {
  const race = await resolveRace(crewToken)
  if (!race) return { error: 'Invalid crew link' }
  if (!(await verifyStation(stationId, race.id))) return { error: 'Station not found' }

  try {
    const event = await getOrCreateEvent(stationId, race.id)
    await db
      .update(stationEvents)
      .set({ actualDeparture: new Date(), updatedAt: new Date() })
      .where(eq(stationEvents.id, event.id))
    return { ok: true }
  } catch {
    return { error: 'Failed to log departure' }
  }
}

export async function saveConditionNotes(
  crewToken: string,
  stationId: string,
  notes: string
): Promise<Result> {
  const race = await resolveRace(crewToken)
  if (!race) return { error: 'Invalid crew link' }
  if (!(await verifyStation(stationId, race.id))) return { error: 'Station not found' }

  try {
    const event = await getOrCreateEvent(stationId, race.id)
    await db
      .update(stationEvents)
      .set({ conditionNotes: notes.trim() || null, updatedAt: new Date() })
      .where(eq(stationEvents.id, event.id))
    return { ok: true }
  } catch {
    return { error: 'Failed to save notes' }
  }
}
