import { db } from '@/lib/db'
import { aidStations, fuelPlans, pacePlans, races, segments, stationChecklists, stationEvents } from '@/lib/db/schema'
import { and, eq } from 'drizzle-orm'
import { notFound } from 'next/navigation'
import Link from 'next/link'
import { ChevronLeft, ArrowRight } from 'lucide-react'
import { StationEventForm } from '@/components/crew/station-event-form'
import { formatArrivalTime } from '@/lib/pacing'
import type { ChecklistItem } from '@/actions/checklists'

export default async function CrewStationPage({
  params,
}: {
  params: Promise<{ token: string; stationId: string }>
}) {
  const { token, stationId } = await params

  const race = await db.query.races.findFirst({
    where: eq(races.crewToken, token),
    columns: { id: true, name: true, activeScenario: true },
  })
  if (!race) notFound()

  const station = await db.query.aidStations.findFirst({
    where: and(eq(aidStations.id, stationId), eq(aidStations.raceId, race.id)),
  })
  if (!station) notFound()

  // Segment ending at this station (for pacing + fueling)
  const segment = await db.query.segments.findFirst({
    where: and(eq(segments.toStationId, stationId), eq(segments.raceId, race.id)),
  })

  const [pacingRow, fuelRow, checklistRow, eventRow] = await Promise.all([
    segment
      ? db.query.pacePlans.findFirst({
          where: and(
            eq(pacePlans.segmentId, segment.id),
            eq(pacePlans.raceId, race.id),
            eq(pacePlans.scenario, race.activeScenario)
          ),
          columns: { projectedArrivalTime: true },
        })
      : Promise.resolve(null),
    segment
      ? db.query.fuelPlans.findFirst({
          where: and(eq(fuelPlans.segmentId, segment.id), eq(fuelPlans.raceId, race.id)),
          columns: { targetCalPerHour: true, targetFluidMlPerHour: true, targetSodiumMgPerHour: true, totalCalories: true, totalFluidMl: true, totalSodiumMg: true },
        })
      : Promise.resolve(null),
    db.query.stationChecklists.findFirst({
      where: eq(stationChecklists.stationId, stationId),
    }),
    db.query.stationEvents.findFirst({
      where: and(eq(stationEvents.stationId, stationId), eq(stationEvents.raceId, race.id)),
    }),
  ])

  const sortedTasks = (items: ChecklistItem[] | null) =>
    [...(items ?? [])].sort((a, b) => a.order - b.order)

  const runnerTasks = sortedTasks(checklistRow?.runnerTasks ?? null)
  const crewTasks = sortedTasks(checklistRow?.crewTasks ?? null)

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-2">
        <Link href={`/crew/${token}`} className="flex items-center gap-1 text-sm text-muted-foreground hover:text-foreground">
          <ChevronLeft className="h-4 w-4" /> {race.name}
        </Link>
      </div>

      <div className="border-b pb-4">
        <h1 className="text-2xl font-bold">{station.name}</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          {parseFloat(station.distanceKm).toFixed(1)} km
          {station.crewAccess && <span className="ml-2 rounded bg-blue-100 px-2 py-0.5 text-xs text-blue-700">Crew access</span>}
        </p>
        {pacingRow?.projectedArrivalTime && (
          <p className="mt-2 text-sm">
            Projected arrival:{' '}
            <strong>{formatArrivalTime(pacingRow.projectedArrivalTime.toISOString())}</strong>
          </p>
        )}
      </div>

      <StationEventForm
        crewToken={token}
        stationId={stationId}
        projectedArrival={pacingRow?.projectedArrivalTime?.toISOString() ?? null}
        initialArrival={eventRow?.actualArrival?.toISOString() ?? null}
        initialDeparture={eventRow?.actualDeparture?.toISOString() ?? null}
        initialNotes={eventRow?.conditionNotes ?? null}
      />

      {runnerTasks.length > 0 && (
        <div className="space-y-2">
          <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">Runner Tasks</p>
          <ul className="space-y-2">
            {runnerTasks.map((t) => (
              <li key={t.id} className="flex items-start gap-2 text-sm">
                <span className="mt-0.5 h-4 w-4 shrink-0 rounded-full border-2 border-foreground/30" />
                {t.text}
              </li>
            ))}
          </ul>
        </div>
      )}

      {station.crewAccess && crewTasks.length > 0 && (
        <div className="space-y-2">
          <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">Crew Tasks</p>
          <ul className="space-y-2">
            {crewTasks.map((t) => (
              <li key={t.id} className="flex items-start gap-2 text-sm">
                <span className="mt-0.5 h-4 w-4 shrink-0 rounded border-2 border-foreground/30" />
                {t.text}
              </li>
            ))}
          </ul>
        </div>
      )}

      {fuelRow && (
        <div className="space-y-2">
          <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">Fueling (this segment)</p>
          <div className="grid grid-cols-3 gap-3 rounded-lg border bg-card p-3 text-center">
            <div>
              <p className="text-lg font-bold tabular-nums">{fuelRow.totalCalories ?? '—'}</p>
              <p className="text-xs text-muted-foreground">kcal</p>
            </div>
            <div>
              <p className="text-lg font-bold tabular-nums">
                {fuelRow.totalFluidMl != null
                  ? fuelRow.totalFluidMl >= 1000
                    ? `${(fuelRow.totalFluidMl / 1000).toFixed(1)}L`
                    : `${fuelRow.totalFluidMl}ml`
                  : '—'}
              </p>
              <p className="text-xs text-muted-foreground">fluid</p>
            </div>
            <div>
              <p className="text-lg font-bold tabular-nums">{fuelRow.totalSodiumMg ?? '—'}</p>
              <p className="text-xs text-muted-foreground">mg Na</p>
            </div>
          </div>
        </div>
      )}

      {checklistRow?.mentalAnchor && (
        <div className="rounded-lg bg-muted/50 px-4 py-3">
          <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground mb-1">Mental Anchor</p>
          <p className="text-sm italic">"{checklistRow.mentalAnchor}"</p>
        </div>
      )}
    </div>
  )
}
