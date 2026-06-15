import { redirect } from 'next/navigation'

export default async function RacePage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  redirect(`/races/${id}/setup`)
}
