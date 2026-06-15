'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { setActiveScenario } from '@/actions/pacing'
import { cn } from '@/lib/utils'

const SCENARIOS = [
  { key: 'optimistic' as const, label: 'Optimistic' },
  { key: 'base' as const, label: 'Base' },
  { key: 'pessimistic' as const, label: 'Pessimistic' },
]

type Scenario = 'optimistic' | 'base' | 'pessimistic'

export function ScenarioTabs({
  raceId,
  currentScenario,
}: {
  raceId: string
  currentScenario: Scenario
}) {
  const router = useRouter()
  const [loading, setLoading] = useState(false)

  const handleSwitch = async (scenario: Scenario) => {
    if (scenario === currentScenario || loading) return
    setLoading(true)
    await setActiveScenario(raceId, scenario)
    router.push(`/races/${raceId}/pacing?scenario=${scenario}`)
    setLoading(false)
  }

  return (
    <div className="space-y-1">
      <p className="text-xs text-muted-foreground font-medium uppercase tracking-wide">
        Scenario
      </p>
      <div className="flex gap-1 rounded-lg border p-1 w-fit bg-muted/30">
        {SCENARIOS.map(({ key, label }) => (
          <button
            key={key}
            onClick={() => handleSwitch(key)}
            disabled={loading}
            className={cn(
              'rounded-md px-4 py-1.5 text-sm font-medium transition-colors',
              currentScenario === key
                ? 'bg-primary text-primary-foreground shadow-sm'
                : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground'
            )}
          >
            {label}
          </button>
        ))}
      </div>
    </div>
  )
}
