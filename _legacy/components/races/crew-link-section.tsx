'use client'

import { useEffect, useState } from 'react'
import { generateCrewToken, rotateCrewToken } from '@/actions/crew-token'
import { Button } from '@/components/ui/button'
import { Copy, Link, RefreshCw } from 'lucide-react'

export function CrewLinkSection({
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
    <div className="space-y-2">
      <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
        Crew Link
      </p>
      {token && crewUrl ? (
        <div className="space-y-1.5">
          <div className="flex items-center gap-1.5 rounded-md border bg-muted/30 px-2 py-1.5">
            <Link className="h-3 w-3 shrink-0 text-muted-foreground" />
            <span className="flex-1 truncate text-xs text-muted-foreground">
              /crew/{token.slice(0, 8)}…
            </span>
          </div>
          <div className="flex gap-1">
            <Button
              variant="outline"
              size="sm"
              className="h-7 flex-1 text-xs"
              onClick={handleCopy}
            >
              {copied ? (
                '✓ Copied'
              ) : (
                <>
                  <Copy className="mr-1 h-3 w-3" />
                  Copy link
                </>
              )}
            </Button>
            <Button
              variant="ghost"
              size="sm"
              className="h-7 px-2 text-xs text-muted-foreground"
              onClick={handleRotate}
              disabled={loading}
              title="Rotate token"
            >
              <RefreshCw className="h-3 w-3" />
            </Button>
          </div>
        </div>
      ) : (
        <Button
          variant="outline"
          size="sm"
          className="h-8 w-full text-xs"
          onClick={handleGenerate}
          disabled={loading}
        >
          {loading ? 'Generating…' : 'Generate Crew Link'}
        </Button>
      )}
    </div>
  )
}
