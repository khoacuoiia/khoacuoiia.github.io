// ===================================================================
// TERRAPULSE - Disaster Simulation & Impact Projection Engine
// Allows judges to dynamically model scenarios & test response triage
// ===================================================================

class DisasterSimulator {
  constructor() {
    this.presets = {
      typhoon: {
        name: "Super Typhoon 'VORTEX-MAX' Landfall",
        type: "cyclone",
        coords: [20.85, 106.70], // Hai Phong coast
        mag: 8.2, // Composite
        wind: 240, // km/h
        rain: 450, // mm
        notes: "Catastrophic storm surge + flash floods across 4 coastal delta provinces."
      },
      earthquake: {
        name: "M 7.8 Continental Subduction Rupture",
        type: "earthquake",
        coords: [37.60, 36.90], // Anatolian Fault
        mag: 7.8,
        wind: 20,
        rain: 10,
        notes: "Violent surface acceleration PGA > 0.6g. High risk of multi-story concrete collapse."
      },
      flood: {
        name: "Megacity Extreme Monsoonal Flash Inundation",
        type: "flood",
        coords: [10.77, 106.69], // Ho Chi Minh City / Mekong
        mag: 6.5,
        wind: 65,
        rain: 580,
        notes: "Simultaneous high tide crest + upstream dam discharge inundating 6 urban districts."
      }
    };
  }

  calculateImpact(mag, wind, rain) {
    // Empirical physics & disaster model approximation
    const radiusKm = Math.round(
      Math.max(
        Math.pow(10, mag * 0.35) * 1.8,
        (wind / 200) * 160,
        (rain / 500) * 90
      )
    );

    // Approximate affected population (scaled logarithmically by intensity)
    const baseDensity = 1450; // people per sq km in populated deltas
    const impactArea = Math.PI * Math.pow(radiusKm * 0.4, 2);
    const affectedPop = Math.round(impactArea * baseDensity * (mag / 9.0));

    // Casualty risk index (0 - 100%)
    const casualtyRisk = Math.min(96, Math.round((mag * 6.5) + (wind * 0.15) + (rain * 0.05)));

    // Required emergency units
    const requiredBoats = Math.max(10, Math.round(affectedPop / 15000));
    const requiredShelters = Math.max(3, Math.round(affectedPop / 35000));

    return {
      radiusKm,
      affectedPop: affectedPop.toLocaleString(),
      casualtyRisk: `${casualtyRisk}%`,
      requiredBoats,
      requiredShelters,
      severityLevel: casualtyRisk > 70 ? 'CRITICAL (CODE RED)' : casualtyRisk > 40 ? 'HIGH (CODE ORANGE)' : 'MODERATE'
    };
  }

  loadPreset(key) {
    const preset = this.presets[key];
    if (!preset) return;

    const magSlider = document.getElementById('simMagSlider');
    const windSlider = document.getElementById('simWindSlider');
    const rainSlider = document.getElementById('simRainSlider');

    if (magSlider) magSlider.value = preset.mag;
    if (windSlider) windSlider.value = preset.wind;
    if (rainSlider) rainSlider.value = preset.rain;

    this.updateLiveOutputs();

    // Visual active button highlight
    document.querySelectorAll('.preset-btn').forEach(btn => btn.classList.remove('active'));
    const targetBtn = document.querySelector(`[data-preset="${key}"]`);
    if (targetBtn) targetBtn.classList.add('active');
  }

  updateLiveOutputs() {
    const mag = parseFloat(document.getElementById('simMagSlider')?.value || 7.0);
    const wind = parseFloat(document.getElementById('simWindSlider')?.value || 120);
    const rain = parseFloat(document.getElementById('simRainSlider')?.value || 150);

    const magValEl = document.getElementById('simMagVal');
    const windValEl = document.getElementById('simWindVal');
    const rainValEl = document.getElementById('simRainVal');

    if (magValEl) magValEl.textContent = mag.toFixed(1);
    if (windValEl) windValEl.textContent = `${Math.round(wind)} km/h`;
    if (rainValEl) rainValEl.textContent = `${Math.round(rain)} mm`;

    const impact = this.calculateImpact(mag, wind, rain);

    const outRadius = document.getElementById('simOutRadius');
    const outPop = document.getElementById('simOutPop');
    const outRisk = document.getElementById('simOutRisk');
    const outBoats = document.getElementById('simOutBoats');
    const outShelters = document.getElementById('simOutShelters');
    const outSeverity = document.getElementById('simOutSeverity');

    if (outRadius) outRadius.textContent = `${impact.radiusKm} km`;
    if (outPop) outPop.textContent = impact.affectedPop;
    if (outRisk) outRisk.textContent = impact.casualtyRisk;
    if (outBoats) outBoats.textContent = `${impact.requiredBoats} Units`;
    if (outShelters) outShelters.textContent = `${impact.requiredShelters} Hubs`;
    if (outSeverity) {
      outSeverity.textContent = impact.severityLevel;
      outSeverity.style.color = impact.casualtyRisk > 70 ? 'var(--status-crimson)' : 'var(--status-amber)';
    }
  }

  injectToTacticalMap() {
    const mag = parseFloat(document.getElementById('simMagSlider')?.value || 7.0);
    const wind = parseFloat(document.getElementById('simWindSlider')?.value || 120);
    const rain = parseFloat(document.getElementById('simRainSlider')?.value || 150);
    const impact = this.calculateImpact(mag, wind, rain);

    // Pick location (default center or current view)
    const lat = 20.85 + (Math.random() - 0.5) * 0.3;
    const lon = 106.70 + (Math.random() - 0.5) * 0.3;

    const simulatedIncident = {
      id: `sim-${Date.now().toString().slice(-4)}`,
      type: wind > 180 ? 'cyclone' : mag > 6.5 ? 'earthquake' : 'flood',
      title: `🚨 [SIMULATED CRISIS] M${mag.toFixed(1)} / Wind ${Math.round(wind)} km/h Event`,
      coords: [lat, lon],
      magnitude: mag.toFixed(1),
      depth: 12.0,
      severity: "CRITICAL",
      time: "Just Now (Simulated)",
      timestamp: Date.now(),
      source: "Judge Simulation Studio Sandbox",
      atRiskPop: impact.affectedPop,
      radiusKm: impact.radiusKm,
      triageNotes: `Dynamic Simulation Inject: Required ${impact.requiredBoats} boats & ${impact.requiredShelters} shelters. Projected risk index: ${impact.casualtyRisk}. Pre-emptive siren triggered.`,
      status: "active"
    };

    window.dataManager.addSimulatedIncident(simulatedIncident);

    // Switch to Map tab automatically
    if (window.app) {
      window.app.switchTab('tab-map');
    }

    setTimeout(() => {
      window.tacticalMap.selectIncident(simulatedIncident);
    }, 300);
  }
}

window.disasterSimulator = new DisasterSimulator();
