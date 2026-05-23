export type DraftStation = {
  id: string          // crypto.randomUUID() — client-only, not persisted
  name: string
  distanceKm: number
  crewAccess: boolean
  dropBag: boolean
  services: 'full' | 'water' | 'medical'
  cutoffTime: string  // HH:MM from race start, empty = no cutoff
  isStart: boolean
  isFinish: boolean
}
