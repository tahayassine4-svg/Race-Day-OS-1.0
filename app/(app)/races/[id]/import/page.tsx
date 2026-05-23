import { auth } from '@/lib/auth'
import { db } from '@/lib/db'
import { races } from '@/lib/db/schema'
import { and, eq } from 'drizzle-orm'
import { notFound } from 'next/navigation'
import { ImportClient } from '@/components/import/import-client'

export default async function ImportPage({ params }: { params: Promise<{ id: string }> }) {
  const { id: raceId } = await params
  const session = await auth()

  const race = await db.query.races.findFirst({
    where: and(eq(races.id, raceId), eq(races.userId, session!.user.id)),
    columns: { id: true },
  })
  if (!race) notFound()

  return (
    <div className="max-w-2xl">
      <ImportClient raceId={raceId} />
    </div>
  )
}
