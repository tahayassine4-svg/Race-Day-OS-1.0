import postgres from 'postgres'

const url = process.env.DATABASE_URL!
if (!url) throw new Error('DATABASE_URL not set')

const sql = postgres(url, { ssl: 'require', max: 1 })

async function run() {
  console.log('Applying Packet 08/09 schema changes…')

  await sql`
    ALTER TABLE races
      ADD COLUMN IF NOT EXISTS gpx_track_points  jsonb,
      ADD COLUMN IF NOT EXISTS imported_stations jsonb,
      ADD COLUMN IF NOT EXISTS import_source     varchar(20) NOT NULL DEFAULT 'manual'
  `
  console.log('✓ races: gpx_track_points, imported_stations, import_source')

  await sql`
    ALTER TABLE aid_stations
      ADD COLUMN IF NOT EXISTS cutoff_seconds integer
  `
  console.log('✓ aid_stations: cutoff_seconds')

  await sql.end()
  console.log('Done.')
}

run().catch(e => { console.error('FAILED:', e.message); process.exit(1) })
