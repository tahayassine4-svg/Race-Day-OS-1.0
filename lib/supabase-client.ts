import { createClient } from '@supabase/supabase-js'

// Browser-side Supabase client — used only for Realtime subscriptions.
// DB reads/writes go through Drizzle (server-side only).
export const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)
