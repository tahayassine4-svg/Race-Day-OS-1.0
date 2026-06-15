'use client'

import { useState } from 'react'
import { saveChecklist, type ChecklistItem } from '@/actions/checklists'
import { TaskList } from './task-list'
import { StationCardPreview } from './station-card-preview'
import { Button } from '@/components/ui/button'

type Station = { id: string; name: string; distanceKm: string; crewAccess: boolean }

type Props = {
  station: Station
  initialRunnerTasks: ChecklistItem[]
  initialCrewTasks: ChecklistItem[]
  initialMentalAnchor: string | null
}

export function ChecklistCard({ station, initialRunnerTasks, initialCrewTasks, initialMentalAnchor }: Props) {
  const [runnerTasks, setRunnerTasks] = useState<ChecklistItem[]>(initialRunnerTasks)
  const [crewTasks, setCrewTasks] = useState<ChecklistItem[]>(initialCrewTasks)
  const [mentalAnchor, setMentalAnchor] = useState(initialMentalAnchor ?? '')
  const [showPreview, setShowPreview] = useState(false)
  const [saving, setSaving] = useState(false)
  const [saved, setSaved] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleSave = async () => {
    setSaving(true); setError(null); setSaved(false)
    const result = await saveChecklist(station.id, {
      runnerTasks,
      crewTasks,
      mentalAnchor: mentalAnchor.trim() || null,
    })
    setSaving(false)
    if ('error' in result) { setError(result.error); return }
    setSaved(true)
    setTimeout(() => setSaved(false), 2000)
  }

  return (
    <div className="rounded-lg border">
      <div className="flex items-center justify-between px-4 py-3 border-b">
        <div>
          <span className="font-medium">{station.name}</span>
          <span className="ml-2 text-xs text-muted-foreground">
            {parseFloat(station.distanceKm).toFixed(1)} km
            {station.crewAccess && <span className="ml-1 text-blue-600">· Crew</span>}
          </span>
        </div>
        <div className="flex items-center gap-2">
          {error && <span className="text-xs text-red-600">{error}</span>}
          {saved && <span className="text-xs text-green-600">Saved ✓</span>}
          <Button
            variant="outline"
            size="sm"
            className="h-7 text-xs"
            onClick={() => setShowPreview((v) => !v)}
          >
            {showPreview ? 'Edit' : 'Preview'}
          </Button>
          {!showPreview && (
            <Button size="sm" className="h-7 text-xs" onClick={handleSave} disabled={saving}>
              {saving ? 'Saving…' : 'Save'}
            </Button>
          )}
        </div>
      </div>

      {showPreview ? (
        <div className="p-4 flex justify-center">
          <StationCardPreview
            station={station}
            runnerTasks={runnerTasks}
            crewTasks={crewTasks}
            mentalAnchor={mentalAnchor}
          />
        </div>
      ) : (
        <div className="p-4 space-y-5">
          <div className="space-y-2">
            <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
              Runner tasks
            </p>
            <TaskList
              items={runnerTasks}
              onChange={setRunnerTasks}
              placeholder="Refill bottles, take salt tab…"
            />
          </div>

          {station.crewAccess && (
            <div className="space-y-2">
              <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
                Crew tasks
              </p>
              <TaskList
                items={crewTasks}
                onChange={setCrewTasks}
                placeholder="Prepare bottles, check blisters…"
              />
            </div>
          )}

          <div className="space-y-2">
            <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
              Mental anchor (optional)
            </p>
            <textarea
              value={mentalAnchor}
              onChange={(e) => setMentalAnchor(e.target.value)}
              placeholder="A note to your future self at this station…"
              rows={2}
              className="w-full resize-none rounded-md border border-input bg-background px-3 py-2 text-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
            />
          </div>
        </div>
      )}
    </div>
  )
}
