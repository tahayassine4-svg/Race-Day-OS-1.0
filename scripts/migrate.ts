/**
 * Idempotent schema migration for Race Day OS.
 *
 * Use instead of `drizzle-kit push` — drizzle-kit has a known crash on Node 26
 * due to a CHECK constraint parser bug (TypeError on checkValue.replace).
 * This script uses the postgres driver directly and is safe to re-run.
 *
 * Usage:
 *   npm run migrate
 */

import { config } from 'dotenv'
import { resolve } from 'path'
import postgres from 'postgres'

// Load .env.local (Next.js convention) then fall back to .env
config({ path: resolve(process.cwd(), '.env.local') })
config({ path: resolve(process.cwd(), '.env') })

const url = process.env.DATABASE_URL
if (!url) {
  console.error('Error: DATABASE_URL is not set. Check your .env.local file.')
  process.exit(1)
}

const sql = postgres(url, { ssl: 'require', max: 1, onnotice: () => {} })

async function run() {
  console.log('Running Race Day OS migrations…\n')

  // ── Packet 01–07: baseline schema ────────────────────────────────────────
  // The tables below were created by the initial db:push. We only ADD columns;
  // we never drop or rename anything here so re-runs are fully safe.

  // ── Packet 08–09: GPX import + segment builder ───────────────────────────
  await sql`
    ALTER TABLE races
      ADD COLUMN IF NOT EXISTS gpx_track_points  jsonb,
      ADD COLUMN IF NOT EXISTS imported_stations jsonb,
      ADD COLUMN IF NOT EXISTS import_source     varchar(20) NOT NULL DEFAULT 'manual'
  `
  console.log('✓ races           — gpx_track_points, imported_stations, import_source')

  await sql`
    ALTER TABLE aid_stations
      ADD COLUMN IF NOT EXISTS cutoff_seconds integer
  `
  console.log('✓ aid_stations    — cutoff_seconds')

  // ── Add future migrations here ────────────────────────────────────────────
  // Pattern:
  //   await sql`ALTER TABLE foo ADD COLUMN IF NOT EXISTS bar text`
  //   console.log('✓ foo             — bar')

  await sql.end()
  console.log('\nAll migrations applied.')
}

run().catch(e => {
  console.error('\nMigration failed:', e.message)
  process.exit(1)
})
