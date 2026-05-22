import { redirect } from 'next/navigation'
import { auth } from '@/lib/auth'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { signOut } from '@/lib/auth'

export default async function AppLayout({ children }: { children: React.ReactNode }) {
  const session = await auth()
  if (!session) redirect('/auth/login')

  return (
    <div className="min-h-screen bg-background">
      <header className="border-b">
        <div className="container flex h-14 items-center justify-between">
          <Link href="/dashboard" className="font-semibold text-lg">
            Race Day OS
          </Link>
          <div className="flex items-center gap-4">
            <span className="text-sm text-muted-foreground hidden sm:block">
              {session.user.name ?? session.user.email}
            </span>
            <form
              action={async () => {
                'use server'
                await signOut({ redirectTo: '/auth/login' })
              }}
            >
              <Button variant="ghost" size="sm" type="submit">
                Sign out
              </Button>
            </form>
          </div>
        </div>
      </header>
      <main className="container py-8">{children}</main>
    </div>
  )
}
