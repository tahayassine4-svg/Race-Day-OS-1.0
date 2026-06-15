import { RaceForm } from '@/components/races/race-form'

export default function NewRacePage() {
  return (
    <div className="max-w-2xl space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Create a new race</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          Set up the basics — you can add aid stations and pacing plans after.
        </p>
      </div>
      <RaceForm />
    </div>
  )
}
