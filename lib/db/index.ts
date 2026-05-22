import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from './schema'

// Singleton prevents new connection pools on every hot reload in dev
const globalForDb = globalThis as unknown as { pgClient: ReturnType<typeof postgres> | undefined }

const client =
  globalForDb.pgClient ??
  postgres(process.env.DATABASE_URL!, {
    prepare: false, // required for Supabase pgBouncer
    max: 3,         // stay well under the free-tier cap of 15
  })

if (process.env.NODE_ENV !== 'production') globalForDb.pgClient = client

export const db = drizzle(client, { schema })
