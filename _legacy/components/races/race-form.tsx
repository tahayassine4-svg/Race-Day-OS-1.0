'use client'

import { useState } from 'react'
import { createRace, type CreateRaceData } from '@/actions/races'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

export function RaceForm() {
  const [unit, setUnit] = useState<'km' | 'mi'>('km')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setLoading(true)
    setError(null)

    const fd = new FormData(e.currentTarget)
    const rawDistance = fd.get('distance') as string
    let distanceKm: string | undefined
    if (rawDistance) {
      distanceKm =
        unit === 'mi' ? String(parseFloat(rawDistance) * 1.60934) : rawDistance
    }

    const data: CreateRaceData = {
      name: fd.get('name') as string,
      startTime: fd.get('startTime') as string,
      cutoffTime: (fd.get('cutoffTime') as string) || undefined,
      distanceKm,
      elevationGainM: (fd.get('elevationGainM') as string) || undefined,
      location: (fd.get('location') as string) || undefined,
      raceGuideUrl: (fd.get('raceGuideUrl') as string) || undefined,
    }

    // redirect() in createRace throws and Next.js handles the navigation
    const result = await createRace(data)
    if (result?.error) {
      setError(result.error)
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6 max-w-xl">
      {error && (
        <div className="rounded-md border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {error}
        </div>
      )}

      <div className="space-y-2">
        <Label htmlFor="name">Race name *</Label>
        <Input id="name" name="name" required placeholder="e.g. Western States 100" />
      </div>

      <div className="space-y-2">
        <Label htmlFor="startTime">Start date & time *</Label>
        <Input id="startTime" name="startTime" type="datetime-local" required />
      </div>

      <div className="space-y-2">
        <Label htmlFor="cutoffTime">Cutoff time (optional)</Label>
        <Input id="cutoffTime" name="cutoffTime" type="datetime-local" />
      </div>

      <div className="space-y-2">
        <Label htmlFor="distance">Distance (optional)</Label>
        <div className="flex gap-2">
          <Input
            id="distance"
            name="distance"
            type="number"
            min="0"
            step="0.01"
            placeholder="e.g. 161"
            className="flex-1"
          />
          <div className="flex overflow-hidden rounded-md border">
            <button
              type="button"
              onClick={() => setUnit('km')}
              className={`px-3 py-2 text-sm font-medium transition-colors ${
                unit === 'km'
                  ? 'bg-primary text-primary-foreground'
                  : 'bg-background hover:bg-accent'
              }`}
            >
              km
            </button>
            <button
              type="button"
              onClick={() => setUnit('mi')}
              className={`px-3 py-2 text-sm font-medium transition-colors ${
                unit === 'mi'
                  ? 'bg-primary text-primary-foreground'
                  : 'bg-background hover:bg-accent'
              }`}
            >
              mi
            </button>
          </div>
        </div>
      </div>

      <div className="space-y-2">
        <Label htmlFor="elevationGainM">Total elevation gain — meters (optional)</Label>
        <Input
          id="elevationGainM"
          name="elevationGainM"
          type="number"
          min="0"
          placeholder="e.g. 5500"
        />
      </div>

      <div className="space-y-2">
        <Label htmlFor="location">Location (optional)</Label>
        <Input id="location" name="location" placeholder="e.g. Squaw Valley, CA" />
      </div>

      <div className="space-y-2">
        <Label htmlFor="raceGuideUrl">Race guide URL (optional)</Label>
        <Input id="raceGuideUrl" name="raceGuideUrl" type="url" placeholder="https://..." />
      </div>

      <Button type="submit" disabled={loading} className="w-full">
        {loading ? 'Creating race...' : 'Create race'}
      </Button>
    </form>
  )
}
