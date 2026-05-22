import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { aidStations, races, stationChecklists } from '@/lib/db/schema'
import { and, asc, eq, inArray } from 'drizzle-orm'
import { notFound } from 'next/navigation'
import { ChecklistCard } from '@/components/checklists/checklist-card'

export default async function ChecklistsPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id: raceId } = await params
  const session = await auth()

  const race = await db.query.races.findFirst({
    where: and(eq(races.id, raceId), eq(races.userId, session!.user.id)),
    columns: { id: true },
  })
  if (!race) notFound()

  const stationRows = await db
    .select()
    .from(aidStations)
    .where(eq(aidStations.raceId, raceId))
    .orderBy(asc(aidStations.distanceKm))

  if (stationRows.length === 0) {
    return (
      <div className="rounded-lg border border-dashed p-8 text-center text-sm text-muted-foreground">
        No aid stations yet. Add stations in the{' '}
        <a href={`/races/${raceId}/setup`} className="underline">
          Setup tab
        </a>{' '}
        first.
      </div>
    )
  }

  const stationIds = stationRows.map((s) => s.id)
  const checklistRows = await db
    .select()
    .from(stationChecklists)
    .where(inArray(stationChecklists.stationId, stationIds))

  const checklistByStation = Object.fromEntries(
    checklistRows.map((c) => [c.stationId, c])
  )

  return (
    <div className="space-y-4">
      <p className="text-sm text-muted-foreground">
        One card per aid station. Click <strong>Save</strong> on each card to persist changes.
      </p>
      {stationRows.map((station) => {
        const checklist = checklistByStation[station.id]
        return (
          <ChecklistCard
            key={station.id}
            station={{
              id: station.id,
              name: station.name,
              distanceKm: station.distanceKm,
              crewAccess: station.crewAccess,
            }}
            initialRunnerTasks={checklist?.runnerTasks ?? []}
            initialCrewTasks={checklist?.crewTasks ?? []}
            initialMentalAnchor={checklist?.mentalAnchor ?? null}
          />
        )
      })}
    </div>
  )
}
