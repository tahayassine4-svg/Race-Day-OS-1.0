'use server'

import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { fuelPlans, races } from '@/lib/db/schema'
import { and, eq } from 'drizzle-orm'

type Result = { ok: true } | { error: string }

async function verifyOwnership(raceId: string, userId: string) {
  return db.query.races.findFirst({
    where: and(eq(races.id, raceId), eq(races.userId, userId)),
    columns: { id: true },
  })
}

async function getFuelPlanRow(raceId: string, segmentId: string) {
  return db.query.fuelPlans.findFirst({
    where: and(eq(fuelPlans.raceId, raceId), eq(fuelPlans.segmentId, segmentId)),
  })
}

export async function saveGlobalTargets(
  raceId: string,
  cal: number,
  fluid: number,
  sodium: number
): Promise<Result> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }
  if (!(await verifyOwnership(raceId, session.user.id))) return { error: 'Race not found' }

  try {
    await db
      .update(races)
      .set({
        fuelCalPerHour: cal,
        fuelFluidMlPerHour: fluid,
        fuelSodiumMgPerHour: sodium,
      })
      .where(eq(races.id, raceId))
    return { ok: true }
  } catch {
    return { error: 'Failed to save targets' }
  }
}

export async function saveSegmentOverride(
  raceId: string,
  segmentId: string,
  cal: number,
  fluid: number,
  sodium: number
): Promise<Result> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }
  if (!(await verifyOwnership(raceId, session.user.id))) return { error: 'Race not found' }

  try {
    const existing = await getFuelPlanRow(raceId, segmentId)
    if (existing) {
      await db
        .update(fuelPlans)
        .set({
          targetCalPerHour: cal,
          targetFluidMlPerHour: fluid,
          targetSodiumMgPerHour: sodium,
          isManualOverride: true,
        })
        .where(eq(fuelPlans.id, existing.id))
    } else {
      await db.insert(fuelPlans).values({
        raceId,
        segmentId,
        targetCalPerHour: cal,
        targetFluidMlPerHour: fluid,
        targetSodiumMgPerHour: sodium,
        isManualOverride: true,
      })
    }
    return { ok: true }
  } catch {
    return { error: 'Failed to save override' }
  }
}

export async function clearSegmentOverride(
  raceId: string,
  segmentId: string
): Promise<Result> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }
  if (!(await verifyOwnership(raceId, session.user.id))) return { error: 'Race not found' }

  try {
    const existing = await getFuelPlanRow(raceId, segmentId)
    if (existing) {
      await db
        .update(fuelPlans)
        .set({
          targetCalPerHour: null,
          targetFluidMlPerHour: null,
          targetSodiumMgPerHour: null,
          isManualOverride: false,
        })
        .where(eq(fuelPlans.id, existing.id))
    }
    return { ok: true }
  } catch {
    return { error: 'Failed to clear override' }
  }
}

export async function saveStationNotes(
  raceId: string,
  segmentId: string,
  notes: string
): Promise<Result> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }
  if (!(await verifyOwnership(raceId, session.user.id))) return { error: 'Race not found' }

  try {
    const existing = await getFuelPlanRow(raceId, segmentId)
    if (existing) {
      await db
        .update(fuelPlans)
        .set({ itemNotes: notes || null })
        .where(eq(fuelPlans.id, existing.id))
    } else {
      await db.insert(fuelPlans).values({
        raceId,
        segmentId,
        itemNotes: notes || null,
        isManualOverride: false,
      })
    }
    return { ok: true }
  } catch {
    return { error: 'Failed to save notes' }
  }
}
