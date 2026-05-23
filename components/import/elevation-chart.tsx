'use client'

import {
  ComposedChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ReferenceLine,
  ResponsiveContainer,
} from 'recharts'
import type { TrackPoint } from '@/lib/gpx-parser'
import type { DraftStation } from '@/lib/types/import'

type Props = {
  trackPoints: TrackPoint[]
  stations: DraftStation[]
  selectedId: string | null
  onStationClick: (index: number) => void
}

type ChartPayload = {
  activePayload?: Array<{ payload: TrackPoint }>
}

function TooltipContent({ active, payload }: { active?: boolean; payload?: Array<{ payload: TrackPoint }> }) {
  if (!active || !payload?.length) return null
  const pt = payload[0].payload
  return (
    <div className="rounded border bg-background px-2 py-1.5 text-xs shadow">
      <p className="font-medium">{pt.cumKm.toFixed(1)} km</p>
      <p className="text-muted-foreground">{Math.round(pt.ele)} m</p>
    </div>
  )
}

export function ElevationChart({ trackPoints, stations, selectedId, onStationClick }: Props) {
  const handleClick = (data: ChartPayload) => {
    if (!data?.activePayload?.length) return
    const clickedKm = data.activePayload[0].payload.cumKm
    let nearestIdx = -1
    let minDist = 5 // only select if within 5 km
    stations.forEach((s, i) => {
      const d = Math.abs(s.distanceKm - clickedKm)
      if (d < minDist) { minDist = d; nearestIdx = i }
    })
    if (nearestIdx >= 0) onStationClick(nearestIdx)
  }

  return (
    <div className="rounded-lg border bg-card p-4">
      <p className="mb-3 text-xs text-muted-foreground">
        Elevation profile — click near a station marker to select it
      </p>
      <ResponsiveContainer width="100%" height={240}>
        <ComposedChart
          data={trackPoints}
          margin={{ top: 4, right: 8, bottom: 0, left: 0 }}
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          onClick={handleClick as any}
          style={{ cursor: 'crosshair' }}
        >
          <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" opacity={0.4} />
          <XAxis
            dataKey="cumKm"
            type="number"
            domain={[0, 'auto']}
            tickFormatter={(v: number) => `${v.toFixed(0)} km`}
            tick={{ fontSize: 10 }}
            tickCount={6}
          />
          <YAxis
            tickFormatter={(v: number) => `${v} m`}
            tick={{ fontSize: 10 }}
            width={48}
          />
          <Tooltip content={<TooltipContent />} />
          <Area
            type="monotone"
            dataKey="ele"
            fill="hsl(var(--primary))"
            fillOpacity={0.12}
            stroke="hsl(var(--primary))"
            strokeWidth={1.5}
            dot={false}
            activeDot={{ r: 3 }}
            isAnimationActive={false}
          />
          {stations.map((s, i) => (
            <ReferenceLine
              key={s.id}
              x={s.distanceKm}
              stroke={
                s.id === selectedId
                  ? 'hsl(var(--primary))'
                  : s.crewAccess
                  ? '#f97316'
                  : '#94a3b8'
              }
              strokeWidth={s.id === selectedId ? 2 : 1.5}
              strokeDasharray={s.id === selectedId ? undefined : '4 2'}
              label={{
                value: s.name.length > 10 ? s.name.slice(0, 10) + '…' : s.name,
                angle: -90,
                position: i % 2 === 0 ? 'insideTopLeft' : 'insideTopRight',
                fontSize: 9,
                fill: s.id === selectedId ? 'hsl(var(--primary))' : '#64748b',
              }}
            />
          ))}
        </ComposedChart>
      </ResponsiveContainer>
      <div className="mt-2 flex gap-4 text-xs text-muted-foreground">
        <span className="flex items-center gap-1">
          <span className="inline-block h-3 w-0.5 bg-orange-400" />
          Crew access
        </span>
        <span className="flex items-center gap-1">
          <span className="inline-block h-3 w-0.5 bg-slate-400" />
          No crew access
        </span>
        <span className="flex items-center gap-1">
          <span className="inline-block h-3 w-0.5 bg-primary" />
          Selected
        </span>
      </div>
    </div>
  )
}
