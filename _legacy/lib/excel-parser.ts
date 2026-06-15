// Client-only: uses dynamic import('xlsx') and File API
import type { ParsedStation } from './gpx-parser'
import { parseCSVStations } from './gpx-parser'

export type ExcelParseResult = {
  stations: ParsedStation[]
  columnMap: Record<string, string>   // field key → actual header as found in the sheet
  unmappedHeaders: string[]
  error?: string
}

const NAME_ALIASES    = ['name', 'station', 'aid station', 'checkpoint', 'location', 'aid']
const DIST_ALIASES    = ['distance', 'dist', 'km', 'distance (km)', 'dist km', 'distance km', 'miles', 'mi', 'distance (mi)', 'dist (km)', 'dist (mi)']
const CREW_ALIASES    = ['crew', 'crew access', 'crew accessible', 'crew?', 'crew (y/n)']
const DROP_ALIASES    = ['drop', 'drop bag', 'dropbag', 'drop?', 'drop bags', 'drop bag (y/n)']
const SVC_ALIASES     = ['services', 'service', 'type', 'aid type', 'station type', 'services available']
const CUTOFF_ALIASES  = ['cutoff', 'cutoff time', 'time limit', 'cutoff (hh:mm)', 'close time', 'station cutoff', 'cutoff time (hh:mm)']

function norm(s: string) { return s.trim().toLowerCase() }

function matchAlias(header: string, aliases: string[]): boolean {
  return aliases.includes(norm(header))
}

function parseBool(val: unknown): boolean {
  if (typeof val === 'boolean') return val
  if (typeof val === 'number') return val !== 0
  const s = String(val ?? '').trim().toLowerCase()
  return ['y', 'yes', 'true', '1', 'x'].includes(s)
}

function parseServices(val: unknown): string {
  const s = String(val ?? '').trim().toLowerCase()
  if (s.includes('water')) return 'water'
  if (s.includes('medical') || s === 'med') return 'medical'
  return 'full'
}

function parseCutoff(val: unknown): string {
  if (!val && val !== 0) return ''
  const s = String(val).trim()
  if (/^\d{1,2}:\d{2}(:\d{2})?$/.test(s)) {
    const [h, m] = s.split(':')
    return `${h.padStart(2, '0')}:${m}`
  }
  const n = parseFloat(s)
  if (!isNaN(n)) {
    const h = Math.floor(n)
    const m = Math.round((n - h) * 60)
    return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`
  }
  return ''
}

async function parseExcelBuffer(buffer: ArrayBuffer): Promise<ExcelParseResult> {
  const XLSX = await import('xlsx')
  const wb = XLSX.read(new Uint8Array(buffer), { type: 'array' })
  const ws = wb.Sheets[wb.SheetNames[0]]
  const rows = XLSX.utils.sheet_to_json<unknown[]>(ws, { header: 1, defval: '' }) as unknown[][]

  if (rows.length < 2) {
    return { stations: [], columnMap: {}, unmappedHeaders: [], error: 'Sheet appears empty or has only a header row.' }
  }

  const headers = rows[0].map(h => String(h ?? ''))
  const dataRows = rows.slice(1).filter(r => r.some(c => c !== ''))

  const colIdx: Record<string, number> = {}
  const columnMap: Record<string, string> = {}
  const unmappedHeaders: string[] = []

  headers.forEach((h, i) => {
    if (!h.trim()) return
    if (matchAlias(h, NAME_ALIASES))   { colIdx.name = i;   columnMap.name   = h }
    else if (matchAlias(h, DIST_ALIASES))   { colIdx.dist = i;   columnMap.dist   = h }
    else if (matchAlias(h, CREW_ALIASES))   { colIdx.crew = i;   columnMap.crew   = h }
    else if (matchAlias(h, DROP_ALIASES))   { colIdx.drop = i;   columnMap.drop   = h }
    else if (matchAlias(h, SVC_ALIASES))    { colIdx.svc  = i;   columnMap.svc    = h }
    else if (matchAlias(h, CUTOFF_ALIASES)) { colIdx.cutoff = i; columnMap.cutoff = h }
    else unmappedHeaders.push(h)
  })

  if (colIdx.name === undefined || colIdx.dist === undefined) {
    return {
      stations: [],
      columnMap,
      unmappedHeaders,
      error: `Required columns (Name + Distance) not found. Headers detected: ${headers.filter(h => h.trim()).join(', ')}`,
    }
  }

  const distHeader = norm(columnMap.dist ?? '')
  const isMiles = (distHeader.includes('mi') || distHeader.includes('mile')) && !distHeader.includes('km')

  const stations: ParsedStation[] = []
  for (const row of dataRows) {
    const name = String((row as unknown[])[colIdx.name] ?? '').trim()
    const rawDist = parseFloat(String((row as unknown[])[colIdx.dist] ?? ''))
    if (!name || isNaN(rawDist)) continue
    const distanceKm = isMiles ? rawDist * 1.60934 : rawDist
    stations.push({
      name,
      distanceKm,
      crewAccess: colIdx.crew !== undefined ? parseBool((row as unknown[])[colIdx.crew]) : false,
      dropBag:    colIdx.drop !== undefined ? parseBool((row as unknown[])[colIdx.drop]) : false,
      services:   colIdx.svc  !== undefined ? parseServices((row as unknown[])[colIdx.svc]) : 'full',
      cutoffTime: colIdx.cutoff !== undefined ? parseCutoff((row as unknown[])[colIdx.cutoff]) : '',
    })
  }

  stations.sort((a, b) => a.distanceKm - b.distanceKm)
  return { stations, columnMap, unmappedHeaders }
}

export async function parseStationFile(file: File): Promise<ExcelParseResult> {
  const name = file.name.toLowerCase()

  if (name.endsWith('.csv')) {
    const text = await file.text()
    const stations = parseCSVStations(text)
    if (stations.length === 0) {
      return { stations: [], columnMap: {}, unmappedHeaders: [], error: 'No stations found in CSV. Expected columns: Name, Distance, Crew (Y/N), Drop Bag (Y/N), Services.' }
    }
    return { stations, columnMap: { name: 'Name', dist: 'Distance' }, unmappedHeaders: [] }
  }

  if (name.endsWith('.xlsx') || name.endsWith('.xls')) {
    const buffer = await file.arrayBuffer()
    return parseExcelBuffer(buffer)
  }

  return { stations: [], columnMap: {}, unmappedHeaders: [], error: 'Unsupported file type. Use .xlsx, .xls, or .csv.' }
}
