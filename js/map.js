// ===================================================================
// TERRAPULSE - Leaflet Geospatial Tactical Radar Engine
// Renders dynamic crisis layers, impact radiuses, and shelter POIs
// ===================================================================

class TacticalMap {
  constructor() {
    this.map = null;
    this.layerGroups = {
      earthquakes: null,
      storms: null,
      floods: null,
      wildfires: null,
      shelters: null,
      simulation: null
    };
    this.baseLayers = {};
    this.activeMarker = null;
    this.selectedIncident = null;
  }

  init() {
    if (this.map) return;

    // Center on Southeast Asia / Pacific Ring of Fire by default
    this.map = L.map('leafletMap', {
      center: [16.047079, 108.206230], // Da Nang / Central Vietnam
      zoom: 5,
      zoomControl: false,
      attributionControl: false
    });

    // Custom Zoom Control top-right
    L.control.zoom({ position: 'topright' }).addTo(this.map);

    // 1. ESRI World Dark Gray Canvas (Base + Labels) - 100% Free Open Map, NO API KEY, NO WATERMARK!
    const darkBase = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/{z}/{y}/{x}', {
      maxZoom: 16,
      attribution: 'Tiles &copy; Esri &mdash; Esri, DeLorme, NAVTEQ'
    });
    const darkLabels = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Reference/MapServer/tile/{z}/{y}/{x}', {
      maxZoom: 16,
      pane: 'shadowPane' // render above base
    });
    const darkGroup = L.layerGroup([darkBase, darkLabels]);

    // 2. ESRI World Imagery (High-Res True Satellite Recon) - Free, stunning satellite imagery
    const satelliteTileLayer = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
      maxZoom: 18,
      attribution: 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community'
    });

    // 3. OpenStreetMap Standard Tiles (Community Open Data)
    const osmTileLayer = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    });

    // 4. OpenTopoMap Terrain Tiles
    const topoTileLayer = L.tileLayer('https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png', {
      maxZoom: 17,
      attribution: 'Map data: &copy; OpenStreetMap contributors, SRTM | Map style: &copy; OpenTopoMap'
    });

    // Set default base layer to Tactical Dark Canvas
    darkGroup.addTo(this.map);

    this.baseLayers = {
      dark: darkGroup,
      satellite: satelliteTileLayer,
      osm: osmTileLayer,
      topo: topoTileLayer
    };

    // Initialize Layer Groups
    for (let key in this.layerGroups) {
      this.layerGroups[key] = L.layerGroup().addTo(this.map);
    }

    // Subscribe to Data Manager changes
    window.dataManager.subscribe(() => {
      this.renderIncidents();
    });

    this.renderIncidents();
    this.renderShelters();

    // Map click outside resets selection
    this.map.on('click', (e) => {
      if (!e.originalEvent.defaultPrevented) {
        // Can be used for custom ping
      }
    });

    // Invalidate map size after layout stabilizes
    setTimeout(() => {
      this.map.invalidateSize();
    }, 400);
  }

  switchBaseLayer(layerName) {
    if (!this.baseLayers[layerName]) return;
    for (let key in this.baseLayers) {
      try {
        this.map.removeLayer(this.baseLayers[key]);
      } catch (e) {}
    }
    this.map.addLayer(this.baseLayers[layerName]);
  }

  toggleLayerVisibility(groupName, isVisible) {
    if (!this.layerGroups[groupName]) return;
    if (isVisible) {
      this.map.addLayer(this.layerGroups[groupName]);
    } else {
      this.map.removeLayer(this.layerGroups[groupName]);
    }
  }

  renderIncidents() {
    // Clear incident layer groups
    this.layerGroups.earthquakes.clearLayers();
    this.layerGroups.storms.clearLayers();
    this.layerGroups.floods.clearLayers();
    this.layerGroups.wildfires.clearLayers();

    const incidents = window.dataManager.incidents;

    incidents.forEach(inc => {
      const isCritical = inc.severity === "CRITICAL";
      const isWarning = inc.severity === "WARNING";
      
      let strokeColor = "#10b981"; // Safe / green
      let fillColor = "#10b981";
      if (isCritical) {
        strokeColor = "#ef4444";
        fillColor = "#ef4444";
      } else if (isWarning) {
        strokeColor = "#f59e0b";
        fillColor = "#f59e0b";
      }

      // Radius in meters
      const radiusMeters = (inc.radiusKm || 50) * 1000;

      // 1. Impact Zone Danger Circle
      const dangerCircle = L.circle(inc.coords, {
        radius: radiusMeters,
        color: strokeColor,
        weight: 1.5,
        opacity: 0.65,
        fillColor: fillColor,
        fillOpacity: isCritical ? 0.12 : 0.06,
        dashArray: isCritical ? '6, 6' : null
      });

      // 2. Custom Pulsing Radar Marker Icon
      const customIcon = L.divIcon({
        className: 'custom-map-icon-container',
        html: `
          <div class="custom-radar-marker">
            <div class="radar-ping-ring" style="border-color: ${strokeColor}"></div>
            <div class="radar-dot" style="background: ${strokeColor}; box-shadow: 0 0 12px ${strokeColor}"></div>
          </div>
        `,
        iconSize: [32, 32],
        iconAnchor: [16, 16]
      });

      const marker = L.marker(inc.coords, { icon: customIcon });

      // Click event on marker
      marker.on('click', () => {
        this.selectIncident(inc);
      });
      dangerCircle.on('click', () => {
        this.selectIncident(inc);
      });

      // Tooltip
      marker.bindTooltip(`
        <div style="font-weight: 700; font-size: 12px; color: ${strokeColor};">${inc.title}</div>
        <div style="font-size: 11px; opacity: 0.85; font-family: monospace;">Pop at Risk: ${inc.atRiskPop} | R: ${inc.radiusKm}km</div>
      `, { offset: [0, -10], direction: 'top', className: 'tactical-tooltip' });

      // Add to corresponding layer group
      if (inc.type === 'earthquake') {
        this.layerGroups.earthquakes.addLayer(dangerCircle);
        this.layerGroups.earthquakes.addLayer(marker);
      } else if (inc.type === 'cyclone' || inc.type === 'storm') {
        this.layerGroups.storms.addLayer(dangerCircle);
        this.layerGroups.storms.addLayer(marker);
      } else if (inc.type === 'flood') {
        this.layerGroups.floods.addLayer(dangerCircle);
        this.layerGroups.floods.addLayer(marker);
      } else if (inc.type === 'wildfire') {
        this.layerGroups.wildfires.addLayer(dangerCircle);
        this.layerGroups.wildfires.addLayer(marker);
      }
    });
  }

  renderShelters() {
    this.layerGroups.shelters.clearLayers();
    const shelters = window.dataManager.shelters;

    shelters.forEach(sh => {
      const shelterIcon = L.divIcon({
        className: 'shelter-poi-marker',
        html: `
          <div style="background: #10b981; border: 2px solid #ffffff; width: 18px; height: 18px; border-radius: 4px; display: flex; align-items: center; justify-content: center; box-shadow: 0 0 10px #10b981;">
            <span style="font-size: 10px; font-weight: 900; color: #ffffff;">S</span>
          </div>
        `,
        iconSize: [20, 20],
        iconAnchor: [10, 10]
      });

      const marker = L.marker(sh.coords, { icon: shelterIcon });
      marker.bindPopup(`
        <div style="padding: 6px;">
          <div style="font-weight: 800; color: #10b981; font-size: 13px; margin-bottom: 4px;">🛡️ ${sh.name}</div>
          <div style="font-size: 11px; color: #cbd5e1; margin-bottom: 2px;">Cap: <b>${sh.capacity}</b> (${sh.status})</div>
          <div style="font-size: 11px; font-family: monospace; color: #38bdf8;">📞 ${sh.phone}</div>
        </div>
      `);
      this.layerGroups.shelters.addLayer(marker);
    });
  }

  selectIncident(inc) {
    this.selectedIncident = inc;
    this.map.flyTo(inc.coords, Math.max(this.map.getZoom(), 7), {
      duration: 1.2
    });

    if (window.app && typeof window.app.showIncidentInspector === 'function') {
      window.app.showIncidentInspector(inc);
    }
  }

  locateUser() {
    if (!navigator.geolocation) {
      alert("Geolocation is not supported by your browser");
      return;
    }
    navigator.geolocation.getCurrentPosition((pos) => {
      const coords = [pos.coords.latitude, pos.coords.longitude];
      this.map.flyTo(coords, 10, { duration: 1.5 });
      L.circleMarker(coords, {
        radius: 8,
        fillColor: '#06b6d4',
        color: '#ffffff',
        weight: 2,
        fillOpacity: 0.9
      }).addTo(this.map).bindPopup("📍 Your Current Operational Post").openPopup();
    }, (err) => {
      console.warn("Could not retrieve GPS location", err);
      // Fallback fly to Vietnam region
      this.map.flyTo([16.047, 108.206], 6);
    });
  }
}

window.tacticalMap = new TacticalMap();
