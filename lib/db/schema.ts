import {
  pgTable,
  uuid,
  varchar,
  text,
  integer,
  boolean,
  timestamp,
  decimal,
  jsonb,
} from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'

export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(),
  email: varchar('email', { length: 255 }).notNull().unique(),
  name: varchar('name', { length: 255 }),
  passwordHash: text('password_hash'),
  googleId: varchar('google_id', { length: 255 }).unique(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
})

export const races = pgTable('races', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  name: varchar('name', { length: 255 }).notNull(),
  startTime: timestamp('start_time', { withTimezone: true }).notNull(),
  cutoffTime: timestamp('cutoff_time', { withTimezone: true }),
  distanceKm: decimal('distance_km', { precision: 10, scale: 2 }),
  elevationGainM: integer('elevation_gain_m'),
  location: varchar('location', { length: 255 }),
  raceGuideUrl: text('race_guide_url'),
  crewToken: uuid('crew_token').unique(),
  activeScenario: varchar('active_scenario', { length: 20 }).default('base').notNull(),
  goalFinishSeconds: integer('goal_finish_seconds'),
  scenarioGoals: jsonb('scenario_goals').$type<Partial<Record<'optimistic' | 'base' | 'pessimistic', { goalSeconds: number; elevAdj: number }>>>(),
  fuelCalPerHour: integer('fuel_cal_per_hour').default(250),
  fuelFluidMlPerHour: integer('fuel_fluid_ml_per_hour').default(500),
  fuelSodiumMgPerHour: integer('fuel_sodium_mg_per_hour').default(500),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
})

export const aidStations = pgTable('aid_stations', {
  id: uuid('id').primaryKey().defaultRandom(),
  raceId: uuid('race_id').notNull().references(() => races.id, { onDelete: 'cascade' }),
  name: varchar('name', { length: 255 }).notNull(),
  distanceKm: decimal('distance_km', { precision: 10, scale: 2 }).notNull(),
  crewAccess: boolean('crew_access').default(false).notNull(),
  pacerAccess: boolean('pacer_access').default(false).notNull(),
  dropBag: boolean('drop_bag').default(false).notNull(),
  services: varchar('services', { length: 50 }).default('full').notNull(),
  sortOrder: integer('sort_order').notNull(),
})

export const segments = pgTable('segments', {
  id: uuid('id').primaryKey().defaultRandom(),
  raceId: uuid('race_id').notNull().references(() => races.id, { onDelete: 'cascade' }),
  fromStationId: uuid('from_station_id').references(() => aidStations.id, { onDelete: 'set null' }),
  toStationId: uuid('to_station_id').notNull().references(() => aidStations.id, { onDelete: 'cascade' }),
  distanceKm: decimal('distance_km', { precision: 10, scale: 2 }).notNull(),
  elevGainM: integer('elev_gain_m').default(0).notNull(),
  elevLossM: integer('elev_loss_m').default(0).notNull(),
  sortOrder: integer('sort_order').notNull(),
})

export const pacePlans = pgTable('pace_plans', {
  id: uuid('id').primaryKey().defaultRandom(),
  segmentId: uuid('segment_id').notNull().references(() => segments.id, { onDelete: 'cascade' }),
  raceId: uuid('race_id').notNull().references(() => races.id, { onDelete: 'cascade' }),
  scenario: varchar('scenario', { length: 20 }).notNull().default('base'),
  plannedPaceSecPerKm: integer('planned_pace_sec_per_km'),
  plannedDurationSec: integer('planned_duration_sec'),
  projectedArrivalTime: timestamp('projected_arrival_time', { withTimezone: true }),
  isManualOverride: boolean('is_manual_override').default(false).notNull(),
})

export const fuelPlans = pgTable('fuel_plans', {
  id: uuid('id').primaryKey().defaultRandom(),
  segmentId: uuid('segment_id').notNull().references(() => segments.id, { onDelete: 'cascade' }),
  raceId: uuid('race_id').notNull().references(() => races.id, { onDelete: 'cascade' }),
  targetCalPerHour: integer('target_cal_per_hour'),
  targetFluidMlPerHour: integer('target_fluid_ml_per_hour'),
  targetSodiumMgPerHour: integer('target_sodium_mg_per_hour'),
  totalCalories: integer('total_calories'),
  totalFluidMl: integer('total_fluid_ml'),
  totalSodiumMg: integer('total_sodium_mg'),
  itemNotes: text('item_notes'),
  isManualOverride: boolean('is_manual_override').default(false).notNull(),
})

export const crewMembers = pgTable('crew_members', {
  id: uuid('id').primaryKey().defaultRandom(),
  raceId: uuid('race_id').notNull().references(() => races.id, { onDelete: 'cascade' }),
  name: varchar('name', { length: 255 }).notNull(),
  phone: varchar('phone', { length: 50 }),
})

export const crewAssignments = pgTable('crew_assignments', {
  id: uuid('id').primaryKey().defaultRandom(),
  crewMemberId: uuid('crew_member_id').notNull().references(() => crewMembers.id, { onDelete: 'cascade' }),
  stationId: uuid('station_id').notNull().references(() => aidStations.id, { onDelete: 'cascade' }),
  role: varchar('role', { length: 100 }),
})

export const stationChecklists = pgTable('station_checklists', {
  id: uuid('id').primaryKey().defaultRandom(),
  stationId: uuid('station_id').notNull().references(() => aidStations.id, { onDelete: 'cascade' }).unique(),
  runnerTasks: jsonb('runner_tasks').$type<Array<{ id: string; text: string; order: number }>>(),
  crewTasks: jsonb('crew_tasks').$type<Array<{ id: string; text: string; order: number }>>(),
  mentalAnchor: text('mental_anchor'),
})

export const stationEvents = pgTable('station_events', {
  id: uuid('id').primaryKey().defaultRandom(),
  stationId: uuid('station_id').notNull().references(() => aidStations.id, { onDelete: 'cascade' }),
  raceId: uuid('race_id').notNull().references(() => races.id, { onDelete: 'cascade' }),
  actualArrival: timestamp('actual_arrival', { withTimezone: true }),
  actualDeparture: timestamp('actual_departure', { withTimezone: true }),
  conditionNotes: text('condition_notes'),
  loggedBy: varchar('logged_by', { length: 255 }),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
})

// Relations
export const usersRelations = relations(users, ({ many }) => ({
  races: many(races),
}))

export const racesRelations = relations(races, ({ one, many }) => ({
  user: one(users, { fields: [races.userId], references: [users.id] }),
  aidStations: many(aidStations),
  segments: many(segments),
  pacePlans: many(pacePlans),
  fuelPlans: many(fuelPlans),
  crewMembers: many(crewMembers),
  stationEvents: many(stationEvents),
}))

export const aidStationsRelations = relations(aidStations, ({ one, many }) => ({
  race: one(races, { fields: [aidStations.raceId], references: [races.id] }),
  crewAssignments: many(crewAssignments),
  checklist: one(stationChecklists, {
    fields: [aidStations.id],
    references: [stationChecklists.stationId],
  }),
  stationEvents: many(stationEvents),
  segmentsFrom: many(segments, { relationName: 'fromStation' }),
  segmentsTo: many(segments, { relationName: 'toStation' }),
}))

export const segmentsRelations = relations(segments, ({ one, many }) => ({
  race: one(races, { fields: [segments.raceId], references: [races.id] }),
  fromStation: one(aidStations, {
    fields: [segments.fromStationId],
    references: [aidStations.id],
    relationName: 'fromStation',
  }),
  toStation: one(aidStations, {
    fields: [segments.toStationId],
    references: [aidStations.id],
    relationName: 'toStation',
  }),
  pacePlans: many(pacePlans),
  fuelPlans: many(fuelPlans),
}))

export const pacePlansRelations = relations(pacePlans, ({ one }) => ({
  segment: one(segments, { fields: [pacePlans.segmentId], references: [segments.id] }),
  race: one(races, { fields: [pacePlans.raceId], references: [races.id] }),
}))

export const fuelPlansRelations = relations(fuelPlans, ({ one }) => ({
  segment: one(segments, { fields: [fuelPlans.segmentId], references: [segments.id] }),
  race: one(races, { fields: [fuelPlans.raceId], references: [races.id] }),
}))

export const crewMembersRelations = relations(crewMembers, ({ one, many }) => ({
  race: one(races, { fields: [crewMembers.raceId], references: [races.id] }),
  assignments: many(crewAssignments),
}))

export const crewAssignmentsRelations = relations(crewAssignments, ({ one }) => ({
  crewMember: one(crewMembers, {
    fields: [crewAssignments.crewMemberId],
    references: [crewMembers.id],
  }),
  station: one(aidStations, {
    fields: [crewAssignments.stationId],
    references: [aidStations.id],
  }),
}))

export const stationChecklistsRelations = relations(stationChecklists, ({ one }) => ({
  station: one(aidStations, {
    fields: [stationChecklists.stationId],
    references: [aidStations.id],
  }),
}))

export const stationEventsRelations = relations(stationEvents, ({ one }) => ({
  station: one(aidStations, { fields: [stationEvents.stationId], references: [aidStations.id] }),
  race: one(races, { fields: [stationEvents.raceId], references: [races.id] }),
}))
