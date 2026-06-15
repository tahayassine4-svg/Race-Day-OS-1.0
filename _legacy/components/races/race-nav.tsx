'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { cn } from '@/lib/utils'

const NAV_ITEMS = [
  { label: 'Setup', slug: 'setup' },
  { label: 'Pacing', slug: 'pacing' },
  { label: 'Fueling', slug: 'fueling' },
  { label: 'Crew', slug: 'crew' },
  { label: 'Checklists', slug: 'checklists' },
  { label: 'Live', slug: 'live' },
]

export function RaceNav({ raceId }: { raceId: string }) {
  const pathname = usePathname()

  return (
    <nav className="flex flex-col gap-1">
      {NAV_ITEMS.map(({ label, slug }) => {
        const href = `/races/${raceId}/${slug}`
        const active = pathname === href
        return (
          <Link
            key={slug}
            href={href}
            className={cn(
              'rounded-md px-3 py-2 text-sm font-medium transition-colors',
              active
                ? 'bg-primary text-primary-foreground'
                : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground'
            )}
          >
            {label}
          </Link>
        )
      })}
    </nav>
  )
}
