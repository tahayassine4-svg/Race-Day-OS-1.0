'use server'

import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { races } from '@/lib/db/schema'
import { and, eq } from 'drizzle-orm'

type Result = { token: string } | { error: string }

async function verifyOwnership(raceId: string, userId: string) {
  return db.query.races.findFirst({
    where: and(eq(races.id, raceId), eq(races.userId, userId)),
    columns: { id: true },
  })
}

export async function generateCrewToken(raceId: string): Promise<Result> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }
  if (!(await verifyOwnership(raceId, session.user.id))) return { error: 'Race not found' }

  const token = crypto.randomUUID()
  try {
    await db.update(races).set({ crewToken: token }).where(eq(races.id, raceId))
    return { token }
  } catch {
    return { error: 'Failed to generate crew link' }
  }
}

export async function rotateCrewToken(raceId: string): Promise<Result> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }
  if (!(await verifyOwnership(raceId, session.user.id))) return { error: 'Race not found' }

  const token = crypto.randomUUID()
  try {
    await db.update(races).set({ crewToken: token }).where(eq(races.id, raceId))
    return { token }
  } catch {
    return { error: 'Failed to rotate crew link' }
  }
}
