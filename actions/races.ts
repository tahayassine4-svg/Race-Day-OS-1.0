'use server'

import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { races } from '@/lib/db/schema'
import { redirect } from 'next/navigation'

export type CreateRaceData = {
  name: string
  startTime: string
  cutoffTime?: string
  distanceKm?: string
  elevationGainM?: string
  location?: string
  raceGuideUrl?: string
}

export async function createRace(data: CreateRaceData): Promise<{ error: string } | void> {
  const session = await auth()
  if (!session?.user?.id) return { error: 'Not authenticated' }
  if (!data.name.trim()) return { error: 'Race name is required' }
  if (!data.startTime) return { error: 'Start date/time is required' }

  let raceId: string
  try {
    const [race] = await db
      .insert(races)
      .values({
        userId: session.user.id,
        name: data.name.trim(),
        startTime: new Date(data.startTime),
        cutoffTime: data.cutoffTime ? new Date(data.cutoffTime) : null,
        distanceKm: data.distanceKm || null,
        elevationGainM: data.elevationGainM ? parseInt(data.elevationGainM) : null,
        location: data.location?.trim() || null,
        raceGuideUrl: data.raceGuideUrl?.trim() || null,
      })
      .returning({ id: races.id })
    raceId = race.id
  } catch {
    return { error: 'Failed to create race. Please try again.' }
  }

  redirect(`/races/${raceId}/import`)
}
