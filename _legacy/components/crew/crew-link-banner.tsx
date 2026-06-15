'use client'

import { useEffect, useState } from 'react'
import { generateCrewToken, rotateCrewToken } from '@/actions/crew-token'
import { Button } from '@/components/ui/button'
import { Copy, RefreshCw, Users } from 'lucide-react'

export function CrewLinkBanner({
  raceId,
  crewToken: initial,
}: {
  raceId: string
  crewToken: string | null
}) {
  const [token, setToken] = useState(initial)
  const [origin, setOrigin] = useState('')
  const [loading, setLoading] = useState(false)
  const [copied, setCopied] = useState(false)

  useEffect(() => {
    setOrigin(window.location.origin)
  }, [])

  const crewUrl = token && origin ? `${origin}/crew/${token}` : null

  const handleGenerate = async () => {
    setLoading(true)
    const result = await generateCrewToken(raceId)
    setLoading(false)
    if ('token' in result) setToken(result.token)
  }

  const handleRotate = async () => {
    if (!confirm('Rotating invalidates the old link. Continue?')) return
    setLoading(true)
    const result = await rotateCrewToken(raceId)
    setLoading(false)
    if ('token' in result) setToken(result.token)
  }

  const handleCopy = async () => {
    if (!crewUrl) return
    await navigator.clipboard.writeText(crewUrl)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  return (
    <div className="rounded-lg border bg-card p-4 space-y-3">
      <div className="flex items-center gap-2">
        <Users className="h-4 w-4 text-muted-foreground" />
        <p className="text-sm font-medium">Share with crew</p>
      </div>
      <p className="text-xs text-muted-foreground">
        Send this link to your crew — no account needed. They can view station assignments, ETAs, and log arrivals on race day.
      </p>
      {crewUrl ? (
        <div className="flex items-center gap-2">
          <code className="flex-1 rounded bg-muted px-3 py-1.5 text-xs text-muted-foreground truncate">
            {crewUrl}
          </code>
          <Button variant="outline" size="sm" onClick={handleCopy} className="shrink-0">
            {copied ? '✓ Copied' : (
              <>
                <Copy className="mr-1.5 h-3.5 w-3.5" />
                Copy link
              </>
            )}
          </Button>
          <Button
            variant="ghost"
            size="sm"
            onClick={handleRotate}
            disabled={loading}
            title="Rotate — invalidates old link"
            className="shrink-0 text-muted-foreground"
          >
            <RefreshCw className="h-3.5 w-3.5" />
          </Button>
        </div>
      ) : (
        <Button onClick={handleGenerate} disabled={loading} className="w-full">
          {loading ? 'Generating…' : 'Generate crew link'}
        </Button>
      )}
    </div>
  )
}
