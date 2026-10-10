// ===================================================================
// TERRAPULSE - Telemetry & Analytical Data Visualizer
// Powered by Chart.js (Open Source Canvas Engine)
// ===================================================================

class AnalyticsEngine {
  constructor() {
    this.charts = {};
  }

  init() {
    this.renderSeismicEnergyChart();
    this.renderIncidentDistributionChart();
    this.renderResourceReadinessChart();
    this.renderAtmosphericTrendChart();
  }

  renderSeismicEnergyChart() {
    const ctx = document.getElementById('seismicChart');
    if (!ctx) return;

    if (this.charts.seismic) this.charts.seismic.destroy();

    // Past 7 days energy calculation
    const labels = ['Day -6', 'Day -5', 'Day -4', 'Day -3', 'Day -2', 'Yesterday', 'Today (Live)'];
    const energyData = [12.4, 8.2, 19.5, 45.1, 14.8, 88.6, 142.3]; // TeraJoules approx

    this.charts.seismic = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: 'Seismic Energy Release (TeraJoules)',
          data: energyData,
          backgroundColor: 'rgba(239, 68, 68, 0.45)',
          borderColor: '#ef4444',
          borderWidth: 2,
          borderRadius: 6
        }, {
          label: 'Cumulative Trend (Log Equivalent)',
          data: [10, 15, 25, 52, 60, 110, 190],
          type: 'line',
          borderColor: '#06b6d4',
          tension: 0.35,
          pointBackgroundColor: '#06b6d4',
          pointRadius: 4
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            labels: { color: '#cbd5e1', font: { family: 'Plus Jakarta Sans', size: 11 } }
          }
        },
        scales: {
          x: {
            grid: { color: 'rgba(255, 255, 255, 0.05)' },
            ticks: { color: '#94a3b8', font: { family: 'JetBrains Mono', size: 10 } }
          },
          y: {
            grid: { color: 'rgba(255, 255, 255, 0.05)' },
            ticks: { color: '#94a3b8', font: { family: 'JetBrains Mono', size: 10 } }
          }
        }
      }
    });
  }

  renderIncidentDistributionChart() {
    const ctx = document.getElementById('distributionChart');
    if (!ctx) return;

    if (this.charts.distribution) this.charts.distribution.destroy();

    this.charts.distribution = new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: ['Earthquakes', 'Typhoons/Storms', 'Flash Floods', 'Wildfires', 'Others'],
        datasets: [{
          data: [42, 28, 16, 10, 4],
          backgroundColor: [
            '#ef4444',
            '#06b6d4',
            '#3b82f6',
            '#f59e0b',
            '#10b981'
          ],
          borderWidth: 0,
          hoverOffset: 6
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'right',
            labels: { color: '#cbd5e1', font: { family: 'Plus Jakarta Sans', size: 11 } }
          }
        },
        cutout: '68%'
      }
    });
  }

  renderResourceReadinessChart() {
    const ctx = document.getElementById('resourceChart');
    if (!ctx) return;

    if (this.charts.resource) this.charts.resource.destroy();

    this.charts.resource = new Chart(ctx, {
      type: 'radar',
      data: {
        labels: ['Medical Packs', 'Rescue Boats', 'Generators', 'Starlink Comms', 'Water Filtration', 'Search Drones'],
        datasets: [{
          label: 'Deployed Active (%)',
          data: [65, 80, 55, 40, 75, 50],
          backgroundColor: 'rgba(6, 182, 212, 0.25)',
          borderColor: '#06b6d4',
          pointBackgroundColor: '#06b6d4',
          pointBorderColor: '#fff',
          pointHoverBackgroundColor: '#fff',
          pointHoverBorderColor: '#06b6d4'
        }, {
          label: 'Strategic Reserve (%)',
          data: [100, 100, 100, 100, 100, 100],
          borderColor: 'rgba(255, 255, 255, 0.15)',
          borderDash: [5, 5],
          fill: false,
          pointRadius: 0
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            labels: { color: '#cbd5e1', font: { family: 'Plus Jakarta Sans', size: 11 } }
          }
        },
        scales: {
          r: {
            angleLines: { color: 'rgba(255, 255, 255, 0.08)' },
            grid: { color: 'rgba(255, 255, 255, 0.08)' },
            pointLabels: { color: '#cbd5e1', font: { family: 'Plus Jakarta Sans', size: 10 } },
            ticks: { display: false }
          }
        }
      }
    });
  }

  renderAtmosphericTrendChart() {
    const ctx = document.getElementById('atmosphericChart');
    if (!ctx) return;

    if (this.charts.atmospheric) this.charts.atmospheric.destroy();

    const hours = ['00:00', '03:00', '06:00', '09:00', '12:00', '15:00', '18:00', '21:00'];
    const pressureHpa = [1008, 1004, 998, 990, 975, 960, 968, 982]; // Deep low pressure cyclone eye
    const windGustsKm = [45, 60, 85, 120, 185, 220, 195, 140];

    this.charts.atmospheric = new Chart(ctx, {
      type: 'line',
      data: {
        labels: hours,
        datasets: [{
          label: 'Central Pressure (hPa)',
          data: pressureHpa,
          borderColor: '#a855f7',
          backgroundColor: 'rgba(168, 85, 247, 0.1)',
          fill: true,
          tension: 0.4,
          yAxisID: 'y'
        }, {
          label: 'Peak Wind Gusts (km/h)',
          data: windGustsKm,
          borderColor: '#f59e0b',
          tension: 0.4,
          borderDash: [4, 4],
          yAxisID: 'y1'
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            labels: { color: '#cbd5e1', font: { family: 'Plus Jakarta Sans', size: 11 } }
          }
        },
        scales: {
          x: {
            grid: { color: 'rgba(255, 255, 255, 0.05)' },
            ticks: { color: '#94a3b8', font: { family: 'JetBrains Mono', size: 10 } }
          },
          y: {
            type: 'linear',
            display: true,
            position: 'left',
            grid: { color: 'rgba(255, 255, 255, 0.05)' },
            ticks: { color: '#a855f7', font: { family: 'JetBrains Mono', size: 10 } }
          },
          y1: {
            type: 'linear',
            display: true,
            position: 'right',
            grid: { drawOnChartArea: false },
            ticks: { color: '#f59e0b', font: { family: 'JetBrains Mono', size: 10 } }
          }
        }
      }
    });
  }
}

window.analyticsEngine = new AnalyticsEngine();
