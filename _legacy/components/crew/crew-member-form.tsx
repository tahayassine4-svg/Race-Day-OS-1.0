'use client'

import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

type Props = {
  initial?: { name: string; phone: string | null }
  onSubmit: (data: { name: string; phone: string }) => Promise<void>
  onCancel: () => void
  loading: boolean
  submitLabel?: string
}

export function CrewMemberForm({ initial, onSubmit, onCancel, loading, submitLabel }: Props) {
  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const fd = new FormData(e.currentTarget)
    await onSubmit({
      name: fd.get('name') as string,
      phone: fd.get('phone') as string,
    })
  }

  return (
    <form onSubmit={handleSubmit} className="rounded-lg border bg-card p-3 space-y-3">
      <div className="grid grid-cols-2 gap-3">
        <div className="space-y-1.5">
          <Label htmlFor="cm-name" className="text-xs">Name *</Label>
          <Input
            id="cm-name"
            name="name"
            required
            defaultValue={initial?.name}
            placeholder="Alex"
          />
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="cm-phone" className="text-xs">Phone (optional)</Label>
          <Input
            id="cm-phone"
            name="phone"
            type="tel"
            defaultValue={initial?.phone ?? ''}
            placeholder="+1 555-0100"
          />
        </div>
      </div>
      <div className="flex justify-end gap-2">
        <Button type="button" variant="outline" size="sm" onClick={onCancel} disabled={loading}>
          Cancel
        </Button>
        <Button type="submit" size="sm" disabled={loading}>
          {loading ? 'Saving…' : (submitLabel ?? 'Save')}
        </Button>
      </div>
    </form>
  )
}
