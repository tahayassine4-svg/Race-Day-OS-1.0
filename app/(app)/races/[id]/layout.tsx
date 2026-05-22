import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { races } from '@/lib/db/schema'
import { and, eq } from 'drizzle-orm'
import { notFound } from 'next/navigation'
import { CalendarDays, MapPin } from 'lucide-react'
import { RaceNav } from '@/components/races/race-nav'
import { CrewLinkSection } from '@/components/races/crew-link-section'

export default async function RaceLayout({
  children,
  params,
}: {
  children: React.ReactNode
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const session = await auth()

  const race = await db.query.races.findFirst({
    where: and(eq(races.id, id), eq(races.userId, session!.user.id)),
  })
  if (!race) notFound()

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">{race.name}</h1>
        <div className="mt-1 flex flex-wrap items-center gap-4 text-sm text-muted-foreground">
          <span className="flex items-center gap-1.5">
            <CalendarDays className="h-3.5 w-3.5" />
            {new Date(race.startTime).toLocaleDateString('en-US', {
              weekday: 'long',
              year: 'numeric',
              month: 'long',
              day: 'numeric',
            })}
          </span>
          {race.location && (
            <span className="flex items-center gap-1.5">
              <MapPin className="h-3.5 w-3.5" />
              {race.location}
            </span>
          )}
          {race.distanceKm && (
            <span>{parseFloat(race.distanceKm).toFixed(1)} km</span>
          )}
        </div>
      </div>

      <div className="flex gap-8">
        <div className="w-36 shrink-0 space-y-4">
          <RaceNav raceId={id} />
          <div className="border-t pt-4">
            <CrewLinkSection raceId={id} crewToken={race.crewToken ?? null} />
          </div>
        </div>
        <main className="min-w-0 flex-1">{children}</main>
      </div>
    </div>
  )
}
