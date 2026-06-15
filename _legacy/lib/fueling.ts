export type FuelingSegment = {
  id: string
  durationSec: number
}

export type FuelingOverride = {
  cal?: number   // kcal/h
  fluid?: number // ml/h
  sodium?: number // mg/h
}

export type FuelingInput = {
  globalCal: number
  globalFluid: number
  globalSodium: number
  segments: FuelingSegment[]
  overrides: Record<string, FuelingOverride>
}

export type SegmentFuelResult = {
  segmentId: string
  calPerH: number
  fluidPerH: number
  sodiumPerH: number
  calories: number
  fluid: number
  sodium: number
  cumulativeCal: number
  cumulativeFluid: number
  cumulativeSodium: number
}

/**
 * Pure fueling engine. Computes per-segment fuel requirements from planned
 * durations and per-hour targets. Overrides apply only to the specified segment.
 */
export function computeFuelPlan(input: FuelingInput): SegmentFuelResult[] {
  let cumCal = 0
  let cumFluid = 0
  let cumSodium = 0

  return input.segments.map((seg) => {
    const override = input.overrides[seg.id] ?? {}
    const durationH = seg.durationSec / 3600

    const calPerH = override.cal ?? input.globalCal
    const fluidPerH = override.fluid ?? input.globalFluid
    const sodiumPerH = override.sodium ?? input.globalSodium

    const calories = Math.round(calPerH * durationH)
    const fluid = Math.round(fluidPerH * durationH)
    const sodium = Math.round(sodiumPerH * durationH)

    cumCal += calories
    cumFluid += fluid
    cumSodium += sodium

    return {
      segmentId: seg.id,
      calPerH,
      fluidPerH,
      sodiumPerH,
      calories,
      fluid,
      sodium,
      cumulativeCal: cumCal,
      cumulativeFluid: cumFluid,
      cumulativeSodium: cumSodium,
    }
  })
}
