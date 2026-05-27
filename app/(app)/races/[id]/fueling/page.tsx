import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { fuelPlans, pacePlans, races, segments } from '@/lib/db/schema'
import { and, asc, eq } from 'drizzle-orm'
import { notFound } from 'next/navigation'
import { computeFuelPlan } from '@/lib/fueling'
import { GlobalTargetsForm } from '@/components/fueling/global-targets-form'
import { FuelingTable, type FuelRow } from '@/components/fueling/fueling-table'
import { FuelSummary } from '@/components/fueling/fuel-summary'

export default async function FuelingPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id: raceId } = await params
  const session = await auth()

  const race = await db.query.races.findFirst({
    where: and(eq(races.id, raceId), eq(races.userId, session!.user.id)),
    columns: {
      id: true,
      activeScenario: true,
      fuelCalPerHour: true,
      fuelFluidMlPerHour: true,
      fuelSodiumMgPerHour: true,
    },
  })
  if (!race) notFound()

  const globalCal = race.fuelCalPerHour ?? 250
  const globalFluid = race.fuelFluidMlPerHour ?? 500
  const globalSodium = race.fuelSodiumMgPerHour ?? 500

  const [segmentRows, pacingRows, fuelRows] = await Promise.all([
    db.query.segments.findMany({
      where: eq(segments.raceId, raceId),
      orderBy: (s, { asc }) => [asc(s.sortOrder)],
      with: {
        fromStation: { columns: { name: true } },
        toStation: { columns: { name: true } },
      },
    }),
    db
      .select({ segmentId: pacePlans.segmentId, durationSec: pacePlans.plannedDurationSec })
      .from(pacePlans)
      .where(and(eq(pacePlans.raceId, raceId), eq(pacePlans.scenario, race.activeScenario))),
    db.select().from(fuelPlans).where(eq(fuelPlans.raceId, raceId)),
  ])

  if (segmentRows.length === 0) {
    return (
      <div className="space-y-6">
        <GlobalTargetsForm raceId={raceId} defaults={{ cal: globalCal, fluid: globalFluid, sodium: globalSodium }} />
        <div className="rounded-lg border border-dashed p-8 text-center space-y-3">
          <p className="text-sm text-muted-foreground">
            Per-segment fuel totals will appear here once you add aid stations.
          </p>
          <a
            href={`/races/${raceId}/setup`}
            className="inline-flex items-center gap-1.5 rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
          >
            Add aid stations →
          </a>
        </div>
      </div>
    )
  }

  if (pacingRows.length === 0) {
    return (
      <div className="space-y-6">
        <GlobalTargetsForm raceId={raceId} defaults={{ cal: globalCal, fluid: globalFluid, sodium: globalSodium }} />
        <div className="rounded-lg border border-dashed p-8 text-center space-y-3">
          <p className="text-sm text-muted-foreground">
            Set your goal time to see per-segment fuel calculations.
          </p>
          <a
            href={`/races/${raceId}/pacing`}
            className="inline-flex items-center gap-1.5 rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
          >
            Set goal time →
          </a>
        </div>
      </div>
    )
  }

  const pacingBySegment = Object.fromEntries(
    pacingRows.map((p) => [p.segmentId, p.durationSec ?? 0])
  )
  const fuelBySegment = Object.fromEntries(fuelRows.map((f) => [f.segmentId, f]))

  // Build overrides for the engine
  const overrides: Record<string, { cal?: number; fluid?: number; sodium?: number }> = {}
  for (const f of fuelRows) {
    if (f.isManualOverride) {
      overrides[f.segmentId] = {
        cal: f.targetCalPerHour ?? undefined,
        fluid: f.targetFluidMlPerHour ?? undefined,
        sodium: f.targetSodiumMgPerHour ?? undefined,
      }
    }
  }

  // Run engine on segments that have a pacing duration
  const orderedForEngine = segmentRows
    .filter((s) => pacingBySegment[s.id] !== undefined)
    .map((s) => ({ id: s.id, durationSec: pacingBySegment[s.id] }))

  const results = computeFuelPlan({ globalCal, globalFluid, globalSodium, segments: orderedForEngine, overrides })
  const resultMap = Object.fromEntries(results.map((r) => [r.segmentId, r]))

  const tableRows: FuelRow[] = segmentRows
    .filter((s) => resultMap[s.id])
    .map((s) => {
      const r = resultMap[s.id]
      return {
        segmentId: s.id,
        fromName: s.fromStation?.name ?? 'Start',
        toName: s.toStation.name,
        durationSec: pacingBySegment[s.id] ?? 0,
        calPerH: r.calPerH,
        fluidPerH: r.fluidPerH,
        sodiumPerH: r.sodiumPerH,
        calories: r.calories,
        fluid: r.fluid,
        sodium: r.sodium,
        cumulativeCal: r.cumulativeCal,
        cumulativeFluid: r.cumulativeFluid,
        cumulativeSodium: r.cumulativeSodium,
        itemNotes: fuelBySegment[s.id]?.itemNotes ?? null,
        isManualOverride: fuelBySegment[s.id]?.isManualOverride ?? false,
      }
    })

  const lastResult = results[results.length - 1]

  return (
    <div className="space-y-6">
      <GlobalTargetsForm
        raceId={raceId}
        defaults={{ cal: globalCal, fluid: globalFluid, sodium: globalSodium }}
      />
      <FuelingTable raceId={raceId} rows={tableRows} />
      {lastResult && (
        <FuelSummary
          totalCal={lastResult.cumulativeCal}
          totalFluid={lastResult.cumulativeFluid}
          totalSodium={lastResult.cumulativeSodium}
        />
      )}
    </div>
  )
}
