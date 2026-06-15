import type { ChecklistItem } from '@/actions/checklists'

type Station = { name: string; distanceKm: string; crewAccess: boolean }

type Props = {
  station: Station
  runnerTasks: ChecklistItem[]
  crewTasks: ChecklistItem[]
  mentalAnchor: string
}

function sorted(items: ChecklistItem[]) {
  return [...items].sort((a, b) => a.order - b.order)
}

export function StationCardPreview({ station, runnerTasks, crewTasks, mentalAnchor }: Props) {
  const rTasks = sorted(runnerTasks)
  const cTasks = sorted(crewTasks)

  return (
    <div className="rounded-xl border-2 border-primary/50 bg-card p-5 max-w-sm space-y-4 shadow-sm">
      <div className="border-b pb-3 text-center">
        <h3 className="text-lg font-bold">{station.name}</h3>
        <p className="text-xs text-muted-foreground mt-0.5">
          {parseFloat(station.distanceKm).toFixed(1)} km
        </p>
      </div>

      {rTasks.length > 0 && (
        <div className="space-y-1.5">
          <p className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
            Runner
          </p>
          <ul className="space-y-1.5">
            {rTasks.map((t) => (
              <li key={t.id} className="flex items-start gap-2 text-sm">
                <span className="mt-0.5 h-4 w-4 shrink-0 rounded-full border-2 border-foreground/40" />
                {t.text}
              </li>
            ))}
          </ul>
        </div>
      )}

      {station.crewAccess && cTasks.length > 0 && (
        <div className="space-y-1.5">
          <p className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
            Crew
          </p>
          <ul className="space-y-1.5">
            {cTasks.map((t) => (
              <li key={t.id} className="flex items-start gap-2 text-sm">
                <span className="mt-0.5 h-4 w-4 shrink-0 rounded border-2 border-foreground/40" />
                {t.text}
              </li>
            ))}
          </ul>
        </div>
      )}

      {mentalAnchor && (
        <div className="rounded-md bg-muted/60 px-3 py-2">
          <p className="text-sm italic text-muted-foreground">"{mentalAnchor}"</p>
        </div>
      )}

      {rTasks.length === 0 && (!station.crewAccess || cTasks.length === 0) && !mentalAnchor && (
        <p className="text-sm text-muted-foreground text-center py-2">No checklist items yet.</p>
      )}
    </div>
  )
}
