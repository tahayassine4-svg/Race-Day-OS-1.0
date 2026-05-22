'use server'

import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { races, segments } from '@/lib/db/schema'
import { and, eq } from 'drizzle-orm'

export async function updateSegmentElevation(
  segmentId: string,
  raceId: string,
  elevGainM: number,
  elevLossM: number
): Promise<{ ok: true } | { error: string }> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }

  const race = await db.query.races.findFirst({
    where: and(eq(races.id, raceId), eq(races.userId, session.user.id)),
    columns: { id: true },
  })
  if (!race) return { error: 'Race not found' }

  try {
    await db
      .update(segments)
      .set({ elevGainM, elevLossM })
      .where(and(eq(segments.id, segmentId), eq(segments.raceId, raceId)))
    return { ok: true }
  } catch {
    return { error: 'Failed to update elevation' }
  }
}
