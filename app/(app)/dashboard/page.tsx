import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { races } from '@/lib/db/schema'
import { eq } from 'drizzle-orm'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { CalendarDays, MapPin, Plus } from 'lucide-react'

export default async function DashboardPage() {
  const session = await auth()
  const userRaces = await db.query.races.findMany({
    where: eq(races.userId, session!.user.id),
    orderBy: (races, { desc }) => [desc(races.createdAt)],
    with: { aidStations: { columns: { id: true } } },
  })

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">My Races</h1>
          <p className="text-muted-foreground text-sm mt-1">
            Plan and coordinate your ultra races
          </p>
        </div>
        <Button asChild>
          <Link href="/races/new">
            <Plus className="h-4 w-4 mr-2" />
            New Race
          </Link>
        </Button>
      </div>

      {userRaces.length === 0 ? (
        <div className="flex flex-col items-center justify-center rounded-lg border border-dashed p-12 text-center">
          <h3 className="text-lg font-semibold">No races yet</h3>
          <p className="text-muted-foreground text-sm mt-2 max-w-sm">
            Create your first race to start building your crew plan, pacing strategy, and race-day OS.
          </p>
          <Button className="mt-6" asChild>
            <Link href="/races/new">
              <Plus className="h-4 w-4 mr-2" />
              Create your first race
            </Link>
          </Button>
        </div>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {userRaces.map((race) => (
            <Link key={race.id} href={`/races/${race.id}`}>
              <Card className="hover:border-primary/50 transition-colors cursor-pointer h-full">
                <CardHeader>
                  <CardTitle className="text-lg">{race.name}</CardTitle>
                  <CardDescription className="flex flex-col gap-1 mt-1">
                    <span className="flex items-center gap-1.5">
                      <CalendarDays className="h-3.5 w-3.5" />
                      {new Date(race.startTime).toLocaleDateString('en-US', {
                        weekday: 'short',
                        year: 'numeric',
                        month: 'short',
                        day: 'numeric',
                      })}
                    </span>
                    {race.location && (
                      <span className="flex items-center gap-1.5">
                        <MapPin className="h-3.5 w-3.5" />
                        {race.location}
                      </span>
                    )}
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="text-sm text-muted-foreground">
                    {race.distanceKm
                      ? `${parseFloat(race.distanceKm).toFixed(1)} km`
                      : 'Distance not set'}
                    {' · '}
                    {race.aidStations.length}{' '}
                    {race.aidStations.length === 1 ? 'station' : 'stations'}
                  </div>
                </CardContent>
              </Card>
            </Link>
          ))}
        </div>
      )}
    </div>
  )
}
