export type PacingSegment = {
  id: string
  distanceKm: number
  elevGainM: number
  elevLossM: number
}

export type PacingInput = {
  startTime: Date
  goalFinishSeconds: number
  segments: PacingSegment[]
  overrides: Record<string, number> // segmentId → paceSecPerKm
  elevAdjSecPerKmPer100m: number
}

export type SegmentPaceResult = {
  segmentId: string
  paceSecPerKm: number
  durationSec: number
  projectedArrival: Date
}

/**
 * Pure pacing engine. Distributes goal finish time across segments proportional
 * to distance, with an optional grade-adjusted pace modifier for elevation gain.
 * Manual overrides consume a fixed time slice; remaining segments recalculate.
 */
export function computePacePlan(input: PacingInput): SegmentPaceResult[] {
  const { startTime, goalFinishSeconds, segments, overrides, elevAdjSecPerKmPer100m } = input

  // Fixed time consumed by overridden segments
  let fixedTimeSec = 0
  const free: PacingSegment[] = []

  for (const seg of segments) {
    if (overrides[seg.id] !== undefined) {
      fixedTimeSec += overrides[seg.id] * seg.distanceKm
    } else {
      free.push(seg)
    }
  }

  const remainingSec = goalFinishSeconds - fixedTimeSec

  // Solve for base flat pace across non-overridden segments:
  // sum((basePace + (elevGain/100)*elevAdj) * dist) = remainingSec
  // basePace * totalDist + elevAdj * sum((elevGain/100)*dist) = remainingSec
  const totalFreeDist = free.reduce((s, seg) => s + seg.distanceKm, 0)
  const elevCorrection = free.reduce(
    (s, seg) => s + (seg.elevGainM / 100) * elevAdjSecPerKmPer100m * seg.distanceKm,
    0
  )
  const basePace =
    totalFreeDist > 0
      ? Math.max(60, (remainingSec - elevCorrection) / totalFreeDist)
      : 0

  // Build results in segment order, accumulating arrival time
  let cumulativeSec = 0
  return segments.map((seg) => {
    const paceSecPerKm =
      overrides[seg.id] !== undefined
        ? overrides[seg.id]
        : basePace + (seg.elevGainM / 100) * elevAdjSecPerKmPer100m
    const durationSec = paceSecPerKm * seg.distanceKm
    cumulativeSec += durationSec
    return {
      segmentId: seg.id,
      paceSecPerKm,
      durationSec,
      projectedArrival: new Date(startTime.getTime() + cumulativeSec * 1000),
    }
  })
}

// ── Formatting helpers ────────────────────────────────────────────────────────

export function formatPace(secPerKm: number): string {
  const min = Math.floor(secPerKm / 60)
  const sec = Math.round(secPerKm % 60)
  return `${min}:${sec.toString().padStart(2, '0')}`
}

export function parsePace(str: string): number | null {
  const parts = str.split(':').map((s) => s.trim())
  if (parts.length === 1) {
    const min = parseFloat(parts[0])
    return isNaN(min) ? null : min * 60
  }
  if (parts.length === 2) {
    const min = parseInt(parts[0])
    const sec = parseInt(parts[1])
    return isNaN(min) || isNaN(sec) ? null : min * 60 + sec
  }
  return null
}

export function formatDuration(sec: number): string {
  const h = Math.floor(sec / 3600)
  const m = Math.floor((sec % 3600) / 60)
  if (h > 0) return `${h}h ${m.toString().padStart(2, '0')}m`
  return `${m}m`
}

export function formatArrivalTime(isoString: string): string {
  return new Date(isoString).toLocaleTimeString('en-US', {
    hour: 'numeric',
    minute: '2-digit',
    hour12: true,
  })
}
