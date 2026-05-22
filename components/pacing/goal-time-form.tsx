'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { saveGoalTime } from '@/actions/pacing'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

type Props = {
  raceId: string
  scenario: 'optimistic' | 'base' | 'pessimistic'
  initial?: { goalSeconds: number; elevAdj: number }
}

export function GoalTimeForm({ raceId, scenario, initial }: Props) {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const initHours = initial ? Math.floor(initial.goalSeconds / 3600) : ''
  const initMinutes = initial ? Math.floor((initial.goalSeconds % 3600) / 60) : ''

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setLoading(true)
    setError(null)
    const fd = new FormData(e.currentTarget)
    const hours = parseInt(fd.get('hours') as string) || 0
    const minutes = parseInt(fd.get('minutes') as string) || 0
    const goalSeconds = hours * 3600 + minutes * 60
    const elevAdj = parseInt(fd.get('elevAdj') as string) || 0

    if (goalSeconds <= 0) {
      setError('Goal time must be greater than 0')
      setLoading(false)
      return
    }

    const result = await saveGoalTime(raceId, scenario, goalSeconds, elevAdj)
    setLoading(false)
    if ('error' in result) {
      setError(result.error)
    } else {
      router.refresh()
    }
  }

  return (
    <div className="rounded-lg border bg-card p-4 space-y-3">
      <p className="text-sm font-medium">Goal time</p>
      <form onSubmit={handleSubmit}>
        <div className="flex flex-wrap items-end gap-3">
          <div className="space-y-1.5">
            <Label htmlFor="goal-h" className="text-xs text-muted-foreground">
              Hours
            </Label>
            <Input
              id="goal-h"
              name="hours"
              type="number"
              min="0"
              max="99"
              defaultValue={initHours}
              className="w-20"
              placeholder="24"
            />
          </div>
          <div className="space-y-1.5">
            <Label htmlFor="goal-m" className="text-xs text-muted-foreground">
              Minutes
            </Label>
            <Input
              id="goal-m"
              name="minutes"
              type="number"
              min="0"
              max="59"
              defaultValue={initMinutes}
              className="w-20"
              placeholder="0"
            />
          </div>
          <div className="space-y-1.5">
            <Label htmlFor="elev-adj" className="text-xs text-muted-foreground">
              Elev adj (sec/km per 100m ↑)
            </Label>
            <Input
              id="elev-adj"
              name="elevAdj"
              type="number"
              min="0"
              defaultValue={initial?.elevAdj ?? 0}
              className="w-28"
              placeholder="0"
            />
          </div>
          <Button type="submit" disabled={loading}>
            {loading ? 'Calculating…' : initial ? 'Recalculate' : 'Generate plan'}
          </Button>
        </div>
        {error && <p className="mt-2 text-sm text-red-600">{error}</p>}
      </form>
    </div>
  )
}
