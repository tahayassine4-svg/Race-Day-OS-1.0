'use server'

import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { crewAssignments, crewMembers, races } from '@/lib/db/schema'
import { and, eq } from 'drizzle-orm'

type Result = { ok: true } | { error: string }

async function verifyRaceOwnership(raceId: string, userId: string) {
  return db.query.races.findFirst({
    where: and(eq(races.id, raceId), eq(races.userId, userId)),
    columns: { id: true },
  })
}

export async function addCrewMember(
  raceId: string,
  data: { name: string; phone: string }
): Promise<Result> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }
  if (!(await verifyRaceOwnership(raceId, session.user.id))) return { error: 'Race not found' }
  if (!data.name.trim()) return { error: 'Name is required' }

  try {
    await db.insert(crewMembers).values({
      raceId,
      name: data.name.trim(),
      phone: data.phone.trim() || null,
    })
    return { ok: true }
  } catch {
    return { error: 'Failed to add crew member' }
  }
}

export async function updateCrewMember(
  memberId: string,
  raceId: string,
  data: { name: string; phone: string }
): Promise<Result> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }
  if (!(await verifyRaceOwnership(raceId, session.user.id))) return { error: 'Race not found' }
  if (!data.name.trim()) return { error: 'Name is required' }

  try {
    await db
      .update(crewMembers)
      .set({ name: data.name.trim(), phone: data.phone.trim() || null })
      .where(and(eq(crewMembers.id, memberId), eq(crewMembers.raceId, raceId)))
    return { ok: true }
  } catch {
    return { error: 'Failed to update crew member' }
  }
}

export async function deleteCrewMember(
  memberId: string,
  raceId: string
): Promise<Result> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }
  if (!(await verifyRaceOwnership(raceId, session.user.id))) return { error: 'Race not found' }

  try {
    await db
      .delete(crewMembers)
      .where(and(eq(crewMembers.id, memberId), eq(crewMembers.raceId, raceId)))
    return { ok: true }
  } catch {
    return { error: 'Failed to delete crew member' }
  }
}

export async function saveAssignment(
  raceId: string,
  stationId: string,
  memberId: string,
  role: string | null
): Promise<Result> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }
  if (!(await verifyRaceOwnership(raceId, session.user.id))) return { error: 'Race not found' }

  // Check member belongs to this race
  const member = await db.query.crewMembers.findFirst({
    where: and(eq(crewMembers.id, memberId), eq(crewMembers.raceId, raceId)),
    columns: { id: true },
  })
  if (!member) return { error: 'Crew member not found' }

  // Prevent duplicate assignment
  const existing = await db.query.crewAssignments.findFirst({
    where: and(eq(crewAssignments.crewMemberId, memberId), eq(crewAssignments.stationId, stationId)),
    columns: { id: true },
  })
  if (existing) return { error: 'Already assigned to this station' }

  try {
    await db.insert(crewAssignments).values({ crewMemberId: memberId, stationId, role })
    return { ok: true }
  } catch {
    return { error: 'Failed to save assignment' }
  }
}

export async function removeAssignment(
  assignmentId: string,
  raceId: string
): Promise<Result> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }
  if (!(await verifyRaceOwnership(raceId, session.user.id))) return { error: 'Race not found' }

  try {
    const assignment = await db.query.crewAssignments.findFirst({
      where: eq(crewAssignments.id, assignmentId),
      with: { crewMember: { columns: { raceId: true } } },
    })
    if (!assignment || assignment.crewMember.raceId !== raceId) {
      return { error: 'Assignment not found' }
    }
    await db.delete(crewAssignments).where(eq(crewAssignments.id, assignmentId))
    return { ok: true }
  } catch {
    return { error: 'Failed to remove assignment' }
  }
}
