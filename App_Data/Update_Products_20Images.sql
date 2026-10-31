USE GearZoneDB;
GO

-- 1. BANG PRODUCTIMAGES
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='ProductImages' AND xtype='U')
BEGIN
    CREATE TABLE ProductImages (
        ImageID INT IDENTITY(1,1) PRIMARY KEY,
        ProductID INT NOT NULL,
        ImageURL NVARCHAR(500) NOT NULL,
        Caption NVARCHAR(200) NULL,
        DisplayOrder INT NOT NULL DEFAULT 1,
        IsMain BIT NOT NULL DEFAULT 0,
        CONSTRAINT FK_ProductImages_Products FOREIGN KEY (ProductID)
            REFERENCES Products(ProductID) ON DELETE CASCADE
    );
END
GO

-- 2. COT SPECIFICATIONS TRONG PRODUCTS
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'Specifications' AND Object_ID = Object_ID(N'Products'))
BEGIN
    ALTER TABLE Products ADD Specifications NVARCHAR(MAX) NULL;
END
GO

-- 3. CAP NHAT CATEGORIES HINH ANH DEP
UPDATE Categories SET ImageURL = N'images/products/aula-f75-1.jpg' WHERE CategoryID = 1;
UPDATE Categories SET ImageURL = N'images/products/logitech-g102-1.jpg' WHERE CategoryID = 2;
UPDATE Categories SET ImageURL = N'images/products/hyperx-stinger-1.png' WHERE CategoryID = 3;
UPDATE Categories SET ImageURL = N'images/products/ugreen-hub-1.jpg' WHERE CategoryID = 5;
GO

-- 4. CAP NHAT SAN PHAM VOI MO TA & THONG SO CHI TIET
-- SP 1: AULA F75
UPDATE Products SET
    ImageURL = N'images/products/aula-f75-1.jpg',
    Description = N'AULA F75 là bàn phím cơ gaming layout 75% thời thượng, thiết kế nhỏ gọn với 80 phím bấm nhưng vẫn giữ đầy đủ cụm phím điều hướng và núm xoay đa phương tiện kim loại tiện lợi.

Cấu trúc Gasket Mount cao cấp kết hợp 5 lớp tiêu âm chuyên nghiệp (Poron foam, IXPE switch pad, PET film, silicon bottom pad) mang đến trải nghiệm gõ êm ái, đầm chắc và âm thanh marbly thocky đặc trưng được cộng đồng bàn phím cơ đánh giá rất cao.

Sản phẩm hỗ trợ 3 chế độ kết nối linh hoạt: Bluetooth 5.0 (kết nối tối đa 3 thiết bị cùng lúc), Wireless 2.4GHz với độ trễ siêu thấp thích hợp chơi game và cáp USB Type-C bọc dù tháo rời.

Bàn phím trang bị mạch xuôi (South-facing RGB) với hơn 16.8 triệu màu cùng 16 hiệu ứng ánh sáng rực rỡ, hoàn toàn không bị cấn keycap profile Cherry. Tính năng Hot-swap toàn bộ phím cho phép bạn dễ dàng thay đổi các loại switch 3-pin / 5-pin tùy theo sở thích mà không cần hàn mạch.',
    Specifications = N'Hãng sản xuất: AULA
Model: F75
Layout: 75% (80 phím + 1 núm xoay kim loại đa năng)
Kết nối: 3 chế độ (Type-C có dây, Bluetooth 5.0, Wireless 2.4GHz)
Cấu trúc: Gasket Mount 5 lớp đệm tiêu âm
Loại Switch: LEOBOG Reaper Axis / Ice Vein Switch (Linear nhẹ mượt)
Tính năng Hot-swap: Có (hỗ trợ switch 3-pin và 5-pin, mạch xuôi South-Facing)
Keycap: PBT Double-shot, OEM Profile siêu bền, chống mài mòn bóng
Đèn nền: RGB 16.8 triệu màu với 16 chế độ hiệu ứng sống động
Dung lượng pin: 4000mAh (thời lượng dùng lên đến 17.5 giờ bật đèn, 260 giờ tắt đèn)
Kích thước: 322.7 x 143.2 x 43.1 mm
Trọng lượng: Khoảng 975g
Tương thích hệ điều hành: Windows, macOS, Android, iOS
Phụ kiện đi kèm: Cáp Type-C, đầu thu USB 2.4GHz, dụng cụ tháo keycap & switch 2-in-1, nắp che bụi trong suốt, 2 switch dự phòng, sách hướng dẫn sử dụng'
WHERE ProductID = 1;

-- SP 2: Logitech G102
UPDATE Products SET
    ImageURL = N'images/products/logitech-g102-1.jpg',
    Description = N'Logitech G102 Gen2 LIGHTSYNC là mẫu chuột gaming quốc dân được hàng triệu game thủ trên toàn thế giới tin dùng nhờ thiết kế kinh điển và hiệu năng vượt trội trong tầm giá.

Phiên bản Gen2 mang đến hệ thống đèn LED RGB LIGHTSYNC công nghệ sóng màu (Color Wave) rực rỡ, có thể tùy biến 16.8 triệu màu đồng bộ theo trò chơi hoặc nhịp điệu âm nhạc thông qua phần mềm Logitech G HUB.

Chuột được trang bị cảm biến gaming độ chính xác cao từ 200 đến 8.000 DPI, cho khả năng tracking mượt mà, phản hồi tức thì trong mọi tựa game từ bắn súng FPS (CS:GO, Valorant) đến chiến thuật MOBA (LMHT, Dota 2).

Thiết kế đối xứng công thái học kinh điển phù hợp với nhiều kiểu cầm chuột khác nhau (Palm, Claw, Fingertip). Hệ thống căng nút bằng lò xo kim loại độc quyền mang lại cảm giác click giòn giã, độ nảy tốt và giảm lực nhấn cần thiết, độ bền đạt hàng chục triệu lượt bấm.',
    Specifications = N'Hãng sản xuất: Logitech G
Model: G102 Gen2 LIGHTSYNC
Loại chuột: Chuột gaming có dây (Wired)
Cảm biến: Cảm biến quang học chơi game chuyên dụng (Gaming-grade Sensor)
Độ phân giải (DPI): 200 - 8.000 DPI (có thể điều chỉnh 5 mức trên G HUB)
Tốc độ phản hồi (Polling Rate): 1000Hz (1ms)
Số nút bấm: 6 nút có thể lập trình độc lập qua phần mềm
Hệ thống đèn LED: RGB LIGHTSYNC 16.8 triệu màu hiệu ứng sóng màu
Bộ vi xử lý: 32-bit ARM
Độ bền nút bấm: 10 triệu lượt nhấn với lò xo cơ học tensioning
Chiều dài dây cáp: 2.1m (bọc cao su dẻo chống rối, bền bỉ)
Kích thước: 116.6 x 62.15 x 38.2 mm
Trọng lượng: 85g (chỉ tính thân chuột)
Phần mềm hỗ trợ: Logitech G HUB (Windows & macOS)
Bảo hành: 24 tháng chính hãng'
WHERE ProductID = 2;

-- SP 3: HyperX Cloud Stinger 2
UPDATE Products SET
    ImageURL = N'images/products/hyperx-stinger-1.png',
    Description = N'HyperX Cloud Stinger 2 là chiếc tai nghe gaming thế hệ mới kế thừa sự thoải mái huyền thoại của dòng tai nghe Cloud lừng danh thế giới.

Với trọng lượng siêu nhẹ dưới 275g cùng đệm tai bọc mút hoạt tính (memory foam) cao cấp bọc da nhân tạo êm ái, bạn có thể đeo tai nghe suốt nhiều giờ thi đấu mà không hề cảm thấy mỏi hay áp lực lên vành tai. Chụp tai có khả năng xoay 90 độ tiện lợi để bạn dễ dàng nghỉ ngơi quanh cổ khi tạm dừng cuộc chơi.

Trang bị củ loa (driver) định hướng kích thước lớn 50mm đặt song song với tai, Cloud Stinger 2 tái tạo âm thanh không gian sống động với dải âm bass sâu trầm, âm mid rõ ràng và âm treble trong trẻo, giúp bạn lắng nghe chính xác từng bước chân kẻ địch.

Tai nghe tích hợp công nghệ âm thanh không gian DTS Headphone:X Spatial Audio (kèm mã kích hoạt bản quyền 2 năm) mang lại trải nghiệm định vị âm thanh vòm 3D chân thực. Micro xoay khử tiếng ồn tiện lợi: chỉ cần xoay mic thẳng đứng lên để tắt tiếng (Swivel-to-mute) và xoay gập xuống để giao tiếp rõ nét với đồng đội.',
    Specifications = N'Hãng sản xuất: HyperX (HP)
Model: Cloud Stinger 2
Kiểu tai nghe: Chụp tai (Over-ear), Closed-back cách âm tốt
Driver âm thanh: Dynamic 50mm với nam châm Neodymium
Dải tần số đáp ứng: 10Hz – 28kHz
Trở kháng: 32 Ω
Độ nhạy: 97.5 dBSPL/mW tại 1kHz
Âm thanh không gian: DTS Headphone:X Spatial Audio (hỗ trợ kích hoạt bản quyền 2 năm)
Loại Microphone: Micro tụ điện Electret định hướng (Bi-directional), lọc tiếng ồn
Tần số đáp ứng micro: 100Hz – 15.6kHz
Tính năng micro: Xoay thẳng lên để tắt tiếng (Swivel-to-mute)
Nút điều khiển: Con lăn chỉnh âm lượng tích hợp ngay trên ốp tai
Cổng kết nối: Jack 3.5mm (4 cực CTIA), tặng kèm cáp chia chữ Y 3.5mm cho PC
Chiều dài cáp: Cáp tai nghe 2m + Cáp chia PC 15cm
Trọng lượng: 275g
Tương thích: PC, Laptop, PlayStation 4/5, Xbox Series X/S, Nintendo Switch, Điện thoại'
WHERE ProductID = 3;

-- SP 4: Ugreen 60515 Hub 7in1
UPDATE Products SET
    ImageURL = N'images/products/ugreen-hub-1.jpg',
    Description = N'Hub chuyển đổi đa năng Ugreen 60515 (Revodok 107) là giải pháp mở rộng cổng kết nối toàn diện cho các dòng laptop thế hệ mới chỉ trang bị cổng Type-C như MacBook Pro/Air, Dell XPS, HP Envy, Lenovo ThinkPad hay Surface.

Từ 1 cổng USB-C duy nhất trên máy tính, Ugreen 60515 mở rộng thành 7 cổng kết nối chất lượng cao:
- 1 cổng HDMI hỗ trợ xuất hình ảnh độ phân giải siêu nét lên tới 4K@60Hz (hoặc 4K@30Hz tùy thiết bị xuất), hỗ trợ HDR cho hình ảnh sống động, mượt mà khi trình chiếu, làm việc hoặc giải trí.
- 1 cổng sạc nhanh USB-C Power Delivery (PD) công suất khủng lên tới 100W (sạc an toàn cho máy tính đến 85W và cấp 15W cho các cổng ngoại vi).
- 2 cổng USB-A 3.0 tốc độ cao truyền tải dữ liệu lên tới 5Gbps (nhanh gấp 10 lần USB 2.0), cho phép sao chép file phim ảnh và tài liệu nặng chỉ trong vài giây.
- Khe cắm thẻ nhớ kép SD và microSD (TF) tốc độ 104MB/s, có thể đọc và ghi đồng thời cả 2 thẻ cùng lúc, cực kỳ tiện lợi cho các nhiếp ảnh gia và nhà sáng tạo nội dung.

Vỏ hợp kim nhôm Anodized xám không gian (Space Gray) cao cấp giúp tản nhiệt vượt trội, chống bám vân tay và bảo vệ bo mạch khỏi va đập.',
    Specifications = N'Hãng sản xuất: UGREEN
Model: 60515 (Revodok 107)
Cổng đầu vào (Input): USB Type-C đực (gắn liền dây cáp bọc dù cao cấp 20cm)
Cổng đầu ra (Output - 7 cổng):
  + 1x HDMI: Độ phân giải 4K@60Hz / 4K@30Hz, Full HD 1080P@120Hz, hỗ trợ 3D, HDR
  + 1x USB-C PD 3.0: Hỗ trợ sạc nhanh công suất tối đa 100W (Input 100W, cấp máy 85W)
  + 2x USB-A 3.0: Tốc độ truyền tải dữ liệu chuẩn 5Gbps, tương thích ngược USB 2.0/1.1
  + 1x Khe đọc thẻ SD: Chuẩn SD / SDHC / SDXC tốc độ đọc đến 104MB/s
  + 1x Khe đọc thẻ Micro SD (TF): Chuẩn Micro SD / TF tốc độ đọc đến 104MB/s
Khả năng đọc thẻ: Hỗ trợ đọc ghi đồng thời cả thẻ SD và TF cùng lúc
Chất liệu vỏ: Hợp kim nhôm nguyên khối tản nhiệt nhanh, chống trầy xước
Kích thước: 115 x 35 x 12.5 mm
Trọng lượng: 80g
Tính năng an toàn: Tích hợp chip xử lý thông minh chống quá dòng, quá áp, ngắn mạch và quá nhiệt
Hệ điều hành tương thích: macOS, Windows 11/10/8, Linux, Chrome OS, iPadOS, Android (Plug and Play)'
WHERE ProductID = 4;
GO

-- 5. LAM MOI BANG PRODUCTIMAGES (5 ANH CHO MOI SAN PHAM = 20 ANH TAT CA)
DELETE FROM ProductImages;
GO

-- Anh cho SP 1 (AULA F75)
INSERT INTO ProductImages (ProductID, ImageURL, Caption, DisplayOrder, IsMain) VALUES
(1, N'images/products/aula-f75-1.jpg', N'Góc chụp chính diện bàn phím AULA F75', 1, 1),
(1, N'images/products/aula-f75-2.jpg', N'Góc nghiêng bàn phím và núm xoay kim loại', 2, 0),
(1, N'images/products/aula-f75-3.png', N'Cấu trúc Gasket Mount 5 lớp tiêu âm', 3, 0),
(1, N'images/products/aula-f75-4.png', N'Chi tiết switch LEOBOG và keycap PBT', 4, 0),
(1, N'images/products/aula-f75-5.png', N'Bàn phím trong không gian làm việc gaming', 5, 0);

-- Anh cho SP 2 (Logitech G102)
INSERT INTO ProductImages (ProductID, ImageURL, Caption, DisplayOrder, IsMain) VALUES
(2, N'images/products/logitech-g102-1.jpg', N'Chuột gaming Logitech G102 Gen2 chính diện', 1, 1),
(2, N'images/products/logitech-g102-2.png', N'Góc nghiêng trên với dải LED RGB LIGHTSYNC', 2, 0),
(2, N'images/products/logitech-g102-3.png', N'Cạnh bên với 2 nút phụ tiện lợi', 3, 0),
(2, N'images/products/logitech-g102-4.png', N'Mặt đáy với cảm biến quang học 8000 DPI và feet chuột', 4, 0),
(2, N'images/products/logitech-g102-5.jpg', N'Chi tiết tổng thể chuột trong studio', 5, 0);

-- Anh cho SP 3 (HyperX Cloud Stinger 2)
INSERT INTO ProductImages (ProductID, ImageURL, Caption, DisplayOrder, IsMain) VALUES
(3, N'images/products/hyperx-stinger-1.png', N'Tai nghe HyperX Cloud Stinger 2 chụp chính diện', 1, 1),
(3, N'images/products/hyperx-stinger-2.png', N'Chụp tai xoay 90 độ và microphone gạt tắt tiếng', 2, 0),
(3, N'images/products/hyperx-stinger-3.png', N'Góc nhìn nghiêng hiển thị đệm đầu êm ái', 3, 0),
(3, N'images/products/hyperx-stinger-4.jpg', N'Cận cảnh củ loa 50mm và đệm tai memory foam', 4, 0),
(3, N'images/products/hyperx-stinger-5.png', N'Tai nghe với phụ kiện cáp chia âm thanh cho PC', 5, 0);

-- Anh cho SP 4 (Ugreen 60515 Hub 7in1)
INSERT INTO ProductImages (ProductID, ImageURL, Caption, DisplayOrder, IsMain) VALUES
(4, N'images/products/ugreen-hub-1.jpg', N'Hub chuyển đổi Ugreen 60515 7-trong-1', 1, 1),
(4, N'images/products/ugreen-hub-2.jpg', N'Các cổng kết nối HDMI 4K, USB 3.0, khe thẻ nhớ', 2, 0),
(4, N'images/products/ugreen-hub-3.png', N'Cổng xuất hình ảnh HDMI 4K siêu nét', 3, 0),
(4, N'images/products/ugreen-hub-4.png', N'Cổng sạc USB-C PD công suất 100W', 4, 0),
(4, N'images/products/ugreen-hub-5.webp', N'Vỏ nhôm tản nhiệt nguyên khối và đầu cắm bọc dù', 5, 0);
GO

PRINT N'Cap nhat thanh cong 4 san pham voi 20 anh va thong so ky thuat chi tiet!';