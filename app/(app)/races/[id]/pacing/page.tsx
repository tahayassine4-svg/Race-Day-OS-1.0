import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { pacePlans, races, segments } from '@/lib/db/schema'
import { and, asc, eq } from 'drizzle-orm'
import { notFound } from 'next/navigation'
import { ScenarioTabs } from '@/components/pacing/scenario-tabs'
import { GoalTimeForm } from '@/components/pacing/goal-time-form'
import { PacingTable } from '@/components/pacing/pacing-table'

type Scenario = 'optimistic' | 'base' | 'pessimistic'
const VALID_SCENARIOS: Scenario[] = ['optimistic', 'base', 'pessimistic']

export default async function PacingPage({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>
  searchParams: Promise<{ scenario?: string }>
}) {
  const { id: raceId } = await params
  const { scenario: scenarioParam } = await searchParams
  const session = await auth()

  const race = await db.query.races.findFirst({
    where: and(eq(races.id, raceId), eq(races.userId, session!.user.id)),
    columns: { id: true, startTime: true, activeScenario: true, scenarioGoals: true },
  })
  if (!race) notFound()

  const viewScenario: Scenario =
    VALID_SCENARIOS.includes(scenarioParam as Scenario)
      ? (scenarioParam as Scenario)
      : (race.activeScenario as Scenario) ?? 'base'

  if (race.activeScenario !== viewScenario) {
    // Keep DB active scenario in sync when navigating via URL param
  }

  const [segmentRows, planRows] = await Promise.all([
    db.query.segments.findMany({
      where: eq(segments.raceId, raceId),
      orderBy: (s, { asc }) => [asc(s.sortOrder)],
      with: {
        fromStation: { columns: { name: true } },
        toStation: { columns: { name: true } },
      },
    }),
    db
      .select()
      .from(pacePlans)
      .where(and(eq(pacePlans.raceId, raceId), eq(pacePlans.scenario, viewScenario))),
  ])

  if (segmentRows.length === 0) {
    return (
      <div className="rounded-lg border border-dashed p-8 text-center text-sm text-muted-foreground">
        No segments yet. Add aid stations in the{' '}
        <a href={`/races/${raceId}/setup`} className="underline">
          Setup tab
        </a>{' '}
        first.
      </div>
    )
  }

  const planBySegment = Object.fromEntries(
    planRows.map((p) => [
      p.segmentId,
      {
        plannedPaceSecPerKm: p.plannedPaceSecPerKm,
        plannedDurationSec: p.plannedDurationSec,
        projectedArrivalTime: p.projectedArrivalTime?.toISOString() ?? null,
        isManualOverride: p.isManualOverride,
      },
    ])
  )

  const scenarioConfig = race.scenarioGoals?.[viewScenario]

  return (
    <div className="space-y-6">
      <ScenarioTabs raceId={raceId} currentScenario={viewScenario} />
      <GoalTimeForm raceId={raceId} scenario={viewScenario} initial={scenarioConfig} />
      {planRows.length > 0 ? (
        <PacingTable
          raceId={raceId}
          scenario={viewScenario}
          segments={segmentRows}
          planBySegment={planBySegment}
        />
      ) : (
        <div className="rounded-lg border border-dashed p-6 text-center text-sm text-muted-foreground">
          Set your goal time above to generate a pacing plan.
        </div>
      )}
    </div>
  )
}
