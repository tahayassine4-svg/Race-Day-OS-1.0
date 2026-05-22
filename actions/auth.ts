'use server'

import { eq } from 'drizzle-orm'
import { db } from '@/lib/db'
import { users } from '@/lib/db/schema'
import bcrypt from 'bcryptjs'

export async function registerUser(
  email: string,
  password: string,
  name: string
): Promise<{ error?: string }> {
  const existing = await db.query.users.findFirst({
    where: eq(users.email, email.toLowerCase().trim()),
  })

  if (existing) {
    return { error: 'An account with this email already exists.' }
  }

  const passwordHash = await bcrypt.hash(password, 12)

  await db.insert(users).values({
    email: email.toLowerCase().trim(),
    name: name.trim(),
    passwordHash,
  })

  return {}
}
