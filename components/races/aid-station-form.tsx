'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import type { StationData } from '@/actions/aid-stations'

type StationInitial = StationData & { id?: string }

type Props = {
  initial?: StationInitial
  onSubmit: (data: StationData) => Promise<void>
  onCancel: () => void
  loading: boolean
}

const SERVICES_OPTIONS = [
  { value: 'full', label: 'Full aid' },
  { value: 'water', label: 'Water only' },
  { value: 'medical', label: 'Medical' },
]

export function AidStationForm({ initial, onSubmit, onCancel, loading }: Props) {
  const [unit, setUnit] = useState<'km' | 'mi'>('km')

  const displayDist = initial?.distanceKm
    ? unit === 'mi'
      ? String((parseFloat(initial.distanceKm) / 1.60934).toFixed(2))
      : initial.distanceKm
    : ''

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const fd = new FormData(e.currentTarget)
    const rawDist = fd.get('distanceKm') as string
    const distKm =
      unit === 'mi' ? String(parseFloat(rawDist) * 1.60934) : rawDist

    await onSubmit({
      name: fd.get('name') as string,
      distanceKm: distKm,
      crewAccess: fd.get('crewAccess') === 'on',
      pacerAccess: fd.get('pacerAccess') === 'on',
      dropBag: fd.get('dropBag') === 'on',
      services: fd.get('services') as string,
    })
  }

  return (
    <form onSubmit={handleSubmit} className="rounded-lg border bg-card p-4 space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div className="space-y-1.5">
          <Label htmlFor="station-name">Station name *</Label>
          <Input
            id="station-name"
            name="name"
            required
            defaultValue={initial?.name}
            placeholder="e.g. Robinson Flat"
          />
        </div>

        <div className="space-y-1.5">
          <Label htmlFor="station-dist">Distance from start *</Label>
          <div className="flex gap-1.5">
            <Input
              id="station-dist"
              name="distanceKm"
              type="number"
              min="0"
              step="0.01"
              required
              defaultValue={displayDist}
              className="flex-1"
              placeholder="0"
            />
            <div className="flex overflow-hidden rounded-md border shrink-0">
              <button
                type="button"
                onClick={() => setUnit('km')}
                className={`px-2 py-1.5 text-xs font-medium transition-colors ${
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
                className={`px-2 py-1.5 text-xs font-medium transition-colors ${
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
      </div>

      <div className="space-y-1.5">
        <Label htmlFor="station-services">Services</Label>
        <select
          id="station-services"
          name="services"
          defaultValue={initial?.services ?? 'full'}
          className="flex h-9 w-full rounded-md border border-input bg-background px-3 py-1 text-sm shadow-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
        >
          {SERVICES_OPTIONS.map(({ value, label }) => (
            <option key={value} value={value}>
              {label}
            </option>
          ))}
        </select>
      </div>

      <div className="flex gap-6">
        <label className="flex cursor-pointer items-center gap-2 text-sm">
          <input
            type="checkbox"
            name="crewAccess"
            defaultChecked={initial?.crewAccess ?? false}
            className="rounded border-gray-300"
          />
          Crew access
        </label>
        <label className="flex cursor-pointer items-center gap-2 text-sm">
          <input
            type="checkbox"
            name="pacerAccess"
            defaultChecked={initial?.pacerAccess ?? false}
            className="rounded border-gray-300"
          />
          Pacer access
        </label>
        <label className="flex cursor-pointer items-center gap-2 text-sm">
          <input
            type="checkbox"
            name="dropBag"
            defaultChecked={initial?.dropBag ?? false}
            className="rounded border-gray-300"
          />
          Drop bag
        </label>
      </div>

      <div className="flex justify-end gap-2">
        <Button type="button" variant="outline" onClick={onCancel} disabled={loading}>
          Cancel
        </Button>
        <Button type="submit" disabled={loading}>
          {loading ? 'Saving...' : initial?.id ? 'Update station' : 'Add station'}
        </Button>
      </div>
    </form>
  )
}
