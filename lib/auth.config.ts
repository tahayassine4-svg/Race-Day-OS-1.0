import type { NextAuthConfig } from 'next-auth'

export const authConfig: NextAuthConfig = {
  pages: {
    signIn: '/auth/login',
  },
  callbacks: {
    authorized({ auth, request }) {
      const isLoggedIn = !!auth?.user
      const { pathname } = request.nextUrl

      const isPublic =
        pathname.startsWith('/auth') ||
        pathname.startsWith('/crew') ||
        pathname.startsWith('/api/auth')

      if (isPublic) return true
      return isLoggedIn
    },
    async session({ session, token }) {
      if (token.userId) {
        session.user.id = token.userId as string
      }
      return session
    },
    async jwt({ token, user, account, profile }) {
      if (user?.id) {
        token.userId = user.id
      }
      return token
    },
  },
  providers: [],
}
