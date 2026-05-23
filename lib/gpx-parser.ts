export type ParsedStation = {
  name: string
  distanceKm: number
  crewAccess: boolean
  dropBag: boolean
  services: string
  cutoffTime?: string  // HH:MM from aid station sheet, empty = no cutoff
}

export type TrackPoint = { cumKm: number; ele: number }

export type GPXTrackResult = {
  points: TrackPoint[]
  stations: ParsedStation[]
  totalKm: number
  elevGainM: number
  error?: string
}

export type GPXParseResult = {
  stations: ParsedStation[]
  totalDistanceKm: number
  totalElevationGainM: number
  error?: string
}

function haversineKm(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371
  const φ1 = (lat1 * Math.PI) / 180
  const φ2 = (lat2 * Math.PI) / 180
  const Δφ = ((lat2 - lat1) * Math.PI) / 180
  const Δλ = ((lon2 - lon1) * Math.PI) / 180
  const a = Math.sin(Δφ / 2) ** 2 + Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) ** 2
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
}

function guessServices(name: string): string {
  const lower = name.toLowerCase()
  if (lower.includes('medical') || lower.includes('med ')) return 'medical'
  if (lower.includes('water only') || lower.includes('water only')) return 'water'
  return 'full'
}

function guessCrewAccess(name: string): boolean {
  const lower = name.toLowerCase()
  return lower.includes('crew') || lower.includes('access') || lower.includes('main')
}

function guessDropBag(name: string): boolean {
  return name.toLowerCase().includes('drop')
}

export function parseGPXFile(text: string): GPXParseResult {
  let doc: Document
  try {
    doc = new DOMParser().parseFromString(text, 'application/xml')
    if (doc.querySelector('parsererror')) throw new Error()
  } catch {
    return { stations: [], totalDistanceKm: 0, totalElevationGainM: 0, error: 'Could not parse GPX file.' }
  }

  // Build track from trkpt or rtept elements
  const ptEls = Array.from(doc.querySelectorAll('trkpt, rtept'))
  const track = ptEls.map((el) => ({
    lat: parseFloat(el.getAttribute('lat') ?? '0'),
    lon: parseFloat(el.getAttribute('lon') ?? '0'),
    ele: parseFloat(el.querySelector('ele')?.textContent ?? '0'),
    cumKm: 0,
  }))

  let totalDistanceKm = 0
  let totalElevationGainM = 0
  for (let i = 1; i < track.length; i++) {
    totalDistanceKm += haversineKm(track[i - 1].lat, track[i - 1].lon, track[i].lat, track[i].lon)
    track[i].cumKm = totalDistanceKm
    const diff = track[i].ele - track[i - 1].ele
    if (diff > 0) totalElevationGainM += diff
  }

  const wptEls = Array.from(doc.querySelectorAll('wpt'))
  if (wptEls.length === 0 && track.length === 0) {
    return { stations: [], totalDistanceKm: 0, totalElevationGainM: 0, error: 'No waypoints or track found in this GPX file.' }
  }

  if (wptEls.length === 0) {
    return { stations: [], totalDistanceKm, totalElevationGainM: Math.round(totalElevationGainM), error: 'Track found but no waypoints for aid stations. Add waypoints to your GPX for each station.' }
  }

  const stations: ParsedStation[] = wptEls.map((wpt) => {
    const lat = parseFloat(wpt.getAttribute('lat') ?? '0')
    const lon = parseFloat(wpt.getAttribute('lon') ?? '0')
    const name = wpt.querySelector('name')?.textContent?.trim() ?? 'Aid Station'

    let distanceKm = 0
    if (track.length > 0) {
      let minD = Infinity
      for (const pt of track) {
        const d = haversineKm(lat, lon, pt.lat, pt.lon)
        if (d < minD) { minD = d; distanceKm = pt.cumKm }
      }
    }

    return {
      name,
      distanceKm,
      crewAccess: guessCrewAccess(name),
      dropBag: guessDropBag(name),
      services: guessServices(name),
    }
  })

  stations.sort((a, b) => a.distanceKm - b.distanceKm)
  return { stations, totalDistanceKm, totalElevationGainM: Math.round(totalElevationGainM) }
}

export function parseGPXToTrack(text: string, maxPoints = 500): GPXTrackResult {
  let doc: Document
  try {
    doc = new DOMParser().parseFromString(text, 'application/xml')
    if (doc.querySelector('parsererror')) throw new Error()
  } catch {
    return { points: [], stations: [], totalKm: 0, elevGainM: 0, error: 'Could not parse GPX file.' }
  }

  const ptEls = Array.from(doc.querySelectorAll('trkpt, rtept'))
  if (ptEls.length === 0) {
    return { points: [], stations: [], totalKm: 0, elevGainM: 0, error: 'No track points found. Make sure your GPX has a recorded track.' }
  }

  type RawPt = { lat: number; lon: number; ele: number; cumKm: number }
  const raw: RawPt[] = []
  let totalKm = 0
  let elevGainM = 0

  for (let i = 0; i < ptEls.length; i++) {
    const el = ptEls[i]
    const lat = parseFloat(el.getAttribute('lat') ?? '0')
    const lon = parseFloat(el.getAttribute('lon') ?? '0')
    const ele = parseFloat(el.querySelector('ele')?.textContent ?? '0')
    if (i > 0) {
      totalKm += haversineKm(raw[i - 1].lat, raw[i - 1].lon, lat, lon)
      const diff = ele - raw[i - 1].ele
      if (diff > 0) elevGainM += diff
    }
    raw.push({ lat, lon, ele, cumKm: totalKm })
  }

  const sampled: TrackPoint[] = []
  if (raw.length <= maxPoints) {
    for (const p of raw) sampled.push({ cumKm: p.cumKm, ele: p.ele })
  } else {
    const step = Math.ceil(raw.length / maxPoints)
    for (let i = 0; i < raw.length; i += step) sampled.push({ cumKm: raw[i].cumKm, ele: raw[i].ele })
    const last = raw[raw.length - 1]
    if (sampled[sampled.length - 1].cumKm !== last.cumKm) sampled.push({ cumKm: last.cumKm, ele: last.ele })
  }

  const wptEls = Array.from(doc.querySelectorAll('wpt'))
  const stations: ParsedStation[] = wptEls.map((wpt) => {
    const lat = parseFloat(wpt.getAttribute('lat') ?? '0')
    const lon = parseFloat(wpt.getAttribute('lon') ?? '0')
    const name = wpt.querySelector('name')?.textContent?.trim() ?? 'Aid Station'
    let distanceKm = 0
    let minD = Infinity
    for (const pt of raw) {
      const d = haversineKm(lat, lon, pt.lat, pt.lon)
      if (d < minD) { minD = d; distanceKm = pt.cumKm }
    }
    return { name, distanceKm, crewAccess: guessCrewAccess(name), dropBag: guessDropBag(name), services: guessServices(name) }
  }).sort((a, b) => a.distanceKm - b.distanceKm)

  return { points: sampled, stations, totalKm, elevGainM: Math.round(elevGainM) }
}

export function parseCSVStations(text: string): ParsedStation[] {
  const lines = text.trim().split('\n').filter((l) => l.trim())
  const stations: ParsedStation[] = []

  // Detect and skip header row (second col is non-numeric)
  const startIdx = isNaN(parseFloat(lines[0]?.split(/[,\t]/)[1])) ? 1 : 0

  for (let i = startIdx; i < lines.length; i++) {
    const parts = lines[i].split(/[,\t]/).map((p) => p.trim().replace(/^["']|["']$/g, ''))
    if (parts.length < 2) continue
    const name = parts[0]
    const dist = parseFloat(parts[1])
    if (!name || isNaN(dist)) continue
    const crew = parts[2]?.toLowerCase().startsWith('y') ?? false
    const drop = parts[3]?.toLowerCase().startsWith('y') ?? false
    const svc = parts[4] ? guessServices(parts[4]) : 'full'
    stations.push({ name, distanceKm: dist, crewAccess: crew, dropBag: drop, services: svc })
  }

  return stations.sort((a, b) => a.distanceKm - b.distanceKm)
}
