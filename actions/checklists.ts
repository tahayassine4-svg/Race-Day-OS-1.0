'use server'

import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { aidStations, races, stationChecklists } from '@/lib/db/schema'
import { and, eq } from 'drizzle-orm'

export type ChecklistItem = { id: string; text: string; order: number }

type SaveData = {
  runnerTasks: ChecklistItem[]
  crewTasks: ChecklistItem[]
  mentalAnchor: string | null
}

type Result = { ok: true } | { error: string }

export async function saveChecklist(
  stationId: string,
  data: SaveData
): Promise<Result> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }

  // Verify ownership via station → race → user
  const station = await db.query.aidStations.findFirst({
    where: eq(aidStations.id, stationId),
    columns: { raceId: true },
  })
  if (!station) return { error: 'Station not found' }

  const race = await db.query.races.findFirst({
    where: and(eq(races.id, station.raceId), eq(races.userId, session.user.id)),
    columns: { id: true },
  })
  if (!race) return { error: 'Access denied' }

  try {
    await db
      .insert(stationChecklists)
      .values({
        stationId,
        runnerTasks: data.runnerTasks,
        crewTasks: data.crewTasks,
        mentalAnchor: data.mentalAnchor,
      })
      .onConflictDoUpdate({
        target: stationChecklists.stationId,
        set: {
          runnerTasks: data.runnerTasks,
          crewTasks: data.crewTasks,
          mentalAnchor: data.mentalAnchor,
        },
      })
    return { ok: true }
  } catch {
    return { error: 'Failed to save checklist' }
  }
}
