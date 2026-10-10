// ===================================================================
// TERRAPULSE - Internationalization (i18n) Engine
// Supports English & Tiếng Việt for Multinational Competition Jury
// ===================================================================

const i18nData = {
  en: {
    appTitle: "TERRAPULSE",
    appSubtitle: "Open Planetary Emergency & Climate Resilience Intelligence OS",
    badgeCompetition: "GLOBAL FOSS 2026",
    statusLive: "SYSTEM ACTIVE • REAL-TIME MESH",
    
    // Navigation
    tabMap: "Tactical Radar",
    tabDispatch: "Crisis Dispatch",
    tabAnalytics: "Telemetry & Charts",
    tabSandbox: "Simulation Studio",
    tabDossier: "Open Source Dossier",

    // Header actions
    btnSosAudio: "Acoustic SOS Beacon",
    btnNewSos: "+ Broadcast SOS",
    
    // Map View
    sidebarTitle: "Global Crisis Incidents",
    searchPlaceholder: "Search location, magnitude, event...",
    filterAll: "All Events",
    filterEarthquake: "Seismic",
    filterStorm: "Storms/Typhoons",
    filterFlood: "Floods",
    filterWildfire: "Wildfires",
    
    // Inspector
    inspectorTitle: "Incident Tactical Dossier",
    inspectorSeverity: "Severity Index",
    inspectorPopulation: "Estimated At-Risk Pop:",
    inspectorEvacRadius: "Immediate Danger Zone:",
    inspectorCoords: "Coordinates:",
    inspectorDepth: "Focal Depth:",
    inspectorMagnitude: "Magnitude:",
    inspectorSource: "Data Authority:",
    inspectorTriage: "AI Triage Recommendation",
    btnDispatchDrone: "Dispatch Recon Drone",
    btnBroadcastAlert: "Push Local Broadcast",
    
    // Dispatch Board
    dispatchHeader: "Humanitarian Resource & Incident Triage Mesh",
    dispatchSub: "Peer-to-peer open resource matching and community response coordination.",
    statActiveSos: "Active SOS Alerts",
    statDeployedUnits: "Deployed Units",
    statSheltersOpen: "Open Shelters",
    statPopAssisted: "Citizens Assisted",
    panelSosQueue: "Live Distress Signal Queue",
    panelResources: "Distributed Emergency Inventory",
    btnAssignTeam: "Dispatch Unit",
    
    // Sandbox
    sandboxTitle: "Interactive Disaster Simulation Studio",
    sandboxDesc: "Simulate extreme geophysical & atmospheric crises in real-time. Calculate casualty projections, impact radius, and test automated evacuation triage protocols for competition evaluation.",
    sliderMag: "Seismic Magnitude (Richter):",
    sliderWind: "Sustained Wind Speed (km/h):",
    sliderRain: "Rainfall Intensity (mm/24h):",
    btnRunSim: "Execute Simulation & Map Projection",
    btnResetSim: "Reset Telemetry",

    // Dossier
    pitchBadge: "GLOBAL FOSS INNOVATION CHALLENGE 2026",
    pitchTitle: "TerraPulse: Democratizing Disaster Intelligence for Every Community",
    pitchLead: "A 100% open-source, edge-first planetary emergency intelligence operating system. Integrating USGS seismic telemetry, Open-Meteo atmospheric radar, OpenStreetMap geospatial routing, and on-device AI triage to bridge the survival divide."
  },
  vi: {
    appTitle: "TERRAPULSE",
    appSubtitle: "Hệ điều hành Giám sát Cứu hộ Thiên tai & Ứng phó Khí hậu Mở",
    badgeCompetition: "MÃ NGUỒN MỞ QUỐC TẾ 2026",
    statusLive: "HỆ THỐNG TRỰC TUYẾN • DỮ LIỆU THỜI GIAN THỰC",

    // Navigation
    tabMap: "Bản đồ Tác chiến",
    tabDispatch: "Điều phối Cứu trợ",
    tabAnalytics: "Phân tích & Biểu đồ",
    tabSandbox: "Mô phỏng Thảm họa",
    tabDossier: "Hồ sơ Mã nguồn Mở",

    // Header actions
    btnSosAudio: "Còi Báo động SOS",
    btnNewSos: "+ Phát Tín hiệu SOS",

    // Map View
    sidebarTitle: "Sự kiện Thiên tai Toàn cầu",
    searchPlaceholder: "Tìm kiếm vị trí, cường độ, loại hình...",
    filterAll: "Tất cả",
    filterEarthquake: "Động đất",
    filterStorm: "Bão nhiệt đới",
    filterFlood: "Lũ lụt",
    filterWildfire: "Cháy rừng",

    // Inspector
    inspectorTitle: "Hồ sơ Tác chiến Sự kiện",
    inspectorSeverity: "Chỉ số Nghiêm trọng",
    inspectorPopulation: "Dân số vùng nguy hiểm:",
    inspectorEvacRadius: "Bán kính sơ tán khẩn:",
    inspectorCoords: "Tọa độ GPS:",
    inspectorDepth: "Độ sâu tiêu chấn:",
    inspectorMagnitude: "Cường độ:",
    inspectorSource: "Nguồn dữ liệu:",
    inspectorTriage: "Khuyến nghị Phân loại Cứu hộ (AI)",
    btnDispatchDrone: "Điều phối Drone Trinh sát",
    btnBroadcastAlert: "Phát loa Cảnh báo Khu vực",

    // Dispatch Board
    dispatchHeader: "Mạng lưới Điều phối & Phân loại Cứu trợ Nhân đạo",
    dispatchSub: "Kết nối tài nguyên cứu trợ cộng đồng ngang hàng P2P và điều phối đội cứu hộ tại chỗ.",
    statActiveSos: "Tín hiệu SOS Đang chờ",
    statDeployedUnits: "Đội Cứu hộ Triển khai",
    statSheltersOpen: "Điểm Trú ẩn Mở",
    statPopAssisted: "Người dân Được hỗ trợ",
    panelSosQueue: "Hàng đợi Tín hiệu Khẩn cấp",
    panelResources: "Kho Tài nguyên & Phương tiện Phân tán",
    btnAssignTeam: "Cử Đội cứu hộ",

    // Sandbox
    sandboxTitle: "Phòng Thử nghiệm Mô phỏng Thiên tai Tương tác",
    sandboxDesc: "Mô phỏng các kịch bản siêu bão, động đất lớn và ngập lụt đô thị theo thời gian thực. Tính toán tổn thất giả định, bán kính ảnh hưởng và kiểm thử quy trình điều phối phục vụ ban giám khảo chấm thi.",
    sliderMag: "Cường độ Động đất (Richter):",
    sliderWind: "Sức gió duy trì (km/h):",
    sliderRain: "Lượng mưa đo được (mm/24h):",
    btnRunSim: "Khởi chạy Mô phỏng & Chiếu lên Bản đồ",
    btnResetSim: "Đặt lại Dữ liệu",

    // Dossier
    pitchBadge: "CUỘC THI MÃ NGUỒN MỞ ĐA QUỐC GIA 2026",
    pitchTitle: "TerraPulse: Dân chủ hóa Công nghệ Cứu hộ Khẩn cấp cho Mọi Cộng đồng",
    pitchLead: "Hệ thống chỉ huy cứu nạn và cảnh báo thiên tai 100% mã nguồn mở. Kết hợp dữ liệu USGS, Open-Meteo, bản đồ OpenStreetMap và thuật toán AI phân loại cục bộ tại thiết bị để cứu sống người dân trong thảm họa."
  }
};

let currentLang = 'vi'; // Default to Vietnamese for our roleplay student presentation, with 1-click toggle to EN

function setLanguage(lang) {
  if (!i18nData[lang]) return;
  currentLang = lang;
  
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (i18nData[lang][key]) {
      if (el.tagName === 'INPUT' && el.placeholder !== undefined) {
        el.placeholder = i18nData[lang][key];
      } else {
        el.textContent = i18nData[lang][key];
      }
    }
  });

  const langBtn = document.getElementById('langToggleBtn');
  if (langBtn) {
    langBtn.innerHTML = lang === 'vi' ? '🇻🇳 VI' : '🌐 EN';
  }
}

function t(key) {
  return (i18nData[currentLang] && i18nData[currentLang][key]) || key;
}

window.i18n = { setLanguage, t, getLang: () => currentLang };
