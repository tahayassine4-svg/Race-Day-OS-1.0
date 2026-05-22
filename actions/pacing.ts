'use server'

import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { pacePlans, races, segments } from '@/lib/db/schema'
import { computePacePlan } from '@/lib/pacing'
import { and, asc, eq } from 'drizzle-orm'

type Scenario = 'optimistic' | 'base' | 'pessimistic'
type Result = { ok: true } | { error: string }

async function verifyOwnership(raceId: string, userId: string) {
  return db.query.races.findFirst({
    where: and(eq(races.id, raceId), eq(races.userId, userId)),
    columns: { id: true, startTime: true, scenarioGoals: true },
  })
}

async function recomputeAndStore(raceId: string, scenario: Scenario) {
  const race = await db.query.races.findFirst({
    where: eq(races.id, raceId),
    columns: { startTime: true, scenarioGoals: true },
  })
  const config = race?.scenarioGoals?.[scenario]
  if (!config) return // no goal time set yet for this scenario

  const segs = await db
    .select()
    .from(segments)
    .where(eq(segments.raceId, raceId))
    .orderBy(asc(segments.sortOrder))

  // Load existing manual overrides before wiping
  const existingOverrides = await db
    .select()
    .from(pacePlans)
    .where(
      and(
        eq(pacePlans.raceId, raceId),
        eq(pacePlans.scenario, scenario),
        eq(pacePlans.isManualOverride, true)
      )
    )

  const overrides: Record<string, number> = {}
  for (const p of existingOverrides) {
    if (p.plannedPaceSecPerKm !== null) overrides[p.segmentId] = p.plannedPaceSecPerKm
  }

  const results = computePacePlan({
    startTime: race!.startTime,
    goalFinishSeconds: config.goalSeconds,
    segments: segs.map((s) => ({
      id: s.id,
      distanceKm: Number(s.distanceKm),
      elevGainM: s.elevGainM,
      elevLossM: s.elevLossM,
    })),
    overrides,
    elevAdjSecPerKmPer100m: config.elevAdj,
  })

  // Delete all plans for this scenario and re-insert computed results
  await db
    .delete(pacePlans)
    .where(and(eq(pacePlans.raceId, raceId), eq(pacePlans.scenario, scenario)))

  if (results.length > 0) {
    await db.insert(pacePlans).values(
      results.map((r) => ({
        segmentId: r.segmentId,
        raceId,
        scenario,
        plannedPaceSecPerKm: Math.round(r.paceSecPerKm),
        plannedDurationSec: Math.round(r.durationSec),
        projectedArrivalTime: r.projectedArrival,
        isManualOverride: overrides[r.segmentId] !== undefined,
      }))
    )
  }
}

export async function saveGoalTime(
  raceId: string,
  scenario: Scenario,
  goalSeconds: number,
  elevAdj: number
): Promise<Result> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }
  const race = await verifyOwnership(raceId, session.user.id)
  if (!race) return { error: 'Race not found' }

  const current = race.scenarioGoals ?? {}
  const updated = { ...current, [scenario]: { goalSeconds, elevAdj } }

  try {
    await db
      .update(races)
      .set({
        scenarioGoals: updated,
        goalFinishSeconds: scenario === 'base' ? goalSeconds : undefined,
      })
      .where(eq(races.id, raceId))
    await recomputeAndStore(raceId, scenario)
    return { ok: true }
  } catch {
    return { error: 'Failed to save goal time' }
  }
}

export async function saveOverride(
  raceId: string,
  segmentId: string,
  scenario: Scenario,
  paceSecPerKm: number
): Promise<Result> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }
  if (!(await verifyOwnership(raceId, session.user.id))) return { error: 'Race not found' }

  try {
    // Upsert override (delete + insert to avoid unique constraint issues)
    await db
      .delete(pacePlans)
      .where(
        and(
          eq(pacePlans.segmentId, segmentId),
          eq(pacePlans.raceId, raceId),
          eq(pacePlans.scenario, scenario)
        )
      )
    await db.insert(pacePlans).values({
      segmentId,
      raceId,
      scenario,
      plannedPaceSecPerKm: Math.round(paceSecPerKm),
      plannedDurationSec: 0,
      isManualOverride: true,
    })
    await recomputeAndStore(raceId, scenario)
    return { ok: true }
  } catch {
    return { error: 'Failed to save override' }
  }
}

export async function clearOverride(
  raceId: string,
  segmentId: string,
  scenario: Scenario
): Promise<Result> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }
  if (!(await verifyOwnership(raceId, session.user.id))) return { error: 'Race not found' }

  try {
    await db
      .delete(pacePlans)
      .where(
        and(
          eq(pacePlans.segmentId, segmentId),
          eq(pacePlans.raceId, raceId),
          eq(pacePlans.scenario, scenario),
          eq(pacePlans.isManualOverride, true)
        )
      )
    await recomputeAndStore(raceId, scenario)
    return { ok: true }
  } catch {
    return { error: 'Failed to clear override' }
  }
}

export async function setActiveScenario(
  raceId: string,
  scenario: Scenario
): Promise<Result> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }
  const race = await verifyOwnership(raceId, session.user.id)
  if (!race) return { error: 'Race not found' }

  const goalSeconds = race.scenarioGoals?.[scenario]?.goalSeconds ?? null
  try {
    await db
      .update(races)
      .set({ activeScenario: scenario, goalFinishSeconds: goalSeconds })
      .where(eq(races.id, raceId))
    return { ok: true }
  } catch {
    return { error: 'Failed to set active scenario' }
  }
}
