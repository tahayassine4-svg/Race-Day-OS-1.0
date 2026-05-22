'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { saveGlobalTargets } from '@/actions/fueling'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

type Props = {
  raceId: string
  defaults: { cal: number; fluid: number; sodium: number }
}

export function GlobalTargetsForm({ raceId, defaults }: Props) {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setLoading(true)
    setError(null)
    const fd = new FormData(e.currentTarget)
    const cal = parseInt(fd.get('cal') as string) || 0
    const fluid = parseInt(fd.get('fluid') as string) || 0
    const sodium = parseInt(fd.get('sodium') as string) || 0

    if (cal <= 0 || fluid <= 0) {
      setError('Calories and fluid targets must be greater than 0')
      setLoading(false)
      return
    }

    const result = await saveGlobalTargets(raceId, cal, fluid, sodium)
    setLoading(false)
    if ('error' in result) {
      setError(result.error)
    } else {
      router.refresh()
    }
  }

  return (
    <div className="rounded-lg border bg-card p-4 space-y-3">
      <p className="text-sm font-medium">Global fueling targets</p>
      <form onSubmit={handleSubmit}>
        <div className="flex flex-wrap items-end gap-3">
          <div className="space-y-1.5">
            <Label htmlFor="fuel-cal" className="text-xs text-muted-foreground">
              Cal/h (kcal)
            </Label>
            <Input
              id="fuel-cal"
              name="cal"
              type="number"
              min="0"
              defaultValue={defaults.cal}
              className="w-24"
              placeholder="250"
            />
          </div>
          <div className="space-y-1.5">
            <Label htmlFor="fuel-fluid" className="text-xs text-muted-foreground">
              Fluid/h (ml)
            </Label>
            <Input
              id="fuel-fluid"
              name="fluid"
              type="number"
              min="0"
              defaultValue={defaults.fluid}
              className="w-24"
              placeholder="500"
            />
          </div>
          <div className="space-y-1.5">
            <Label htmlFor="fuel-sodium" className="text-xs text-muted-foreground">
              Sodium/h (mg)
            </Label>
            <Input
              id="fuel-sodium"
              name="sodium"
              type="number"
              min="0"
              defaultValue={defaults.sodium}
              className="w-24"
              placeholder="500"
            />
          </div>
          <Button type="submit" disabled={loading}>
            {loading ? 'Saving…' : 'Apply targets'}
          </Button>
        </div>
        {error && <p className="mt-2 text-sm text-red-600">{error}</p>}
      </form>
    </div>
  )
}
