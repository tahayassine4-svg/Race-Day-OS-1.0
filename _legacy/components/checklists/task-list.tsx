'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { ChevronDown, ChevronUp, Trash2 } from 'lucide-react'
import type { ChecklistItem } from '@/actions/checklists'

type Props = {
  items: ChecklistItem[]
  onChange: (items: ChecklistItem[]) => void
  placeholder?: string
}

export function TaskList({ items, onChange, placeholder = 'Add a task…' }: Props) {
  const [newText, setNewText] = useState('')

  const sorted = [...items].sort((a, b) => a.order - b.order)

  const addItem = () => {
    if (!newText.trim()) return
    const updated = [
      ...sorted,
      { id: crypto.randomUUID(), text: newText.trim(), order: sorted.length },
    ]
    onChange(updated)
    setNewText('')
  }

  const removeItem = (id: string) => {
    onChange(
      sorted
        .filter((item) => item.id !== id)
        .map((item, i) => ({ ...item, order: i }))
    )
  }

  const swap = (indexA: number, indexB: number) => {
    const next = [...sorted]
    ;[next[indexA], next[indexB]] = [next[indexB], next[indexA]]
    onChange(next.map((item, i) => ({ ...item, order: i })))
  }

  return (
    <div className="space-y-1.5">
      {sorted.map((item, i) => (
        <div key={item.id} className="flex items-center gap-2 group">
          <span className="flex-1 text-sm">{item.text}</span>
          <div className="flex items-center gap-0.5 opacity-0 group-hover:opacity-100 transition-opacity">
            <Button
              variant="ghost"
              size="sm"
              className="h-6 w-6 p-0"
              onClick={() => swap(i, i - 1)}
              disabled={i === 0}
            >
              <ChevronUp className="h-3 w-3" />
            </Button>
            <Button
              variant="ghost"
              size="sm"
              className="h-6 w-6 p-0"
              onClick={() => swap(i, i + 1)}
              disabled={i === sorted.length - 1}
            >
              <ChevronDown className="h-3 w-3" />
            </Button>
            <Button
              variant="ghost"
              size="sm"
              className="h-6 w-6 p-0"
              onClick={() => removeItem(item.id)}
            >
              <Trash2 className="h-3 w-3 text-red-500" />
            </Button>
          </div>
        </div>
      ))}
      <div className="flex gap-2 pt-1">
        <Input
          value={newText}
          onChange={(e) => setNewText(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addItem())}
          placeholder={placeholder}
          className="h-8 text-sm"
        />
        <Button variant="outline" size="sm" className="h-8 shrink-0" onClick={addItem}>
          Add
        </Button>
      </div>
    </div>
  )
}
