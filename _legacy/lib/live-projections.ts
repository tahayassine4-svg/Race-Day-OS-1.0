export type ProjectionSegment = {
  id: string
  toStationId: string
  distanceKm: number
  plannedPaceSecPerKm: number
}

export type StationArrival = {
  stationId: string
  actualArrival: Date
}

export type ProjectionResult = {
  stationId: string
  projectedArrival: Date
  isActual: boolean
}

/**
 * Pure live projection engine. Replaces planned projections with actual
 * arrivals where logged, and blends actual pace trend with plan for
 * remaining segments.
 *
 * @param blendWeight - 0-1, weight of actual trend (default 0.8 = 80% actual)
 */
export function recomputeProjections({
  startTime,
  segments,
  arrivals,
  blendWeight = 0.8,
}: {
  startTime: Date
  segments: ProjectionSegment[]
  arrivals: StationArrival[]
  blendWeight?: number
}): ProjectionResult[] {
  const arrivalMap = new Map(arrivals.map((a) => [a.stationId, a.actualArrival]))

  // Compute actual paces from completed segments (stop at first gap)
  const actualPaces: number[] = []
  let prevTime = startTime
  for (const seg of segments) {
    const actual = arrivalMap.get(seg.toStationId)
    if (!actual) break
    const durSec = (actual.getTime() - prevTime.getTime()) / 1000
    if (durSec > 0) actualPaces.push(durSec / seg.distanceKm)
    prevTime = actual
  }

  const trendPace =
    actualPaces.length > 0
      ? actualPaces.reduce((s, p) => s + p, 0) / actualPaces.length
      : 0

  // Build projected results for all segments
  let currentTime = startTime
  return segments.map((seg) => {
    const actual = arrivalMap.get(seg.toStationId)
    if (actual) {
      currentTime = actual
      return { stationId: seg.toStationId, projectedArrival: actual, isActual: true }
    }

    const planPace = seg.plannedPaceSecPerKm > 0 ? seg.plannedPaceSecPerKm : trendPace
    const blendedPace =
      trendPace > 0
        ? blendWeight * trendPace + (1 - blendWeight) * planPace
        : planPace

    const projected = new Date(
      currentTime.getTime() + Math.max(blendedPace, 60) * seg.distanceKm * 1000
    )
    currentTime = projected
    return { stationId: seg.toStationId, projectedArrival: projected, isActual: false }
  })
}

// ── Helpers ───────────────────────────────────────────────────────────────────

export type ArrivalStatus = 'ahead' | 'on-pace' | 'behind'

export function getArrivalStatus(
  projected: Date,
  actual: Date
): ArrivalStatus {
  const diffMin = (actual.getTime() - projected.getTime()) / 60000
  if (diffMin < -5) return 'ahead'
  if (diffMin > 5) return 'behind'
  return 'on-pace'
}

export const STATUS_STYLES: Record<ArrivalStatus, string> = {
  ahead: 'bg-green-100 text-green-800',
  'on-pace': 'bg-yellow-100 text-yellow-800',
  behind: 'bg-red-100 text-red-800',
}

export const STATUS_LABELS: Record<ArrivalStatus, string> = {
  ahead: 'Ahead',
  'on-pace': 'On Pace',
  behind: 'Behind',
}
