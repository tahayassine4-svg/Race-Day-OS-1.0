import NextAuth from 'next-auth'
import Credentials from 'next-auth/providers/credentials'
import Google from 'next-auth/providers/google'
import { eq } from 'drizzle-orm'
import { db } from '@/lib/db'
import { users } from '@/lib/db/schema'
import bcrypt from 'bcryptjs'
import { authConfig } from './auth.config'

export const { handlers, auth, signIn, signOut } = NextAuth({
  ...authConfig,
  providers: [
    Google,
    Credentials({
      credentials: {
        email: { type: 'email' },
        password: { type: 'password' },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) return null

        const user = await db.query.users.findFirst({
          where: eq(users.email, credentials.email as string),
        })

        if (!user?.passwordHash) return null

        const valid = await bcrypt.compare(
          credentials.password as string,
          user.passwordHash
        )
        if (!valid) return null

        return { id: user.id, email: user.email, name: user.name ?? null }
      },
    }),
  ],
  callbacks: {
    ...authConfig.callbacks,
    async jwt({ token, user, account, profile }) {
      if (user?.id) {
        token.userId = user.id
      }

      if (account?.provider === 'google' && profile?.email) {
        let dbUser = await db.query.users.findFirst({
          where: eq(users.email, profile.email),
        })

        if (!dbUser) {
          const [created] = await db
            .insert(users)
            .values({
              email: profile.email,
              name: profile.name ?? null,
              googleId: account.providerAccountId,
            })
            .returning()
          dbUser = created
        } else if (!dbUser.googleId) {
          await db
            .update(users)
            .set({ googleId: account.providerAccountId })
            .where(eq(users.id, dbUser.id))
        }

        token.userId = dbUser.id
      }

      return token
    },
  },
})
