// ICP session seed: creates test user + race, outputs RACE_ID and credentials
import { db } from '@/lib/db'
import { users, races } from '@/lib/db/schema'
import { eq } from 'drizzle-orm'
import bcrypt from 'bcryptjs'

const TEST_EMAIL = 'icp-alex@racedayos.test'
const TEST_PASS = 'TestAlex123!'

async function main() {
  let user = await db.query.users.findFirst({ where: eq(users.email, TEST_EMAIL) })
  if (!user) {
    const hash = await bcrypt.hash(TEST_PASS, 10)
    const [created] = await db.insert(users).values({
      email: TEST_EMAIL,
      name: 'Alex Runner (ICP)',
      passwordHash: hash,
    }).returning()
    user = created
    console.log('Created user:', user.id)
  } else {
    console.log('Existing user:', user.id)
  }

  let race = await db.query.races.findFirst({ where: eq(races.userId, user.id) })
  if (!race) {
    const [created] = await db.insert(races).values({
      userId: user.id,
      name: 'Leadville Trail 100',
      startTime: new Date('2026-08-22T06:00:00Z'),
      cutoffTime: new Date('2026-08-23T12:00:00Z'),
      distanceKm: '160.93',
      elevationGainM: 5500,
      location: 'Leadville, CO',
    }).returning()
    race = created
    console.log('Created race:', race.id)
  } else {
    console.log('Existing race:', race.id)
  }

  console.log(`ICP_EMAIL=${TEST_EMAIL}`)
  console.log(`ICP_PASS=${TEST_PASS}`)
  console.log(`ICP_RACE_ID=${race.id}`)
  process.exit(0)
}

main().catch(e => { console.error(e); process.exit(1) })
