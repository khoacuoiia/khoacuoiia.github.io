# 🌍 TERRAPULSE (Địa Xung)
### Open Planetary Emergency & Climate Resilience Intelligence OS
> **Đề tài Dự thi Cuộc thi Mã Nguồn Mở Đa Quốc Gia 2026 (Global FOSS Innovation Summit & Challenge 2026)**  
> **Thí sinh đại diện:** Nhóm Sinh viên Công nghệ Việt Nam  
> **Giấy phép:** Open Source MIT License | Hoàn toàn miễn phí vì cộng đồng

---

## 📌 1. Bối cảnh & Lý do Chọn Đề tài (Problem Statement & Rationale)

Những năm gần đây, biến đổi khí hậu toàn cầu đã gây ra chuỗi thảm họa khốc liệt chưa từng có:
- **Siêu bão Yagi (2024)** tàn phá miền Bắc Việt Nam và Đông Nam Á với sức gió trên 220 km/h, gây lũ quét, cô lập hàng nghìn khu dân cư.
- Các trận **động đất hủy diệt** tại Thổ Nhĩ Kỳ - Syria, bán đảo Noto (Nhật Bản), và Đài Loan đe dọa trực tiếp hàng triệu sinh mạng.
- **Lũ quét và sạt lở đất** tại các vùng núi cao gây tê liệt hoàn toàn mạng lưới viễn thông và giao thông truyền thống.

### ⚠️ Nghịch lý công nghệ hiện nay:
Hầu hết các hệ thống GIS điều hành khẩn cấp (Emergency Operations Center - EOC) hiện nay thuộc sở hữu của các tập đoàn quốc phòng hoặc công ty phần mềm thương mại đắt đỏ (như ESRI ArcGIS Enterprise, Palantir). Các đội cứu hộ tình nguyện cơ sở, chính quyền địa phương ở các nước đang phát triển và người dân trong tâm bão **hoàn toàn không có quyền tiếp cận**.

### 💡 Tuyên ngôn của TerraPulse:
**"Cứu mạng con người không nên bị giới hạn bởi phí bản quyền phần mềm."**  
TerraPulse ra đời nhằm dân chủ hóa công nghệ cứu hộ thiên tai bằng cách kết hợp sức mạnh của **Mã Nguồn Mở (FOSS)** và **Dữ liệu Mở Toàn cầu (Open Data)** vào một hệ điều hành tác chiến trực quan trên nền web nhẹ, hoạt động mượt mà ngay cả khi đường truyền chập chờn.

---

## 🛠️ 2. Các Cấu phần Mã Nguồn Mở Thu thập & Tích hợp (FOSS Ecosystem)

TerraPulse không xây dựng lại chiếc bánh xe, mà tổng hợp và kết nối các tinh hoa mã nguồn mở hàng đầu thế giới:

| Cấu phần / Thư viện | Vai trò trong Dự án | Giấy phép | Nguồn cung cấp |
| :--- | :--- | :--- | :--- |
| **Leaflet.js (v1.9.4)** | Động cơ bản đồ tương tác hiển thị vùng nguy hiểm, chấn tiêu, và biểu tượng radar lấp lánh | BSD-2-Clause | Open Source Community |
| **ESRI Dark Canvas, World Imagery & OpenStreetMap** | Lớp bản đồ nền tối chuyên dụng cho phòng tác chiến (EOC), ảnh vệ tinh độ phân giải cao và bản đồ mở cộng đồng (100% Free, No API Key) | Open Data / Public GIS | OpenStreetMap & ESRI Open Community |
| **USGS Real-Time Earthquake GeoJSON API** | Luồng dữ liệu địa chấn thời gian thực toàn cầu từ Cục Khảo sát Địa chất Hoa Kỳ | Public Domain | USGS Hazards Program |
| **Open-Meteo Weather API** | Truy vấn trực tiếp sức gió, áp suất tâm bão, lượng mưa theo tọa độ mà không cần API Key | AGPLv3 / Open API | Open-Meteo Project |
| **Chart.js (v4.4.1)** | Trực quan hóa dữ liệu năng lượng địa chấn và radar sẵn sàng cứu trợ | MIT License | Chart.js Community |
| **Web Audio API Synth** | Còi báo động sóng âm kép (800Hz - 1200Hz) & bộ phát mã Morse SOS offline | W3C Open Standard | Native Browser API |
| **HTML5 Web Storage & Geolocation** | Lưu trữ hồ sơ cứu nạn ngoại tuyến và định vị tọa độ GPS người dùng | W3C Standard | Client-side Native |

---

## 🚀 3. Các Tính Năng Đột Phá Đưa Đi Thi Đấu

### 1️⃣ Bản đồ Tác chiến Thời gian thực (Tactical GIS Radar)
- Kết nối tự động dữ liệu động đất USGS và áp suất khí quyển Open-Meteo.
- Tính toán bán kính nguy hiểm tự động dựa trên độ Richter và độ sâu tiêu chấn.
- Lọc theo loại hình thiên tai: Động đất, Bão nhiệt đới, Lũ lụt, Cháy rừng.
- Chọn từng sự kiện để mở **Hồ sơ Tác chiến (Tactical Dossier)** với khuyến nghị phân loại cứu hộ (AI Triage).

### 2️⃣ Mạng lưới Điều phối & Phân loại Cứu trợ Nhân đạo (Crisis Dispatch Mesh)
- Hệ thống tiếp nhận tín hiệu SOS khẩn cấp phân cấp P1 (Nguy hiểm tính mạng), P2 (Cần sơ tán gấp), P3 (Tiếp tế lương thực).
- Quản lý kho phương tiện phân tán: Xuồng cao su cứu hộ, trạm phát điện dã chiến, bộ lọc nước uống sạch, thiết bị liên lạc vệ tinh Starlink.
- Cho phép cử đội cứu hộ (Dispatch Squad) với 1 cú click.

### 3️⃣ Phòng Thử nghiệm Mô phỏng Thiên tai (Judge Simulation Studio)
- Dành riêng cho **Ban Giám Khảo** thử nghiệm các tình huống khẩn cấp:
  - Tự do kéo thanh trượt cường độ Richter (4.0 - 9.5), sức gió (50 - 320 km/h), lượng mưa (10 - 800 mm).
  - Thuật toán tự động tính toán: Bán kính ảnh hưởng ($R$), ước tính dân số gặp nguy hiểm, tỷ lệ thương vong dự phóng, số lượng xuồng cứu sinh và điểm sơ tán cần huy động.
  - Nút **"Khởi chạy Mô phỏng & Chiếu lên Bản đồ"** giúp mô phỏng ngay một sự kiện thảm họa giả định trực tiếp lên bản đồ tác chiến.

### 4️⃣ Còi Báo động SOS Sóng Âm (Acoustic SOS Beacon)
- Khi người dân bị mắc kẹt dưới đống đổ nát hoặc trên nóc nhà lúc lũ về, mạng di động 4G thường tê liệt.
- TerraPulse tích hợp bộ tổng hợp dao động âm tần đa sóng phát ra âm thanh xuyên thấu cực mạnh và phát mã Morse quốc tế `... --- ...` cùng hiệu ứng nhấp nháy màn hình (Strobe Flash) làm tín hiệu định vị cho đội cứu hộ.

### 5️⃣ Tương thích Chuẩn Dữ liệu Quốc tế (UN OCHA Interoperability)
- Tích hợp tính năng trích xuất toàn bộ dữ liệu sự kiện ra định dạng chuẩn **GeoJSON** tương thích với Văn phòng Điều phối các Vấn đề Nhân đạo của Liên Hợp Quốc (UN OCHA) và Hội Chữ Thập Đỏ Quốc Tế.
- Hỗ trợ song ngữ tức thì: **Tiếng Việt 🇻🇳** và **English 🌐**.

---

## 🌿 4. Đóng Góp Vào Mục Tiêu Phát Triển Bền Vững (UN SDGs)
1. **UN SDG 11 (Sustainable Cities and Communities):** Tăng cường khả năng chống chịu rủi ro thiên tai và bảo vệ các khu vực dân cư dễ bị tổn thương.
2. **UN SDG 13 (Climate Action):** Nâng cao hiệu quả cảnh báo sớm và giáo dục cộng đồng ứng phó với hiện tượng thời tiết cực đoan.
3. **UN SDG 17 (Partnerships for the Goals):** Xây dựng cầu nối hợp tác công nghệ mã nguồn mở không biên giới.

---

## 💻 5. Hướng Dẫn Chạy Thử Ứng Dụng (Quickstart)

Ứng dụng được thiết kế theo kiến trúc **Zero-Dependency Native Web Engine** — không cần cài đặt Node.js hay Python phức tạp, chạy trực tiếp trên bất kỳ trình duyệt web hiện đại nào (Chrome, Edge, Firefox, Safari):

1. Mở thư mục dự án: `c:\BaiHTML\New folder\`
2. Nhấp đúp chuột vào file `index.html` để mở trực tiếp trong trình duyệt web (hoặc sử dụng Live Server / VS Code).
3. Trải nghiệm đầy đủ 5 phân hệ từ Bản đồ, Điều phối, Phân tích biểu đồ, Mô phỏng Sandbox đến Hồ sơ Mã nguồn mở.

---
*Dự án được xây dựng với tâm huyết cống hiến cho cộng đồng và lan tỏa tinh thần Mã Nguồn Mở Việt Nam trên đấu trường quốc tế!*
