// ===================================================================
// TERRAPULSE - Master Application Controller
// Orchestrates Map, Telemetry, Dispatch, Audio, Simulation & i18n
// ===================================================================

class AppController {
  constructor() {
    this.currentTab = 'tab-map';
    this.selectedIncident = null;
    this.activeFilter = 'all';
    this.searchQuery = '';
  }

  init() {
    // 1. Start UTC Mission Clock
    this.startMissionClock();

    // 2. Initialize Navigation Tabs
    this.setupNavigation();

    // 3. Initialize Tactical Map
    window.tacticalMap.init();

    // 4. Initialize Analytics on Demand
    window.analyticsEngine.init();

    // 5. Setup Sidebar Incident List & Filters
    this.setupSidebarFeed();

    // 6. Setup Dispatch & SOS Board
    this.setupDispatchBoard();

    // 7. Setup Simulation Sliders & Presets
    this.setupSimulationEvents();

    // 8. Setup Modals & Header Controls
    this.setupModalsAndControls();

    // 9. Initial Live USGS Fetch
    window.dataManager.fetchLiveUSGS();

    // 10. Subscribe to data changes
    window.dataManager.subscribe(() => {
      this.renderSidebarIncidents();
      this.renderDispatchBoard();
    });

    // 11. Initial Render
    this.renderSidebarIncidents();
    this.renderDispatchBoard();
    window.disasterSimulator.updateLiveOutputs();

    console.log("TerraPulse Crisis Operating System successfully armed and operational.");
  }

  startMissionClock() {
    const clockEl = document.getElementById('utcClockDisplay');
    const update = () => {
      const now = new Date();
      const utcStr = now.toISOString().slice(11, 19) + ' UTC';
      const dateStr = now.toLocaleDateString('en-GB', { day: '2-digit', month: 'short' });
      if (clockEl) {
        clockEl.innerHTML = `<span style="color: #06b6d4;">●</span> ${dateStr} ${utcStr}`;
      }
    };
    update();
    setInterval(update, 1000);
  }

  setupNavigation() {
    const tabButtons = document.querySelectorAll('.nav-tab-btn');
    tabButtons.forEach(btn => {
      btn.addEventListener('click', () => {
        const targetTab = btn.getAttribute('data-tab');
        this.switchTab(targetTab);
        window.audioBeacon.playChirp(700, 0.05);
      });
    });
  }

  switchTab(tabId) {
    this.currentTab = tabId;

    // Update button states
    document.querySelectorAll('.nav-tab-btn').forEach(btn => {
      btn.classList.toggle('active', btn.getAttribute('data-tab') === tabId);
    });

    // Update pane visibility
    document.querySelectorAll('.tab-pane').forEach(pane => {
      pane.classList.remove('active');
    });

    const activePane = document.getElementById(tabId);
    if (activePane) {
      activePane.classList.add('active');
    }

    // Trigger Leaflet resize if returning to map
    if (tabId === 'tab-map') {
      setTimeout(() => {
        window.tacticalMap.map.invalidateSize();
      }, 200);
    }

    // Re-render analytics if entering analytics tab
    if (tabId === 'tab-analytics') {
      setTimeout(() => {
        window.analyticsEngine.init();
      }, 100);
    }
  }

  setupSidebarFeed() {
    // Search input
    const searchInput = document.getElementById('incidentSearchInput');
    if (searchInput) {
      searchInput.addEventListener('input', (e) => {
        this.searchQuery = e.target.value.toLowerCase();
        this.renderSidebarIncidents();
      });
    }

    // Filter Chips
    const filterChips = document.querySelectorAll('.filter-chip');
    filterChips.forEach(chip => {
      chip.addEventListener('click', () => {
        filterChips.forEach(c => c.classList.remove('active'));
        chip.classList.add('active');
        this.activeFilter = chip.getAttribute('data-filter');
        this.renderSidebarIncidents();
        window.audioBeacon.playChirp(900, 0.04);
      });
    });

    // Refresh USGS button
    const refreshBtn = document.getElementById('refreshFeedBtn');
    if (refreshBtn) {
      refreshBtn.addEventListener('click', async () => {
        refreshBtn.innerHTML = '⟳ Fetching...';
        await window.dataManager.fetchLiveUSGS();
        refreshBtn.innerHTML = '⟳ Refresh';
        window.audioBeacon.playChirp(1200, 0.1);
      });
    }
  }

  renderSidebarIncidents() {
    const listContainer = document.getElementById('incidentsListContainer');
    if (!listContainer) return;

    let items = window.dataManager.incidents;

    // Apply Filter
    if (this.activeFilter !== 'all') {
      items = items.filter(inc => {
        if (this.activeFilter === 'earthquake') return inc.type === 'earthquake';
        if (this.activeFilter === 'storm') return inc.type === 'cyclone' || inc.type === 'storm';
        if (this.activeFilter === 'flood') return inc.type === 'flood';
        if (this.activeFilter === 'wildfire') return inc.type === 'wildfire';
        return true;
      });
    }

    // Apply Search
    if (this.searchQuery) {
      items = items.filter(inc => 
        inc.title.toLowerCase().includes(this.searchQuery) ||
        (inc.source && inc.source.toLowerCase().includes(this.searchQuery)) ||
        (inc.severity && inc.severity.toLowerCase().includes(this.searchQuery))
      );
    }

    // Update Counter
    const counterEl = document.getElementById('feedTotalCount');
    if (counterEl) counterEl.textContent = `${items.length} EVENTS`;

    if (items.length === 0) {
      listContainer.innerHTML = `
        <div style="text-align: center; padding: 40px 10px; color: #64748b;">
          <div style="font-size: 24px; margin-bottom: 8px;">🛰️</div>
          <div>No matching crisis events in active sector.</div>
        </div>
      `;
      return;
    }

    listContainer.innerHTML = items.map(inc => {
      const isSelected = this.selectedIncident && this.selectedIncident.id === inc.id;
      const typeClass = inc.type === 'cyclone' ? 'cyclone' : inc.type;
      const severityClass = inc.severity ? inc.severity.toLowerCase() : 'info';

      return `
        <div class="incident-card ${severityClass} ${isSelected ? 'selected' : ''}" data-id="${inc.id}">
          <div class="incident-header">
            <span class="incident-type-badge ${typeClass}">
              ${this.getTypeIcon(inc.type)} ${inc.type.toUpperCase()}
            </span>
            <span class="incident-time">${inc.time || 'Recent'}</span>
          </div>
          <div class="incident-title">${inc.title}</div>
          <div class="incident-meta-row">
            <span class="incident-stat">💥 Mag: <b>${inc.magnitude}</b></span>
            <span class="incident-stat">👥 Risk: <b>${inc.atRiskPop || 'N/A'}</b></span>
            <span class="incident-stat">📡 ${inc.radiusKm || 40}km</span>
          </div>
        </div>
      `;
    }).join('');

    // Attach click listeners to cards
    listContainer.querySelectorAll('.incident-card').forEach(card => {
      card.addEventListener('click', () => {
        const id = card.getAttribute('data-id');
        const inc = window.dataManager.incidents.find(i => i.id === id);
        if (inc) {
          window.tacticalMap.selectIncident(inc);
          window.audioBeacon.playChirp(850, 0.05);
        }
      });
    });
  }

  getTypeIcon(type) {
    switch (type) {
      case 'earthquake': return '⚡';
      case 'cyclone':
      case 'storm': return '🌀';
      case 'flood': return '🌊';
      case 'wildfire': return '🔥';
      default: return '⚠️';
    }
  }

  showIncidentInspector(inc) {
    this.selectedIncident = inc;
    const drawer = document.getElementById('incidentInspectorDrawer');
    if (!drawer) return;

    // Highlight selected item in sidebar
    this.renderSidebarIncidents();

    // Populate Inspector UI
    const titleEl = document.getElementById('inspectorTitle');
    const badgeEl = document.getElementById('inspectorTypeBadge');
    const gaugeEl = document.getElementById('inspectorGaugeScore');
    const gaugeTitleEl = document.getElementById('inspectorGaugeTitle');
    const gaugeDescEl = document.getElementById('inspectorGaugeDesc');
    const coordsEl = document.getElementById('inspectorCoords');
    const depthEl = document.getElementById('inspectorDepth');
    const popEl = document.getElementById('inspectorPop');
    const radiusEl = document.getElementById('inspectorRadius');
    const sourceEl = document.getElementById('inspectorSource');
    const triageEl = document.getElementById('inspectorTriageText');
    const weatherBox = document.getElementById('inspectorLiveWeatherBox');

    if (titleEl) titleEl.textContent = inc.title;
    if (badgeEl) {
      badgeEl.textContent = `${inc.type.toUpperCase()} • ${inc.severity}`;
      badgeEl.className = `incident-type-badge ${inc.type}`;
    }
    if (gaugeEl) gaugeEl.textContent = inc.magnitude;
    if (gaugeTitleEl) gaugeTitleEl.textContent = `Severity Level: ${inc.severity}`;
    if (gaugeDescEl) gaugeDescEl.textContent = `Focal depth ${inc.depth || 10}km | Threat radius ${inc.radiusKm || 50}km`;
    if (coordsEl) coordsEl.textContent = `${inc.coords[0].toFixed(3)}°N, ${inc.coords[1].toFixed(3)}°E`;
    if (depthEl) depthEl.textContent = `${inc.depth || 10} km`;
    if (popEl) popEl.textContent = inc.atRiskPop || 'Est. 450,000 citizens';
    if (radiusEl) radiusEl.textContent = `${inc.radiusKm || 50} km`;
    if (sourceEl) sourceEl.textContent = inc.source || 'Open Planetary Data Feed';
    if (triageEl) triageEl.textContent = inc.triageNotes || 'Automated triage: Deploy local reconnaissance assets and prepare evacuation transport corridors.';

    // Fetch real-time Open-Meteo weather for this incident's coordinates
    if (weatherBox) {
      weatherBox.innerHTML = `<i>🛰️ Querying Open-Meteo satellite weather telemetry...</i>`;
      window.dataManager.fetchLiveWeather(inc.coords[0], inc.coords[1]).then(res => {
        if (res.success && res.current) {
          const w = res.current;
          weatherBox.innerHTML = `
            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; font-family: var(--font-mono); font-size: 11px;">
              <div>🌡️ <b>${w.temperature_2m}°C</b></div>
              <div>💨 <b>${w.wind_speed_10m} km/h</b></div>
              <div>📊 <b>${w.surface_pressure} hPa</b></div>
            </div>
          `;
        } else {
          weatherBox.innerHTML = `<span style="color: #64748b;">Live weather sensor feed cached.</span>`;
        }
      });
    }

    drawer.classList.add('open');
  }

  closeIncidentInspector() {
    const drawer = document.getElementById('incidentInspectorDrawer');
    if (drawer) drawer.classList.remove('open');
  }

  setupDispatchBoard() {
    const btnNewSos = document.getElementById('btnNewSosHeader');
    if (btnNewSos) {
      btnNewSos.addEventListener('click', () => {
        this.openModal('sosModal');
      });
    }

    const sosForm = document.getElementById('sosBroadcastForm');
    if (sosForm) {
      sosForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const sender = document.getElementById('sosSender').value;
        const location = document.getElementById('sosLocation').value;
        const urgency = document.getElementById('sosUrgency').value;
        const victims = document.getElementById('sosVictims').value;
        const message = document.getElementById('sosMessage').value;

        window.dataManager.addSOS({
          sender,
          location,
          urgency,
          victims,
          message,
          coords: [21.028 + (Math.random() - 0.5) * 0.2, 105.854 + (Math.random() - 0.5) * 0.2] // Hanoi / Red River Delta default
        });

        this.closeModal('sosModal');
        sosForm.reset();
        window.audioBeacon.playMorseSOS();
        alert("🚨 EMERGENCY SOS BROADCASTED TO CRISIS MESH!");
      });
    }
  }

  renderDispatchBoard() {
    // 1. Render SOS Queue
    const queueContainer = document.getElementById('sosQueueContainer');
    if (queueContainer) {
      const queue = window.dataManager.sosQueue;
      queueContainer.innerHTML = queue.map(item => `
        <div class="sos-card">
          <div class="sos-card-header">
            <span class="sos-priority-tag ${item.urgency.toLowerCase()}">${item.urgency} URGENT</span>
            <span style="font-family: var(--font-mono); font-size: 11px; color: ${item.status === 'ASSIGNED' ? '#10b981' : '#f59e0b'};">
              ● ${item.status}
            </span>
          </div>
          <div class="sos-location">📍 ${item.location} &bull; <b>${item.sender}</b></div>
          <div class="sos-desc">${item.message}</div>
          <div style="font-size: 11px; color: #94a3b8;">👨‍👩‍👧‍👦 Trapped: <b>${item.victims}</b></div>
          <div class="sos-actions-row">
            <span style="font-size: 11px; color: #64748b; font-family: var(--font-mono);">
              ${new Date(item.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
            </span>
            <button class="dispatch-assign-btn" onclick="window.app.assignSOS('${item.id}')">
              ${item.status === 'ASSIGNED' ? '✓ Dispatched' : '⚡ Assign Unit'}
            </button>
          </div>
        </div>
      `).join('');
    }

    // 2. Render Resources
    const resContainer = document.getElementById('resourcesListContainer');
    if (resContainer) {
      const res = window.dataManager.resources;
      resContainer.innerHTML = res.map(item => `
        <div class="resource-item-row">
          <div class="resource-info">
            <div class="resource-icon-box">📦</div>
            <div>
              <div class="resource-name">${item.name}</div>
              <div class="resource-qty">Category: ${item.category} • Strategic Reserve: <b>${item.count}</b></div>
            </div>
          </div>
          <span class="resource-status-badge ${item.status}">
            ${item.status.toUpperCase()}
          </span>
        </div>
      `).join('');
    }
  }

  assignSOS(id) {
    window.dataManager.updateSOSStatus(id, 'ASSIGNED');
    window.audioBeacon.playChirp(1100, 0.08);
  }

  setupSimulationEvents() {
    const magSlider = document.getElementById('simMagSlider');
    const windSlider = document.getElementById('simWindSlider');
    const rainSlider = document.getElementById('simRainSlider');

    [magSlider, windSlider, rainSlider].forEach(slider => {
      if (slider) {
        slider.addEventListener('input', () => {
          window.disasterSimulator.updateLiveOutputs();
        });
      }
    });

    // Preset buttons
    document.querySelectorAll('.preset-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const presetKey = btn.getAttribute('data-preset');
        window.disasterSimulator.loadPreset(presetKey);
        window.audioBeacon.playChirp(950, 0.05);
      });
    });

    // Execute sim button
    const runSimBtn = document.getElementById('btnRunSimulation');
    if (runSimBtn) {
      runSimBtn.addEventListener('click', () => {
        window.disasterSimulator.injectToTacticalMap();
        window.audioBeacon.playChirp(1300, 0.12);
      });
    }
  }

  setupModalsAndControls() {
    // Inspector close button
    const closeInspectorBtn = document.getElementById('closeInspectorBtn');
    if (closeInspectorBtn) {
      closeInspectorBtn.addEventListener('click', () => {
        this.closeIncidentInspector();
      });
    }

    // Acoustic SOS Beacon toggle
    const sirenBtn = document.getElementById('btnAudioSiren');
    if (sirenBtn) {
      sirenBtn.addEventListener('click', () => {
        const isNowPlaying = window.audioBeacon.toggleDistressSiren();
        sirenBtn.innerHTML = isNowPlaying ? '🔊 ALARM ACTIVE (STOP)' : '🚨 Acoustic SOS Beacon';
        sirenBtn.style.background = isNowPlaying ? '#dc2626' : '';
      });
    }

    // Language toggle
    const langBtn = document.getElementById('langToggleBtn');
    if (langBtn) {
      langBtn.addEventListener('click', () => {
        const nextLang = window.i18n.getLang() === 'vi' ? 'en' : 'vi';
        window.i18n.setLanguage(nextLang);
        window.audioBeacon.playChirp(800, 0.04);
      });
    }

    // Export GeoJSON
    const exportBtn = document.getElementById('btnExportGeoJSON');
    if (exportBtn) {
      exportBtn.addEventListener('click', () => {
        window.dataManager.exportGeoJSON();
        window.audioBeacon.playChirp(1000, 0.06);
      });
    }

    // Print Field Triage Dossier
    const printBtn = document.getElementById('btnPrintDossier');
    if (printBtn) {
      printBtn.addEventListener('click', () => {
        window.print();
      });
    }

    // Layer Switcher Buttons
    document.querySelectorAll('[data-map-layer]').forEach(btn => {
      btn.addEventListener('click', () => {
        const layer = btn.getAttribute('data-map-layer');
        window.tacticalMap.switchBaseLayer(layer);
        document.querySelectorAll('[data-map-layer]').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
      });
    });

    // Layer Toggle Checkboxes
    document.querySelectorAll('[data-toggle-group]').forEach(btn => {
      btn.addEventListener('click', () => {
        const group = btn.getAttribute('data-toggle-group');
        const isActive = btn.classList.toggle('active');
        window.tacticalMap.toggleLayerVisibility(group, isActive);
      });
    });

    // Locate Me Button
    const locateBtn = document.getElementById('btnLocateMe');
    if (locateBtn) {
      locateBtn.addEventListener('click', () => {
        window.tacticalMap.locateUser();
      });
    }
  }

  openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) modal.classList.add('open');
  }

  closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) modal.classList.remove('open');
  }
}

// Global bootstrap on DOM ready
document.addEventListener('DOMContentLoaded', () => {
  window.app = new AppController();
  window.app.init();
});
