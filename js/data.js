// ===================================================================
// TERRAPULSE - Open Data Feeds & Real-Time Telemetry Pipeline
// Integrates USGS Open GeoJSON, Open-Meteo Weather, Local Storage
// ===================================================================

const DEFAULT_INCIDENTS = [
  {
    id: "tp-eq-001",
    type: "earthquake",
    title: "M 6.8 - Off the East Coast of Honshu, Japan",
    coords: [38.297, 142.373],
    magnitude: 6.8,
    depth: 24.5,
    severity: "CRITICAL",
    time: "22 mins ago",
    timestamp: Date.now() - 22 * 60 * 1000,
    source: "USGS Seismic Network",
    atRiskPop: "1,240,000",
    radiusKm: 180,
    triageNotes: "Tsunami advisory issued for Miyagi & Fukushima Prefectures. Coastal sea-wall gates engaged. Immediate high ground evacuation recommended for zone A.",
    status: "active"
  },
  {
    id: "tp-st-002",
    type: "cyclone",
    title: "Super Typhoon 'VORTEX-9' - Cat 4 Approaching Gulf of Tonkin",
    coords: [20.8449, 106.6881],
    magnitude: "Cat 4 (220 km/h)",
    depth: 0,
    severity: "CRITICAL",
    time: "1 hour ago",
    timestamp: Date.now() - 60 * 60 * 1000,
    source: "WMO & Open-Meteo Radar",
    atRiskPop: "4,850,000",
    radiusKm: 260,
    triageNotes: "Extreme storm surge threat (2.8m - 3.5m) in coastal Hai Phong & Quang Ninh. 14,000 fishing vessels docked. Pre-emptive power grid stabilization underway.",
    status: "active"
  },
  {
    id: "tp-fl-003",
    type: "flood",
    title: "Severe Flash Flood & Landslide Alert - Yen Bai / Lao Cai Highlands",
    coords: [21.7229, 104.9113],
    magnitude: "Flash Index 8.9",
    depth: 0,
    severity: "CRITICAL",
    time: "3 hours ago",
    timestamp: Date.now() - 180 * 60 * 1000,
    source: "Global Flood Awareness (GloFAS)",
    atRiskPop: "320,000",
    radiusKm: 75,
    triageNotes: "Red River water levels exceeded Warning Level 3 by 1.4m. Multiple arterial bridges blocked by debris. Rubber rescue boats and air-drop food ration dispatched.",
    status: "active"
  },
  {
    id: "tp-eq-004",
    type: "earthquake",
    title: "M 5.4 - Central Turkey Aftershock Cluster",
    coords: [37.5753, 36.9228],
    magnitude: 5.4,
    depth: 10.0,
    severity: "WARNING",
    time: "4 hours ago",
    timestamp: Date.now() - 240 * 60 * 1000,
    source: "EMSC / USGS",
    atRiskPop: "410,000",
    radiusKm: 65,
    triageNotes: "Shallow tectonic rupture. Structural inspection teams on standby for compromised masonry dwellings. No major casualty reported so far.",
    status: "active"
  },
  {
    id: "tp-wf-005",
    type: "wildfire",
    title: "Northern California Wildfire Complex - 12,000 Acres",
    coords: [39.7596, -121.6219],
    magnitude: "Level 4 Fire",
    depth: 0,
    severity: "WARNING",
    time: "6 hours ago",
    timestamp: Date.now() - 360 * 60 * 1000,
    source: "NASA FIRMS Satellite",
    atRiskPop: "85,000",
    radiusKm: 45,
    triageNotes: "High winds (45 mph) pushing smoke plumes south-east. Level 3 mandatory evacuation notice enacted for Butte County sectors 4 to 9.",
    status: "active"
  },
  {
    id: "tp-eq-006",
    type: "earthquake",
    title: "M 4.9 - Southern Sumatra, Indonesia",
    coords: [-4.821, 103.112],
    magnitude: 4.9,
    depth: 54.0,
    severity: "INFO",
    time: "7 hours ago",
    timestamp: Date.now() - 420 * 60 * 1000,
    source: "BMKG Indonesia / USGS",
    atRiskPop: "180,000",
    radiusKm: 30,
    triageNotes: "Deep subduction event. Light shaking reported along coastal Bengkulu. No tsunami risk detected.",
    status: "monitoring"
  }
];

// Open Shelters POIs
const DEFAULT_SHELTERS = [
  { id: "sh-1", name: "Hai Phong Municipal Stadium Evacuation Center", coords: [20.856, 106.682], capacity: "3,500 people", status: "OPEN (Capacity: 45%)", phone: "+84 225 382 119" },
  { id: "sh-2", name: "Yen Bai High Ground Provincial Arena", coords: [21.715, 104.902], capacity: "1,800 people", status: "OPEN (Capacity: 82%)", phone: "+84 216 385 241" },
  { id: "sh-3", name: "Sendai Civic High School Tsunami Sanctuary", coords: [38.268, 140.869], capacity: "2,200 people", status: "OPEN (Capacity: 30%)", phone: "+81 22 214 1111" },
  { id: "sh-4", name: "Chico Community Evacuation Complex", coords: [39.728, -121.837], capacity: "1,200 people", status: "OPEN (Capacity: 60%)", phone: "+1 530 895 4400" }
];

// Distributed Humanitarian Inventory
const DEFAULT_RESOURCES = [
  { id: "res-1", name: "High-Capacity Inflatable Rescue Boats (Zodiac)", category: "Mobility", count: 48, status: "available", icon: "ship" },
  { id: "res-2", name: "Mobile Water Desalination & Filtration Units", category: "Sanitation", count: 120, status: "deployed", icon: "droplet" },
  { id: "res-3", name: "Trauma Surgical Response Packs & Defibrillators", category: "Medical", count: 350, status: "available", icon: "cross" },
  { id: "res-4", name: "Starlink Emergency Satellite Terminals (Off-Grid)", category: "Telecom", count: 25, status: "available", icon: "wifi" },
  { id: "res-5", name: "Heavy-Duty Diesel Power Generators (50kVA)", category: "Energy", count: 40, status: "deployed", icon: "zap" },
  { id: "res-6", name: "Thermal Imaging Search & Rescue Quadcopters", category: "Recon", count: 18, status: "available", icon: "camera" }
];

// Active Community SOS Queue
const DEFAULT_SOS_QUEUE = [
  {
    id: "sos-901",
    sender: "Tran Van Minh (Hamlet 3, Yen Binh)",
    location: "Yen Bai Province, Vietnam",
    coords: [21.730, 104.920],
    urgency: "P1", // P1: Critical, P2: Urgent, P3: Assistance
    victims: "4 adults, 2 elderly, 1 infant",
    message: "Flood water reached roof ceiling! Power and mobile signals intermittent. Running out of clean water. Need immediate boat evacuation.",
    timestamp: Date.now() - 14 * 60 * 1000,
    status: "DISPATCHING"
  },
  {
    id: "sos-902",
    sender: "Fukushima Fishery Cooperative Hub",
    location: "Iwaki Coast, Japan",
    coords: [37.050, 140.890],
    urgency: "P2",
    victims: "12 dockworkers",
    message: "Harbor pier damaged by initial seismic wave. Need structural inspection and backup communications relay.",
    timestamp: Date.now() - 38 * 60 * 1000,
    status: "PENDING"
  },
  {
    id: "sos-903",
    sender: "Butte County Volunteer Fire Brigade 4",
    location: "Paradise Outskirts, CA",
    coords: [39.760, -121.610],
    urgency: "P1",
    victims: "8 firefighters, 15 residents",
    message: "Flames jumped firebreak corridor on Route 70. Need aerial water drop coordination and N95 masks.",
    timestamp: Date.now() - 52 * 60 * 1000,
    status: "ASSIGNED"
  }
];

class DataManager {
  constructor() {
    this.incidents = this.loadLocal('tp_incidents', DEFAULT_INCIDENTS);
    this.shelters = this.loadLocal('tp_shelters', DEFAULT_SHELTERS);
    this.resources = this.loadLocal('tp_resources', DEFAULT_RESOURCES);
    this.sosQueue = this.loadLocal('tp_sos', DEFAULT_SOS_QUEUE);
    this.listeners = [];
  }

  loadLocal(key, defaultVal) {
    try {
      const data = localStorage.getItem(key);
      return data ? JSON.parse(data) : defaultVal;
    } catch (e) {
      return defaultVal;
    }
  }

  saveLocal(key, val) {
    try {
      localStorage.setItem(key, JSON.stringify(val));
    } catch (e) {
      console.warn("Storage quota exceeded or disabled", e);
    }
  }

  subscribe(callback) {
    this.listeners.push(callback);
  }

  notify() {
    this.listeners.forEach(cb => cb());
  }

  // Fetch real-time USGS GeoJSON earthquake feed
  async fetchLiveUSGS() {
    try {
      const res = await fetch('https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson');
      if (!res.ok) throw new Error("Network error fetching USGS feed");
      const geojson = await res.json();
      
      const liveEvents = geojson.features.slice(0, 15).map(f => {
        const mag = f.properties.mag || 0;
        let severity = "INFO";
        if (mag >= 6.0) severity = "CRITICAL";
        else if (mag >= 4.5) severity = "WARNING";

        const minutesAgo = Math.round((Date.now() - f.properties.time) / 60000);
        const timeStr = minutesAgo < 60 ? `${minutesAgo} mins ago` : `${Math.floor(minutesAgo/60)} hours ago`;

        return {
          id: `usgs-${f.id}`,
          type: "earthquake",
          title: `M ${mag.toFixed(1)} - ${f.properties.place || "Unknown Region"}`,
          coords: [f.geometry.coordinates[1], f.geometry.coordinates[0]],
          magnitude: mag.toFixed(1),
          depth: f.geometry.coordinates[2] || 10,
          severity: severity,
          time: timeStr,
          timestamp: f.properties.time,
          source: "USGS Real-Time Feed",
          atRiskPop: `${Math.round(mag * 125000).toLocaleString()}`,
          radiusKm: Math.round(Math.pow(10, (mag * 0.43)) * 0.8),
          triageNotes: `Automated USGS seismic telemetry. Focal depth: ${f.geometry.coordinates[2]}km. Shake intensity PAGER rating: ${mag >= 6.0 ? 'Yellow/Orange' : 'Green'}.`,
          status: "active"
        };
      });

      // Merge unique real-time events with curated multi-hazard events
      const merged = [...liveEvents, ...DEFAULT_INCIDENTS.filter(i => i.type !== 'earthquake')];
      this.incidents = merged;
      this.saveLocal('tp_incidents', this.incidents);
      this.notify();
      return { success: true, count: liveEvents.length };
    } catch (err) {
      console.warn("USGS feed offline or restricted by CORS, fallback to local database", err);
      return { success: false, fallback: true };
    }
  }

  // Fetch live weather from Open-Meteo API for coordinates
  async fetchLiveWeather(lat, lon) {
    try {
      const url = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m,wind_direction_10m,surface_pressure`;
      const res = await fetch(url);
      if (!res.ok) throw new Error("Open-Meteo API unreachable");
      const data = await res.json();
      return {
        success: true,
        current: data.current
      };
    } catch (e) {
      return {
        success: false,
        error: e.message
      };
    }
  }

  // Add new SOS Distress Signal
  addSOS(sos) {
    const newEntry = {
      id: `sos-${Date.now().toString().slice(-4)}`,
      timestamp: Date.now(),
      status: "PENDING",
      ...sos
    };
    this.sosQueue.unshift(newEntry);
    this.saveLocal('tp_sos', this.sosQueue);
    this.notify();
    return newEntry;
  }

  // Update SOS status
  updateSOSStatus(id, newStatus) {
    const item = this.sosQueue.find(s => s.id === id);
    if (item) {
      item.status = newStatus;
      this.saveLocal('tp_sos', this.sosQueue);
      this.notify();
    }
  }

  // Add simulated incident
  addSimulatedIncident(incident) {
    this.incidents.unshift(incident);
    this.saveLocal('tp_incidents', this.incidents);
    this.notify();
  }

  // Export current incidents as standard GeoJSON
  exportGeoJSON() {
    const features = this.incidents.map(inc => ({
      type: "Feature",
      geometry: {
        type: "Point",
        coordinates: [inc.coords[1], inc.coords[0]]
      },
      properties: {
        id: inc.id,
        title: inc.title,
        type: inc.type,
        magnitude: inc.magnitude,
        severity: inc.severity,
        source: inc.source,
        triageNotes: inc.triageNotes
      }
    }));

    const geojson = {
      type: "FeatureCollection",
      generator: "TerraPulse Open Humanitarian OS - UN OCHA Standard",
      timestamp: new Date().toISOString(),
      features
    };

    const blob = new Blob([JSON.stringify(geojson, null, 2)], { type: "application/geo+json" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `terrapulse_emergency_incidents_${Date.now()}.geojson`;
    a.click();
    URL.revokeObjectURL(url);
  }
}

window.dataManager = new DataManager();
