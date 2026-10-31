-- =============================================
-- GEARZONE DATABASE - MASTER DATABASE SCRIPT
-- SQL Server 2022
-- Bao gom: Schema day du, 9 Danh muc, 90 San pham, 446 Hinh anh
-- =============================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'GearZoneDB')
BEGIN
    CREATE DATABASE GearZoneDB;
END
GO

USE GearZoneDB;
GO

-- =============================================
-- BANG USERS
-- =============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Users' AND xtype='U')
BEGIN
    CREATE TABLE Users (
        UserID INT IDENTITY(1,1) PRIMARY KEY,
        Username NVARCHAR(50) NOT NULL UNIQUE,
        Email NVARCHAR(100) NOT NULL UNIQUE,
        PasswordHash NVARCHAR(256) NOT NULL,
        FullName NVARCHAR(100) NOT NULL,
        Phone NVARCHAR(20) NULL,
        Address NVARCHAR(500) NULL,
        CreatedDate DATETIME DEFAULT GETDATE()
    );
END
GO

-- =============================================
-- BANG CATEGORIES
-- =============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Categories' AND xtype='U')
BEGIN
    CREATE TABLE Categories (
        CategoryID INT IDENTITY(1,1) PRIMARY KEY,
        CategoryName NVARCHAR(100) NOT NULL,
        Description NVARCHAR(500) NULL,
        ImageURL NVARCHAR(500) NULL
    );
END
GO

-- =============================================
-- BANG PRODUCTS
-- =============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Products' AND xtype='U')
BEGIN
    CREATE TABLE Products (
        ProductID INT IDENTITY(1,1) PRIMARY KEY,
        ProductName NVARCHAR(200) NOT NULL,
        Description NVARCHAR(MAX) NULL,
        Price DECIMAL(18,0) NOT NULL CHECK (Price >= 0),
        Stock INT NOT NULL DEFAULT 0 CHECK (Stock >= 0),
        ImageURL NVARCHAR(500) NULL,
        CategoryID INT NOT NULL,
        CreatedDate DATETIME DEFAULT GETDATE(),
        IsActive BIT DEFAULT 1,
        Specifications NVARCHAR(MAX) NULL,
        CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID)
            REFERENCES Categories(CategoryID)
    );
END
GO

-- Neu cot Specifications chua ton tai thi them vao
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'Specifications' AND Object_ID = Object_ID(N'Products'))
BEGIN
    ALTER TABLE Products ADD Specifications NVARCHAR(MAX) NULL;
END
GO

-- =============================================
-- BANG PRODUCTIMAGES
-- =============================================
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

-- =============================================
-- BANG ORDERS
-- =============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Orders' AND xtype='U')
BEGIN
    CREATE TABLE Orders (
        OrderID INT IDENTITY(1,1) PRIMARY KEY,
        UserID INT NOT NULL,
        OrderDate DATETIME DEFAULT GETDATE(),
        TotalAmount DECIMAL(18,0) NOT NULL,
        ShippingName NVARCHAR(100) NOT NULL,
        ShippingPhone NVARCHAR(20) NOT NULL,
        ShippingAddress NVARCHAR(500) NOT NULL,
        Status NVARCHAR(50) DEFAULT N'Chá» xá»­ lĂ½',
        CONSTRAINT FK_Orders_Users FOREIGN KEY (UserID)
            REFERENCES Users(UserID)
    );
END
GO

-- =============================================
-- BANG ORDERDETAILS
-- =============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='OrderDetails' AND xtype='U')
BEGIN
    CREATE TABLE OrderDetails (
        OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
        OrderID INT NOT NULL,
        ProductID INT NOT NULL,
        Quantity INT NOT NULL CHECK (Quantity > 0),
        UnitPrice DECIMAL(18,0) NOT NULL,
        CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (OrderID)
            REFERENCES Orders(OrderID) ON DELETE CASCADE,
        CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (ProductID)
            REFERENCES Products(ProductID)
    );
END
GO

-- =============================================
-- KHOI TAO DU LIEU USERS & CATEGORIES
-- =============================================

-- Xoa du lieu cu
DELETE FROM OrderDetails;
DELETE FROM Orders;
DELETE FROM ProductImages;
DELETE FROM Products;
DELETE FROM Categories;
DELETE FROM Users;
GO

DBCC CHECKIDENT ('Users', RESEED, 0);
DBCC CHECKIDENT ('Categories', RESEED, 0);
DBCC CHECKIDENT ('Products', RESEED, 0);
DBCC CHECKIDENT ('ProductImages', RESEED, 0);
GO

-- ===== USERS (mat khau: 123456 da bam SHA256) =====
INSERT INTO Users (Username, Email, PasswordHash, FullName, Phone, Address) VALUES
(N'admin', N'admin@gearzone.com', N'8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'Quáº£n trá»‹ viĂªn', N'0901234567', N'123 Nguyá»…n VÄƒn Linh, Q.7, TP.HCM'),
(N'user1', N'user1@gmail.com', N'8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', N'Nguyá»…n VÄƒn A', N'0912345678', N'456 LĂª Lá»£i, Q.1, TP.HCM');
GO

-- ===== CATEGORIES =====
INSERT INTO Categories (CategoryName, Description, ImageURL) VALUES
(N'BĂ n phĂ­m', N'BĂ n phĂ­m cÆ¡, membrane, gaming, vÄƒn phĂ²ng', N'images/products/ban-phim/sp01-aula-f75/main.jpg'),
(N'Chuá»™t', N'Chuá»™t gaming, vÄƒn phĂ²ng, khĂ´ng dĂ¢y', N'images/products/chuot/sp11-logitech-g102/main.jpg'),
(N'Tai nghe', N'Tai nghe gaming, bluetooth, in-ear', N'images/products/tai-nghe/sp21-hyperx-stinger-2/main.png'),
(N'Webcam', N'Webcam HD, Full HD cho há»c táº­p vĂ  há»p online', N'images/products/webcam/sp31-logitech-c920/main.jpg'),
(N'Hub & CĂ¡p', N'Hub USB, USB-C, cĂ¡p chuyá»ƒn Ä‘á»•i', N'images/products/hub-cap/sp41-ugreen-60515/main.jpg'),
(N'GiĂ¡ Ä‘á»¡ Laptop', N'GiĂ¡ Ä‘á»¡ nhĂ´m, gá»—, cĂ³ quáº¡t táº£n nhiá»‡t', N'images/products/gia-do-laptop/sp51-gia-do-n3/main.jpg'),
(N'Äáº¿ táº£n nhiá»‡t', N'Äáº¿ táº£n nhiá»‡t laptop cĂ¡c loáº¡i', N'images/products/de-tan-nhiet/sp61-cm-notepal-xslim/main.jpg'),
(N'Loa', N'Loa vi tĂ­nh, loa bluetooth mini', N'images/products/loa/sp71-edifier-r1280db/main.jpg'),
(N'Thiáº¿t bá»‹ lÆ°u trá»¯', N'USB, á»• cá»©ng di Ä‘á»™ng, tháº» nhá»›', N'images/products/thiet-bi-luu-tru/sp81-kingston-xs1000/main.jpg');
GO

-- ========================================================
-- GEARZONE - CAP NHAT TOAN BO 90 SAN PHAM & 9 DANH MUC
-- Du lieu chuan xac thuc te, day du mo ta, thong so, hinh anh offline
-- ========================================================
USE GearZoneDB;
GO

-- 1. CAP NHAT ANH DAI DIEN CHO 9 DANH MUC
UPDATE Categories SET ImageURL = N'images/products/ban-phim/sp01-aula-f75/main.jpg' WHERE CategoryID = 1;
UPDATE Categories SET ImageURL = N'images/products/chuot/sp11-logitech-g102/main.jpg' WHERE CategoryID = 2;
UPDATE Categories SET ImageURL = N'images/products/tai-nghe/sp21-hyperx-stinger-2/main.png' WHERE CategoryID = 3;
UPDATE Categories SET ImageURL = N'images/products/webcam/sp31-logitech-c920/main.jpg' WHERE CategoryID = 4;
UPDATE Categories SET ImageURL = N'images/products/hub-cap/sp41-ugreen-60515/main.jpg' WHERE CategoryID = 5;
UPDATE Categories SET ImageURL = N'images/products/gia-do-laptop/sp51-gia-do-n3/main.jpg' WHERE CategoryID = 6;
UPDATE Categories SET ImageURL = N'images/products/de-tan-nhiet/sp61-cm-notepal-xslim/main.jpg' WHERE CategoryID = 7;
UPDATE Categories SET ImageURL = N'images/products/loa/sp71-edifier-r1280db/main.jpg' WHERE CategoryID = 8;
UPDATE Categories SET ImageURL = N'images/products/thiet-bi-luu-tru/sp81-kingston-xs1000/main.jpg' WHERE CategoryID = 9;
GO

-- 2. CAP NHAT THONG TIN 4 SAN PHAM HIEN CO (IDs 1, 2, 3, 4)
-- SP 1: AULA F75 – Bàn phím cơ gaming 75%
UPDATE Products SET
    ProductName = N'AULA F75 – Bàn phím cơ gaming 75%',
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
Phụ kiện đi kèm: Cáp Type-C, đầu thu USB 2.4GHz, dụng cụ tháo keycap & switch 2-in-1, nắp che bụi trong suốt, 2 switch dự phòng, sách hướng dẫn sử dụng',
    Price = 850000,
    Stock = 15,
    ImageURL = N'images/products/ban-phim/sp01-aula-f75/main.jpg',
    CategoryID = 1,
    IsActive = 1
WHERE ProductID = 1;

-- SP 2: Chuột Logitech G102 Gen2 LIGHTSYNC
UPDATE Products SET
    ProductName = N'Chuột Logitech G102 Gen2 LIGHTSYNC',
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
Bảo hành: 24 tháng chính hãng',
    Price = 350000,
    Stock = 25,
    ImageURL = N'images/products/chuot/sp11-logitech-g102/main.jpg',
    CategoryID = 2,
    IsActive = 1
WHERE ProductID = 2;

-- SP 3: Tai nghe HyperX Cloud Stinger 2
UPDATE Products SET
    ProductName = N'Tai nghe HyperX Cloud Stinger 2',
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
Tương thích: PC, Laptop, PlayStation 4/5, Xbox Series X/S, Nintendo Switch, Điện thoại',
    Price = 790000,
    Stock = 10,
    ImageURL = N'images/products/tai-nghe/sp21-hyperx-stinger-2/main.png',
    CategoryID = 3,
    IsActive = 1
WHERE ProductID = 3;

-- SP 4: Hub USB-C 7in1 Ugreen 60515
UPDATE Products SET
    ProductName = N'Hub USB-C 7in1 Ugreen 60515',
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
Hệ điều hành tương thích: macOS, Windows 11/10/8, Linux, Chrome OS, iPadOS, Android (Plug and Play)',
    Price = 520000,
    Stock = 20,
    ImageURL = N'images/products/hub-cap/sp41-ugreen-60515/main.jpg',
    CategoryID = 5,
    IsActive = 1
WHERE ProductID = 4;

GO

-- 3. XOA DU LIEU THUA VA CHEN SAN PHAM MOI (IDs 5 den 90)
DELETE FROM OrderDetails WHERE ProductID > 4;
DELETE FROM ProductImages;
DELETE FROM Products WHERE ProductID > 4;
GO

SET IDENTITY_INSERT Products ON;
GO
-- SP 5: Bàn phím cơ Akko 3087 v2 Steam Engine
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (5, N'Bàn phím cơ Akko 3087 v2 Steam Engine', N'Bàn phím cơ Akko 3087 v2 Steam Engine mang phong cách thiết kế Retro công nghiệp cổ điển lấy cảm hứng từ những cỗ máy hơi nước thế kỷ 19, kết hợp tông màu kem cổ điển, xám đậm và cam rực rỡ tạo điểm nhấn ấn tượng cho mọi góc làm việc.

Sản phẩm sở hữu layout Tenkeyless (TKL) 87 phím tiêu chuẩn, lược bỏ cụm phím số bên phải giúp tối ưu không gian di chuột cho game thủ bắn súng FPS và dễ dàng cất vào balo khi di chuyển.

Bàn phím trang bị bộ keycap PBT Dye-subbed cao cấp profile OEM với độ bền vượt trội, bề mặt nhám mịn chống bám dầu mồ hôi tay và không bao giờ bị phai mờ ký tự theo thời gian.

Sử dụng thế hệ Akko Switch v2 được tinh chỉnh mượt mà, lò xo đàn hồi đều cùng lớp lót tiêu âm EVA Foam giảm thiểu tiếng vang rỗng của vỏ phím, mang lại âm gõ chắc nịch và đồng đều trên từng nút bấm.', 1390000, 20, N'images/products/ban-phim/sp02-akko-3087-steam-engine/main.png', 1, GETDATE(), 1, N'Hãng sản xuất: Akko
Model: 3087 v2 Steam Engine
Layout: Tenkeyless 87 phím chuẩn ANSI
Kết nối: USB Type-C có dây (dây cáp rời bọc dù chắc chắn)
Loại Switch: Akko Switch v2 (Pink / Orange / Blue switch)
Độ bền Switch: 50 triệu lần nhấn
Chất liệu Keycap: PBT Dye-subbed cao cấp
Profile Keycap: OEM Profile
Đệm tiêu âm: Lớp lót EVA Foam tích hợp sẵn đáy bàn phím
Tính năng Rollover: N-Key Rollover chống gối phím 100%
Chân đế: Chỉnh 2 nấc độ cao công thái học
Kích thước: 359 x 140 x 41 mm
Trọng lượng: Khoảng 950g
Hệ điều hành hỗ trợ: Windows, macOS, Linux');

-- SP 6: Bàn phím không dây Logitech K380 Multi-Device
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (6, N'Bàn phím không dây Logitech K380 Multi-Device', N'Logitech K380 Multi-Device là chiếc bàn phím không dây Bluetooth nhỏ gọn quốc dân dành cho dân văn phòng, học sinh sinh viên và những người thường xuyên làm việc di động trên nhiều thiết bị.

Thiết kế phím bấm bo tròn dạng Scissor-switch (cắt kéo) êm ái, khoảng cách phím tối ưu giúp ngón tay gõ chính xác, nhẹ nhàng và hầu như không gây tiếng ồn trong môi trường văn phòng yên tĩnh hay quán cà phê.

Điểm sáng nổi bật của Logitech K380 là khả năng kết nối đồng thời với 3 thiết bị khác nhau (laptop, máy tính bảng, điện thoại) và chuyển đổi tức thì chỉ bằng một nút bấm Easy-Switch đánh số 1-2-3 màu vàng nổi bật.

Bàn phím tự động nhận diện hệ điều hành và gán phím tắt phù hợp cho cả Windows, macOS, iPadOS, iOS và Android. Thời lượng pin cực khủng lên tới 2 năm chỉ với 2 viên pin AAA đi kèm.', 599000, 35, N'images/products/ban-phim/sp03-logitech-k380/main.png', 1, GETDATE(), 1, N'Hãng sản xuất: Logitech
Model: K380 Multi-Device Bluetooth Keyboard
Loại bàn phím: Bàn phím không dây văn phòng siêu mỏng
Kết nối: Bluetooth Low Energy (Bluetooth 3.2 / 4.0)
Khoảng cách kết nối: Lên đến 10 mét
Số thiết bị kết nối cùng lúc: 3 thiết bị với 3 nút Easy-Switch chuyển đổi nhanh
Cơ chế phím: Phím cắt kéo Scissor-switch hành trình thấp êm ái
Thời lượng pin: Lên đến 24 tháng (sử dụng 2 viên pin AAA)
Kích thước: 279 x 124 x 16 mm
Trọng lượng: 423g (bao gồm cả pin)
Tương thích: Windows 10/11, macOS 10.15+, iPadOS 14+, iOS 14+, Android 8+, Chrome OS');

-- SP 7: Bàn phím cơ Keychron K2 Version 2 Wireless
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (7, N'Bàn phím cơ Keychron K2 Version 2 Wireless', N'Keychron K2 Version 2 là chiếc bàn phím cơ không dây layout compact 75% (84 phím) đình đám, tối ưu hóa tối đa cho người dùng hệ sinh thái macOS và Windows với đầy đủ hàng phím chức năng media.

Phiên bản V2 được cải tiến khung viền vát nghiêng 9 độ công thái học giúp cổ tay thoải mái khi gõ lâu, đồng thời trang bị tùy chọn Hot-swap cho phép thay đổi switch cơ học dễ dàng theo sở thích cá nhân.

Bàn phím hỗ trợ cả kết nối không dây Bluetooth 5.1 kết nối tối đa 3 thiết bị và chế độ cắm dây Type-C. Nút gạt chuyển đổi hệ điều hành Mac/Windows tiện lợi ở cạnh bên.

Trang bị viên pin dung lượng lớn 4000mAh cho thời gian sử dụng liên tục lên đến 72 giờ khi bật đèn nền LED hoặc lên đến 240 giờ khi tắt đèn, sẵn sàng đồng hành cùng bạn suốt cả tuần làm việc.', 1890000, 18, N'images/products/ban-phim/sp04-keychron-k2-v2/main.jpg', 1, GETDATE(), 1, N'Hãng sản xuất: Keychron
Model: K2 Version 2
Layout: 75% Compact (84 phím bấm)
Kết nối: Bluetooth 5.1 và cáp USB Type-C tháo rời
Loại Switch: Gateron G Pro Switch (Red / Brown / Blue)
Tính năng Hot-swap: Có (hỗ trợ switch 3-pin và 5-pin MX)
Đèn nền: LED White / RGB đa hiệu ứng
Dung lượng pin: 4000mAh Lithium Polymer
Thời gian hoạt động: Đến 240 giờ (tắt đèn) / 72 giờ (bật đèn)
Thời gian sạc: Khoảng 3 giờ
Chất liệu khung: Khung nhôm cao cấp / nhựa ABS gia cố
Kích thước: 317 x 129 x 38.5 mm
Trọng lượng: Khoảng 790g
Tương thích: macOS, Windows, iOS, Android');

-- SP 8: Bàn phím cơ Razer BlackWidow V4 X
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (8, N'Bàn phím cơ Razer BlackWidow V4 X', N'Razer BlackWidow V4 X là mẫu bàn phím cơ gaming full-size hiệu năng cao được thiết kế cho các game thủ chuyên nghiệp đòi hỏi độ phản hồi tức thì và khả năng macro tùy biến tối đa trong từng trận đấu.

Bàn phím trang bị 6 phím macro chuyên dụng ở cạnh trái cùng con lăn điều khiển âm lượng đa phương tiện tiện lợi, cho phép kích hoạt nhanh các combo chiêu thức phức tạp mà không gián đoạn trò chơi.

Sử dụng Razer Mechanical Switches độc quyền thế hệ mới với vỏ trong suốt giúp tản sáng Chroma RGB rực rỡ, độ bền lên đến 100 triệu lần nhấn và cảm giác nhấn clicky hoặc linear chính xác tuyệt đối.

Khung bàn phím hoàn thiện từ hợp kim nhôm 5052 cao cấp gia cường độ cứng cáp, bên trong tích hợp lớp đệm tiêu âm PCB foam giảm thiểu tiếng vọng kim loại khi thi đấu cường độ cao.', 2890000, 12, N'images/products/ban-phim/sp05-razer-blackwidow-v4-x/main.png', 1, GETDATE(), 1, N'Hãng sản xuất: Razer
Model: BlackWidow V4 X
Layout: Fullsize 104 phím + 6 phím Macro chuyên dụng
Kết nối: USB-A có dây bọc dù chống đứt gãy
Loại Switch: Razer Green Switch (Clicky) / Razer Yellow Switch (Linear)
Độ bền Switch: 100 triệu lần nhấn
Đèn nền: Razer Chroma RGB 16.8 triệu màu từng phím
Phím Macro: 6 nút macro lập trình độc lập ở cạnh trái
Núm xoay đa năng: Con lăn kim loại điều chỉnh âm lượng mượt mà
Chất liệu Keycap: ABS Doubleshot bền bỉ
Tần số gửi tín hiệu (Polling rate): 8000Hz (0.125ms)
Kích thước: 466 x 152 x 44 mm
Trọng lượng: Khoảng 1130g
Phần mềm hỗ trợ: Razer Synapse 3');

-- SP 9: Bàn phím cơ DareU EK87 Multi-LED
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (9, N'Bàn phím cơ DareU EK87 Multi-LED', N'DareU EK87 là chiếc bàn phím cơ gaming phân khúc giá rẻ được yêu thích hàng đầu tại thị trường Việt Nam, lựa chọn số một cho học sinh, sinh viên và các phòng net gaming nhờ độ bền bỉ vượt trội.

Thiết kế layout Tenkeyless 87 phím nhỏ gọn, giải phóng diện tích bàn học và làm việc, giúp góc máy trở nên gọn gàng và thuận tiện cho các thao tác vẩy chuột trong game eSports.

Bàn phím sử dụng switch cơ học ''D'' Switch do DareU tự nghiên cứu và phát triển với tuổi thọ trên 50 triệu lần bấm, cảm giác nhấn nảy đầm tay và không bị dính phím nhờ tính năng Full Anti-ghosting.

Hệ thống đèn Multi-LED cầu vồng rực rỡ với nhiều chế độ chuyển động ánh sáng đẹp mắt, tôn vinh phong cách thể thao điện tử mạnh mẽ ngay cả trong điều kiện phòng tối.', 490000, 40, N'images/products/ban-phim/sp06-dareu-ek87/main.jpg', 1, GETDATE(), 1, N'Hãng sản xuất: DareU
Model: EK87 Multi-LED
Layout: Tenkeyless 87 phím
Kết nối: Dây cáp USB 2.0 bọc dù chống gập gãy dài 1.8m
Loại Switch: DareU D-Switch độc quyền (Blue / Brown / Red switch)
Độ bền Switch: 50 triệu lần nhấn
Keycap: Nhựa ABS Double-shot xuyên LED siêu bền
Hệ thống LED: Rainbow Multi-LED nhiều hiệu ứng động
Tương thích: Windows 11/10/8/7, Linux, macOS (hỗ trợ cơ bản)
Kích thước: 358 x 136 x 36 mm
Trọng lượng: Khoảng 850g
Bảo hành: 24 tháng chính hãng');

-- SP 10: Bàn phím cơ Corsair K70 RGB PRO
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (10, N'Bàn phím cơ Corsair K70 RGB PRO', N'Corsair K70 RGB PRO là biểu tượng huyền thoại của dòng bàn phím cơ thể thao điện tử cao cấp, kết hợp giữa khung nhôm phay xước máy bay Anodized trứ danh và công nghệ xử lý siêu tốc Corsair AXON.

Công nghệ siêu xử lý Corsair AXON truyền tín hiệu đầu vào đến máy tính với tần số Hyper-Polling lên tới 8.000Hz (nhanh gấp 8 lần bàn phím gaming thông thường), mang lại lợi thế phản xạ tuyệt đối trong thi đấu chuyên nghiệp.

Trang bị switch cơ học CHERRY MX chính hãng sản xuất tại Đức, kết hợp bộ keycap PBT DOUBLE-SHOT Pro dày 1.5mm chống phai mờ ký tự và bề mặt nhám mịn chuẩn thi đấu.

Bàn phím tích hợp công tắc Tournament Switch tiện lợi ở mặt sau giúp khóa nhanh các phím macro và chuyển đèn nền sang màu tĩnh tránh phân tâm, kèm đệm kê tay nam châm êm ái tháo lắp linh hoạt.', 3490000, 10, N'images/products/ban-phim/sp07-corsair-k70-rgb-pro/main.png', 1, GETDATE(), 1, N'Hãng sản xuất: CORSAIR
Model: K70 RGB PRO
Layout: Fullsize 104 phím tiêu chuẩn quốc tế
Kết nối: Cáp USB Type-C sang Type-A bọc dù tháo rời
Loại Switch: CHERRY MX Red (Linear 45g) / CHERRY MX Speed Silver (1.2mm)
Độ bền Switch: 100 triệu lần nhấn
Công nghệ xử lý: CORSAIR AXON Hyper-Processing (Tần số gửi mẫu 8,000Hz)
Keycap: PBT Double-Shot PRO dày 1.5mm cao cấp
Khung bàn phím: Hợp kim nhôm Anodized phay xước máy bay
Đèn nền: RGB 16.8 triệu màu tùy chỉnh từng phím qua iCUE
Bộ nhớ trong: 8MB lưu trữ tối đa 50 profile tùy biến
Kê tay: Kèm đệm kê tay nam châm bề mặt mềm công thái học
Kích thước: 444 x 166 x 40 mm
Trọng lượng: Khoảng 1150g
Phần mềm: Corsair iCUE (Windows & macOS)');

-- SP 11: Bàn phím công thái học Logitech Wave Keys
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (11, N'Bàn phím công thái học Logitech Wave Keys', N'Logitech Wave Keys là mẫu bàn phím công thái học không dây thế hệ mới được thiết kế dạng lượn sóng uốn cong tự nhiên, giúp giảm bớt căng thẳng lên cổ tay và cánh tay trong suốt ngày dài làm việc.

Điểm nổi bật là phần đệm kê tay 3 lớp mút hoạt tính (memory foam) êm ái gắn liền thân phím, nâng đỡ cổ tay nâng cao hơn 57% và giảm áp lực cổ tay so với bàn phím phẳng thông thường mà không đòi hỏi người dùng phải học lại cách gõ.

Sản phẩm hỗ trợ kết nối kép linh hoạt qua Bluetooth Low Energy hoặc đầu thu USB Logi Bolt bảo mật cao, kết nối tối đa 3 thiết bị cùng lúc và chuyển đổi nhanh bằng các nút Easy-Switch.

Bàn phím đạt chứng nhận công thái học Ergonomist Certified bởi United States Ergonomics, chạy bằng 2 viên pin AAA với thời lượng sử dụng bền bỉ lên đến 36 tháng liên tục.', 1690000, 16, N'images/products/ban-phim/sp08-logitech-wave-keys/main.png', 1, GETDATE(), 1, N'Hãng sản xuất: Logitech
Model: Wave Keys (Ergonomic Keyboard)
Layout: Thiết kế lượn sóng công thái học tích hợp cụm phím số
Kết nối: Bluetooth Low Energy và đầu thu USB Logi Bolt
Phạm vi kết nối: Tối đa 10 mét
Đệm kê tay: Đệm mút hoạt tính 3 lớp đệm chống bám bẩn gắn liền
Khả năng kết nối: Kết nối 3 thiết bị (chuyển đổi qua Easy-Switch)
Chứng nhận: Được chứng nhận bởi United States Ergonomics
Thời lượng pin: Lên đến 36 tháng (2 viên pin AAA)
Kích thước: 375.9 x 218.9 x 30.5 mm
Trọng lượng: Khoảng 750g (kèm pin)
Tương thích: Windows 11/10, macOS 11+, iPadOS 14+, ChromeOS, Android');

-- SP 12: Bàn phím không dây Rapoo E9050G Multi-Mode
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (12, N'Bàn phím không dây Rapoo E9050G Multi-Mode', N'Rapoo E9050G Multi-Mode là chiếc bàn phím không dây văn phòng siêu mỏng chỉ 5.6mm với khung hợp kim nhôm Anodized sang trọng, lấy cảm hứng từ phong cách thanh lịch của các thiết bị Apple.

Trang bị công nghệ kết nối đa chế độ thông minh của Rapoo, bàn phím hỗ trợ chuyển đổi linh hoạt giữa Bluetooth 3.0, Bluetooth 5.0 và kết nối không dây 2.4GHz qua USB receiver siêu nhỏ gọn.

Phím bấm thiết kế cấu trúc cắt kéo (Scissor Key) với bề mặt phím vuông vức, hành trình ngắn và lực phản hồi nảy nhẹ giúp gõ văn bản nhanh, êm ái và không gây mỏi ngón tay.

Tích hợp pin sạc Lithium thân thiện với môi trường qua cổng sạc Type-C hiện đại, chỉ cần sạc 2 giờ là có thể sử dụng thoải mái suốt 60 đến 90 ngày làm việc văn phòng thông thường.', 450000, 25, N'images/products/ban-phim/sp09-rapoo-e9050g/main.jpg', 1, GETDATE(), 1, N'Hãng sản xuất: Rapoo
Model: E9050G Multi-Mode Wireless Keyboard
Layout: 78 phím siêu mỏng nhỏ gọn
Kết nối: 3 chế độ (Bluetooth 5.0, Bluetooth 3.0, Wireless 2.4GHz)
Khoảng cách kết nối: 10m phủ sóng 360 độ
Độ dày bàn phím: Chỉ 5.6 mm tại điểm mỏng nhất
Chất liệu khung: Hợp kim nhôm nguyên khối phay mờ cao cấp
Cơ chế phím: Cắt kéo Scissor Switch gõ siêu êm
Cổng sạc: USB Type-C tiện lợi
Pin: Pin sạc Lithium tích hợp 300mAh
Thời lượng pin: 60 - 90 ngày cho một lần sạc đầy
Kích thước: 283.8 x 114.7 x 12.9 mm
Trọng lượng: Khoảng 312g
Tương thích: Windows, macOS, iOS, Android, Chrome OS');

-- SP 13: Bàn phím cơ MonsGeek M1W V3 SP Wireless RGB
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (13, N'Bàn phím cơ MonsGeek M1W V3 SP Wireless RGB', N'MonsGeek M1W V3 SP là mẫu bàn phím cơ Custom nhôm nguyên khối CNC cao cấp layout 75%, được cộng đồng đam mê bàn phím cơ săn đón nhờ chất lượng hoàn thiện vượt tầm giá cùng âm gõ thocky đầm chắc.

Toàn bộ khung vỏ phím được gia công từ một khối hợp kim nhôm 6063 qua quy trình CNC chính xác và bề mặt sơn Anodized mịn màng, mang lại trọng lượng đầm chắc gần 2kg chống trơn trượt tuyệt đối trên bàn làm việc.

Bàn phím sở hữu cấu trúc Gasket Mount với plate PC mềm dẻo cùng hệ thống đệm Poron và IXPE nhiều lớp, mang lại cảm giác gõ êm ái, giảm lực dội ngược lên đầu ngón tay khi gõ liên tục.

Trang bị 3 chế độ kết nối (Type-C, 2.4GHz và Bluetooth 5.0), mạch xuôi South-facing RGB đa hiệu ứng, tính năng Hot-swap 5-pin và núm xoay kim loại điều khiển âm lượng cực nhạy.', 2190000, 14, N'images/products/ban-phim/sp10-monsgeek-m1w-v3-sp/main.jpg', 1, GETDATE(), 1, N'Hãng sản xuất: MonsGeek (Akko)
Model: M1W V3 SP (Side-Printed)
Layout: 75% (82 phím + 1 núm xoay kim loại CNC)
Chất liệu vỏ: Nhôm nguyên khối CNC 6063 Anodized
Kết nối: 3 Mode (Cáp Type-C, Wireless 2.4GHz, Bluetooth 5.0)
Cấu trúc: Gasket Mount kết hợp Plate PC linh hoạt
Loại Switch: Akko V3 Piano Pro Switch / Cream Yellow Pro
Tính năng Hot-swap: Có (Hotswap 5-pin TTC Socket, mạch xuôi South-Facing)
Keycap: PBT Double-shot in ký tự cạnh bên (Side-printed gradient) xuyên LED
Đèn nền: RGB 16.8 triệu màu với dải LED viền bên hông độc đáo
Dung lượng pin: 6000mAh Lithium polymer khủng
Kích thước: 332 x 147 x 33 mm
Trọng lượng: Khoảng 1950g
Phần mềm hỗ trợ: MonsGeek Cloud Driver tùy biến sâu');

-- SP 14: Chuột không dây Logitech Pebble M350s (Pebble Mouse 2)
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (14, N'Chuột không dây Logitech Pebble M350s (Pebble Mouse 2)', N'Logitech Pebble M350s (Pebble Mouse 2) là mẫu chuột không dây phong cách tối giản thời thượng với thiết kế mỏng nhẹ như một viên sỏi cuội tự nhiên, mang lại vẻ đẹp thanh lịch cho góc làm việc hiện đại.

Trang bị công nghệ SilentTouch độc quyền của Logitech giúp giảm hơn 90% tiếng ồn khi nhấp chuột, cho phép bạn tập trung tối đa và thoải mái làm việc tại thư viện, văn phòng hoặc quán cà phê mà không làm phiền người xung quanh.

Chuột hỗ trợ kết nối kép không dây qua Bluetooth Low Energy hoặc đầu thu Logi Bolt, dễ dàng ghép nối cùng lúc 3 thiết bị và chuyển đổi nhanh chóng bằng nút Easy-Switch dưới đáy.

Thời lượng pin vượt trội lên tới 24 tháng chỉ với 1 viên pin AA duy nhất, kết hợp tính năng tự động chuyển sang chế độ tiết kiệm năng lượng khi không sử dụng.', 420000, 30, N'images/products/chuot/sp12-logitech-pebble-m350s/main.png', 2, GETDATE(), 1, N'Hãng sản xuất: Logitech
Model: Pebble Mouse 2 M350s
Loại chuột: Chuột không dây văn phòng siêu mỏng tĩnh âm
Kết nối: Bluetooth Low Energy và USB Logi Bolt Receiver
Khoảng cách kết nối: Lên tới 10 mét
Cảm biến: Cảm biến quang học chính xác Logitech
Độ phân giải (DPI): 400 - 4000 DPI (mặc định 1000 DPI)
Số nút: 3 nút (Trái/Phải/Nút giữa có thể tùy biến qua ứng dụng Logi Options+)
Công nghệ nhấp: SilentTouch giảm 90% tiếng ồn click
Thời lượng pin: 24 tháng (1 viên pin AA)
Kích thước: 106.7 x 58.7 x 26.6 mm
Trọng lượng: 76g (bao gồm pin)
Tương thích: Windows 10/11, macOS 11+, iPadOS 14+, Android 9.0+, ChromeOS');

-- SP 15: Chuột không dây công thái học Logitech MX Master 3S
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (15, N'Chuột không dây công thái học Logitech MX Master 3S', N'Logitech MX Master 3S là chiếc chuột công thái học đỉnh cao dành riêng cho các chuyên gia sáng tạo, lập trình viên và người dùng văn phòng chuyên nghiệp đòi hỏi độ chuẩn xác và tốc độ tối đa.

Chuột được trang bị cảm biến quang học cao cấp Darkfield 8.000 DPI có khả năng theo dõi mượt mà trên mọi bề mặt – kể cả mặt bàn kính trong suốt dày từ 4mm trở lên.

Con lăn điện từ MagSpeed trứ danh bằng thép gia công cơ học siêu tĩnh, có khả năng cuộn siêu tốc 1.000 dòng văn bản trong vòng 1 giây hoặc dừng lại chính xác trên từng pixel đơn lẻ.

Công nghệ Quiet Clicks giảm 90% tiếng ồn nhấp chuột kết hợp con lăn phụ cuộn ngang bằng ngón cái tiện lợi, sạc nhanh qua cổng USB-C chỉ 1 phút dùng được 3 giờ và pin đầy dùng tới 70 ngày.', 2190000, 20, N'images/products/chuot/sp13-logitech-mx-master-3s/main.png', 2, GETDATE(), 1, N'Hãng sản xuất: Logitech
Model: MX Master 3S
Loại chuột: Chuột không dây công thái học cao cấp
Cảm biến: Darkfield High Precision (hoạt động trên mặt kính dày > 4mm)
Độ phân giải (DPI): 200 - 8000 DPI (chỉnh bước nhảy 50 DPI)
Con lăn chính: MagSpeed SmartShift điện từ thép không gỉ
Con lăn phụ: Con lăn ngón tay cái cuộn ngang mượt mà
Số nút: 7 nút bấm có thể gán macro chuyên sâu qua Logi Options+
Kết nối: Bluetooth Low Energy và đầu thu Logi Bolt
Pin: Sạc qua USB-C, dung lượng 500mAh (dùng tới 70 ngày một lần sạc)
Kích thước: 124.9 x 84.3 x 51 mm
Trọng lượng: 141g
Tương thích: Windows, macOS, Linux, iPadOS, Android');

-- SP 16: Chuột gaming không dây Razer DeathAdder V2 X HyperSpeed
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (16, N'Chuột gaming không dây Razer DeathAdder V2 X HyperSpeed', N'Razer DeathAdder V2 X HyperSpeed kế thừa form dáng công thái học huyền thoại với hơn 15 triệu bản đã được bán ra trên toàn cầu, mang lại cảm giác cầm nắm thoải mái tuyệt đối cho các game thủ thuận tay phải.

Trang bị công nghệ không dây siêu tốc độ Razer HyperSpeed Wireless với độ trễ cực thấp ngang ngửa kết nối có dây, kết hợp chế độ Bluetooth năng lượng thấp giúp tối ưu thời lượng pin khi làm việc văn phòng.

Cảm biến quang học Razer 5G 14.000 DPI cho độ chính xác 99% theo dõi chuyển động, cùng switch chuột cơ học Razer Mechanical Gen-2 mạ vàng tiếp điểm cho độ bền 60 triệu lần bấm.

Khe gắn pin kép độc đáo hỗ trợ sử dụng linh hoạt 1 viên pin AA hoặc 1 viên pin AAA để điều chỉnh trọng lượng chuột theo thói quen thi đấu, thời lượng pin lên đến 615 giờ qua Bluetooth.', 1090000, 22, N'images/products/chuot/sp14-razer-deathadder-v2x/main.jpg', 2, GETDATE(), 1, N'Hãng sản xuất: Razer
Model: DeathAdder V2 X HyperSpeed
Form chuột: Công thái học cho người thuận tay phải (Right-handed Ergonomic)
Kết nối: Không dây kép (Razer HyperSpeed 2.4GHz và Bluetooth)
Cảm biến: Cảm biến quang học Razer 5G tiên tiến
Độ phân giải (DPI): Lên tới 14.000 DPI
Tốc độ tối đa (IPS): 300 IPS / Gia tốc 35G
Switch chuột: Razer Mechanical Mouse Switches Gen-2 (độ bền 60 triệu click)
Số nút: 7 nút bấm có thể lập trình độc lập qua Razer Synapse 3
Thời lượng pin: Lên đến 235 giờ (HyperSpeed 2.4GHz) / 615 giờ (Bluetooth)
Loại pin: Hỗ trợ 1 pin AA hoặc 1 pin AAA (khe pin kép thông minh)
Kích thước: 127 x 70.1 x 42.7 mm
Trọng lượng: 86 - 103g (tùy thuộc pin sử dụng)');

-- SP 17: Chuột gaming không dây DareU EM901X RGB kèm Dock sạc
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (17, N'Chuột gaming không dây DareU EM901X RGB kèm Dock sạc', N'DareU EM901X RGB là mẫu chuột gaming không dây giá tốt đáng sở hữu nhất phân khúc khi đi kèm dock sạc nam châm có đèn viền RGB vô cùng sang chảnh thường chỉ thấy trên các dòng chuột cao cấp.

Thiết kế form đối xứng thon gọn phù hợp cho cả người thuận tay trái lẫn tay phải, trọng lượng tối ưu khoảng 85g giúp các pha vẩy chuột bắn súng ngắm AWP hay tap AK-47 cực kỳ thanh thoát và chuẩn xác.

Chuột trang bị cảm biến độc quyền DareU Bravo ATG4090 đạt 6.000 DPI với khả năng tracking mượt mà, độ trễ tín hiệu 2.4GHz gần như bằng 0 giúp trải nghiệm chơi game không dây không hề gián đoạn.

Điểm tiện lợi nhất là dock sạc nam châm: sau mỗi buổi chơi game chỉ cần đặt nhẹ chuột lên đế sạc là pin sẽ tự động được nạp đầy, đồng thời biến góc setup gaming trở nên ấn tượng và chuyên nghiệp.', 650000, 28, N'images/products/chuot/sp15-dareu-em901x/main.jpg', 2, GETDATE(), 1, N'Hãng sản xuất: DareU
Model: EM901X RGB (kèm Charging Dock)
Kết nối: Wireless 2.4GHz và Type-C có dây
Cảm biến: DareU Bravo ATG4090 Gaming Sensor
Độ phân giải (DPI): 600 - 6.000 DPI (6 mức chuyển đổi nhanh)
Tốc độ quét: 100 IPS / Tần số phản hồi: 1000Hz
Switch chuột: DareU Micro Switch tuổi thọ 50 triệu lần nhấn
Đèn LED: RGB dải viền trên thân chuột và vòng LED RGB trên dock sạc
Dung lượng pin: 930mAh Lithium sạc lại
Thời lượng pin: Khoảng 30 giờ (bật LED) / 40 giờ (tắt LED)
Phụ kiện đi kèm: Dock sạc nam châm RGB, cáp Type-C bọc dù dài 1.5m, đầu thu USB
Kích thước: 125 x 67 x 39 mm
Trọng lượng: Khoảng 85g');

-- SP 18: Chuột công thái học đứng Logitech Lift Vertical
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (18, N'Chuột công thái học đứng Logitech Lift Vertical', N'Logitech Lift Vertical là mẫu chuột công thái học dáng đứng đột phá được thiết kế chuyên biệt cho bàn tay cỡ nhỏ và vừa, mang lại tư thế cầm nắm ''bắt tay'' tự nhiên 57 độ giúp loại bỏ hoàn toàn hiện tượng đau mỏi cổ tay.

Góc nghiêng 57 độ chuẩn y khoa giúp giải phóng áp lực chèn ép lên dây thần kinh cổ tay, giữ cẳng tay ở vị trí thả lỏng tự nhiên nhất trong suốt 8 giờ làm việc liên tục tại bàn văn phòng.

Chuột trang bị con lăn SmartWheel chuyển đổi thông minh giữa chế độ cuộn chính xác từng dòng và chế độ cuộn tự do siêu nhanh, các nút bấm tĩnh âm SilentTouch chống gây tiếng động khó chịu.

Kết nối dễ dàng cùng lúc với 3 thiết bị máy tính thông qua Bluetooth Low Energy hoặc đầu thu USB Logi Bolt, thời lượng pin 1 viên pin AA bền bỉ lên đến 2 năm sử dụng.', 1390000, 15, N'images/products/chuot/sp16-logitech-lift/main.png', 2, GETDATE(), 1, N'Hãng sản xuất: Logitech
Model: Lift Vertical Ergonomic Mouse
Form chuột: Dáng đứng công thái học góc nghiêng 57 độ (chuẩn tự nhiên)
Kích cỡ tay phù hợp: Bàn tay cỡ nhỏ và trung bình
Cảm biến: Cảm biến quang học nâng cao Logitech
Độ phân giải (DPI): 400 - 4000 DPI (chỉnh bước nhảy 100 DPI)
Con lăn: SmartWheel lăn chuẩn xác từng dòng hoặc cuộn lướt nhanh
Nút bấm: 6 nút (Trái/Phải SilentTouch, Nút quay lại/tiến lên, Nút giữa, Nút DPI)
Kết nối: Bluetooth Low Energy và USB Logi Bolt Receiver
Số thiết bị kết nối: 3 thiết bị (chuyển đổi qua Easy-Switch)
Thời lượng pin: Lên đến 24 tháng (1 viên pin AA)
Kích thước: 108 x 70 x 71 mm
Trọng lượng: 125g (kèm pin)');

-- SP 19: Chuột gaming siêu nhẹ Pulsar X2 V2 Wireless
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (19, N'Chuột gaming siêu nhẹ Pulsar X2 V2 Wireless', N'Pulsar X2 V2 Wireless là mẫu chuột gaming eSports siêu nhẹ cao cấp không đục lỗ chỉ nặng 53g, được các vận động viên bắn súng FPS hàng đầu thế giới tin dùng để thi đấu chuyên nghiệp.

Trang bị cảm biến hàng đầu thế giới PixArt PAW3395 với độ phân giải khủng 26.000 DPI, tốc độ lướt 650 IPS và gia tốc 50G, mang lại độ chính xác từng điểm ảnh và hoàn toàn không có hiện tượng mất tín hiệu khi vẩy tay cực nhanh.

Chuột sử dụng switch quang học Optical Switch loại bỏ hoàn toàn lỗi double-click cơ học, phản hồi tức thì với tốc độ ánh sáng và độ bền lên đến 80 triệu lần nhấn.

Con lăn trang bị encoder Pulsar Blue chống bụi siêu êm, hỗ trợ nâng cấp tần số quét lên tới 4.000Hz (4K Polling Rate) qua đầu thu Dongle 4K bán rời, mang lại độ mượt mà tối thượng trên màn hình 240Hz/360Hz.', 2290000, 12, N'images/products/chuot/sp17-pulsar-x2-v2/main.jpg', 2, GETDATE(), 1, N'Hãng sản xuất: Pulsar Gaming Gears
Model: X2 V2 Wireless (Size 2 - Medium)
Trọng lượng siêu nhẹ: Chỉ 53g (+- 1g, thân vỏ liền không đục lỗ)
Cảm biến: Flagship PixArt PAW3395 Sensor
Độ phân giải (DPI): Lên tới 26.000 DPI
Tốc độ tối đa: 650 IPS / Gia tốc: 50G
Switch phím chính: Optical Switches chống double-click (80 triệu lần nhấn)
Bộ điều khiển (MCU): Nordic 52840 cao cấp, hỗ trợ 4K Polling Rate
Kết nối: Wireless 2.4GHz không độ trễ và Type-C có dây
Thời lượng pin: Lên đến 70 giờ chơi liên tục
Feet chuột: 100% Virgin PTFE bo tròn cạnh siêu trơn
Kích thước: 120.4 x 63.1 x 38 mm
Phần mềm: Pulsar Fusion Software');

-- SP 20: Chuột không dây văn phòng Xiaomi Silent Edition
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (20, N'Chuột không dây văn phòng Xiaomi Silent Edition', N'Chuột không dây Xiaomi Dual Mode Silent Edition là sự kết hợp hoàn hảo giữa thiết kế công thái học thanh lịch, khả năng chống ồn tuyệt đối và mức giá vô cùng dễ tiếp cận cho người dùng phổ thông.

Chuột hỗ trợ 2 chế độ kết nối song song: Bluetooth không dây và kết nối USB 2.4GHz, cho phép bạn điều khiển 2 máy tính cùng lúc và chuyển đổi nhanh chỉ bằng một nút bấm phía trên thân chuột.

Công tắc nút bấm tĩnh âm Silent Click giảm tiếng ồn tới mức tối đa, giúp bạn thoải mái thao tác gõ phím và click chuột đêm khuya mà không làm phiền người thân hay đồng nghiệp xung quanh.

Bề mặt chuột phủ lớp sơn UV mờ mịn màng chống bám mồ hôi vân tay, hai bên hông khoét vân chấm bi chống trơn trượt hiệu quả khi cầm nắm trong thời gian dài.', 220000, 45, N'images/products/chuot/sp18-xiaomi-silent/main.jpg', 2, GETDATE(), 1, N'Hãng sản xuất: Xiaomi
Model: Mi Dual Mode Wireless Mouse Silent Edition
Kết nối: Chế độ kép (Bluetooth 4.2 BLE và Wireless USB 2.4GHz)
Khoảng cách kết nối: 8 mét
Cảm biến: Quang học độ nhạy cao 1300 DPI
Số nút: 4 nút (Trái/Phải/Con lăn/Nút chuyển đổi chế độ kép) + 2 nút phụ cạnh bên
Công nghệ click: Silent Click phím êm không gây tiếng ồn
Chất liệu: Nhựa ABS + PC phủ sơn UV cao cấp
Nguồn điện: 2 viên pin AAA (dùng khoảng 12 tháng)
Kích thước: 112.7 x 62.7 x 36.8 mm
Trọng lượng: Khoảng 93g (kèm pin)
Tương thích: Windows 10/11, macOS 10.10+, Android 6.0+');

-- SP 21: Chuột gaming có dây Corsair Harpoon RGB PRO
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (21, N'Chuột gaming có dây Corsair Harpoon RGB PRO', N'Corsair Harpoon RGB PRO là chiếc chuột gaming có dây chuyên nghiệp hướng tới sự cơ động và tốc độ, trọng lượng siêu nhẹ chỉ 85g giúp giảm mỏi tay trong những phiên cày game kéo dài suốt đêm.

Trang bị cảm biến quang học chất lượng cao độ phân giải thực 12.000 DPI cho khả năng tracking chuẩn xác đến từng milimet, bắt kịp mọi pha vẩy tâm bắn súng ngắm nhanh như chớp.

Thiết kế công thái học uốn cong ôm sát lòng bàn tay, hai bên hông chuột đúc cao su vân kim cương dính tay chắc chắn, hạn chế tối đa trơn trượt ngay cả khi tay ra mồ hôi.

Được trang bị switch cơ học Omron cao cấp tuổi thọ hơn 20 triệu lần nhấn, tích hợp hệ thống đèn nền RGB hiển thị logo Corsair rực rỡ có thể đồng bộ ánh sáng thông qua phần mềm Corsair iCUE.', 490000, 25, N'images/products/chuot/sp19-corsair-harpoon-pro/main.jpg', 2, GETDATE(), 1, N'Hãng sản xuất: CORSAIR
Model: Harpoon RGB PRO
Loại chuột: Chuột gaming có dây (Wired)
Cảm biến: Cảm biến quang học chơi game 12.000 DPI
Số nút: 6 nút bấm có thể gán phím macro độc lập
Switch chuột: Omron cơ học cao cấp (Độ bền hơn 20 triệu lần nhấn)
Đèn nền: 1 vùng RGB (Logo Corsair) tùy biến qua iCUE
Tần số phản hồi: 1000Hz / 500Hz / 250Hz / 125Hz
Dây cáp: Cáp cao su dẻo chống rối dài 1.8m
Kích thước: 115.5 x 68.3 x 40.4 mm
Trọng lượng: Siêu nhẹ 85g
Phần mềm: CORSAIR iCUE (Windows & macOS)');

-- SP 22: Chuột gaming không dây ATK Dragonfly F1 Pro Max
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (22, N'Chuột gaming không dây ATK Dragonfly F1 Pro Max', N'ATK Dragonfly F1 Pro Max (VGN) là siêu phẩm chuột gaming không dây ''kẻ hủy diệt phân khúc'' gây bão toàn cầu nhờ trang bị cấu hình phần cứng đỉnh nóc nhưng trọng lượng chỉ 55g siêu nhẹ.

Trái tim của chuột là cảm biến flagship PixArt PAW3395 (26.000 DPI, 650 IPS) kết hợp chip vi điều khiển cao cấp Nordic 52840 mang lại kết nối không dây Smart Speed Wireless siêu ổn định và tiết kiệm pin.

Sử dụng switch cơ học mạ vàng Kailh Golden Black Mamba độc quyền cho cảm giác bấm nảy giòn tan, phản hồi đanh gọn, không bị ọp ẹp và tuổi thọ lên tới 90 triệu lần nhấn.

Phiên bản Pro Max trang bị viên pin dung lượng lớn 500mAh cho thời gian sử dụng liên tục lên đến 130 giờ, hỗ trợ nâng cấp kết nối 4KHz mượt mà vượt bậc so với chuột 1000Hz truyền thống.', 1290000, 18, N'images/products/chuot/sp20-atk-dragonfly-f1/main.jpg', 2, GETDATE(), 1, N'Hãng sản xuất: ATK (VGN Gear)
Model: Dragonfly F1 Pro Max
Trọng lượng: Chỉ 55g (siêu nhẹ không cần đục lỗ)
Cảm biến: PixArt PAW3395 Flagship Sensor
Độ phân giải (DPI): 26.000 DPI
Tốc độ tối đa: 650 IPS / Gia tốc: 50G
Chip MCU: Nordic 52840 cao cấp (Hỗ trợ polling rate 4KHz)
Switch chuột: Kailh Golden Black Mamba (90 triệu lần nhấn)
Con lăn: TTC Gold Wheel Encoder cảm giác lăn rõ nấc
Kết nối: Wireless 2.4GHz SmartSpeed và Cáp Type-C siêu mềm
Dung lượng pin: 500mAh Lithium (thời lượng dùng tới 130 giờ)
Kích thước: 121.2 x 63.5 x 37.6 mm
Phần mềm: ATK V Hub Driver');

-- SP 23: Tai nghe gaming có dây Razer BlackShark V2 X
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (23, N'Tai nghe gaming có dây Razer BlackShark V2 X', N'Razer BlackShark V2 X là mẫu tai nghe gaming eSports quốc dân được mệnh danh là ''vũ khí sát thương âm thanh'' nhờ sự kết hợp giữa chất âm định hướng cực chuẩn và khả năng cách âm thụ động tuyệt hảo.

Trang bị củ loa độc quyền Razer TriForce 50mm với thiết kế màng loa 3 phần tách biệt, cho phép tinh chỉnh riêng lẻ các dải âm cao (treble), âm trung (mid) và âm trầm (bass), mang lại âm sắc chi tiết trong trẻo và âm bass uy lực.

Microphone cardioid Razer HyperClear có góc thu âm thanh tập trung từ phía trước miệng và loại bỏ tiếng ồn từ phía sau và hai bên hông, giúp đồng đội luôn nghe rõ từng khẩu lệnh tác chiến.

Trọng lượng siêu nhẹ chỉ 240g kết hợp đệm tai mút hoạt tính bọc da thoáng khí giúp bạn đeo thoải mái suốt nhiều giờ liền mà không bị hầm nóng tai.', 1190000, 20, N'images/products/tai-nghe/sp22-razer-blackshark-v2x/main.jpg', 3, GETDATE(), 1, N'Hãng sản xuất: Razer
Model: BlackShark V2 X
Kiểu tai nghe: Chụp tai Over-ear Closed-back
Driver: Razer TriForce 50mm độc quyền
Dải tần số: 12Hz – 28kHz
Trở kháng: 32 Ω tại 1kHz
Độ nhạy: 100 dBSPL/mW
Âm thanh vòm: Hỗ trợ 7.1 Surround Sound (kích hoạt trên Windows 10/11 64-bit)
Micro: Razer HyperClear Cardioid Mic lọc tạp âm
Đệm tai: Đệm mút hoạt tính bọc da nhân tạo êm ái thoáng khí
Kết nối: Jack cắm 3.5mm analog kèm cáp chia chữ Y
Chiều dài dây: 1.3m + Cáp chia PC 1.5m
Trọng lượng: Siêu nhẹ 240g
Tương thích: PC, Mac, PS4, PS5, Xbox One, Xbox Series X/S, Nintendo Switch, Mobile');

-- SP 24: Tai nghe gaming không dây Logitech G435 LIGHTSPEED
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (24, N'Tai nghe gaming không dây Logitech G435 LIGHTSPEED', N'Logitech G435 LIGHTSPEED là chiếc tai nghe gaming không dây siêu nhẹ độc đáo nhất phân khúc với trọng lượng chỉ 165g, phá vỡ định kiến về những chiếc tai nghe gaming cồng kềnh nặng nề.

Sở hữu kết nối kép không dây chuẩn LIGHTSPEED 2.4GHz không độ trễ và Bluetooth độ trễ thấp, G435 cho phép chuyển đổi nhanh chóng giữa máy tính PC chơi game và điện thoại thông minh nghe nhạc.

Củ loa âm thanh 40mm được cân chỉnh tỉ mỉ mang lại âm trường rộng mở, hỗ trợ công nghệ âm thanh vòm Dolby Atmos và Windows Sonic Spatial Sound.

Tai nghe loại bỏ cần mic cơ học truyền thống và thay thế bằng cặp micro tạo chùm tia (beamforming mics) tích hợp trực tiếp trên củ tai giúp giảm tiếng ồn nền hiệu quả. Pin sạc Type-C cho thời lượng nghe liên tục tới 18 giờ.', 1290000, 24, N'images/products/tai-nghe/sp23-logitech-g435/main.jpg', 3, GETDATE(), 1, N'Hãng sản xuất: Logitech G
Model: G435 LIGHTSPEED Wireless Gaming Headset
Kiểu tai nghe: Chụp tai không dây siêu nhẹ (Ultralight Over-ear)
Trọng lượng: Chỉ 165g (siêu nhẹ hàng đầu phân khúc)
Driver: Củ loa âm thanh 40mm
Dải tần số đáp ứng: 20Hz – 20kHz
Trở kháng: 45 Ohms (thụ động)
Giới hạn âm lượng tối đa: Có tùy chọn giới hạn âm lượng an toàn 85dB bảo vệ thính giác
Kết nối: Không dây LIGHTSPEED qua USB-A receiver và Bluetooth
Phạm vi kết nối: Tối đa 10 mét
Microphone: Cặp mic tạo chùm kép (Dual Beamforming Mics) tích hợp
Thời lượng pin: Lên đến 18 giờ phát liên tục (Sạc qua cổng USB-C)
Tương thích: PC, Mac, PlayStation 4/5, Điện thoại, Máy tính bảng');

-- SP 25: Tai nghe chụp tai chống ồn Sony WH-1000XM4
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (25, N'Tai nghe chụp tai chống ồn Sony WH-1000XM4', N'Sony WH-1000XM4 là tượng đài đỉnh cao trong làng tai nghe chống ồn chủ động (ANC) thế giới, sở hữu bộ xử lý chống ồn HD QN1 chuyên dụng mang lại không gian tĩnh lặng tuyệt đối dù bạn đang ở trên máy bay hay giữa phố thị ồn ào.

Trang bị củ loa 40mm màng chắn Polymer tinh thể lỏng (LCP) phủ nhôm, tái tạo trọn vẹn dải tần số siêu rộng lên tới 40kHz, chuẩn âm thanh độ phân giải cao Hi-Res Audio và codec LDAC truyền dữ liệu âm thanh gấp 3 lần Bluetooth thông thường.

Công nghệ trí tuệ nhân tạo DSEE Extreme nâng cấp chất lượng các tệp nhạc nén kỹ thuật số theo thời gian thực. Tính năng Speak-to-Chat thông minh tự động tạm dừng nhạc và kích hoạt âm thanh môi trường ngay khi bạn cất tiếng nói.

Thời lượng pin khủng lên đến 30 giờ khi bật chống ồn (hoặc 38 giờ khi tắt), hỗ trợ sạc nhanh 10 phút dùng được 5 giờ cùng khả năng gập gọn tiện lợi trong hộp đựng cao cấp.', 5990000, 12, N'images/products/tai-nghe/sp24-sony-wh1000xm4/main.jpg', 3, GETDATE(), 1, N'Hãng sản xuất: SONY
Model: WH-1000XM4
Kiểu tai nghe: Chụp tai Over-ear Chống ồn chủ động (ANC)
Bộ xử lý chống ồn: Sony HD Noise Cancelling Processor QN1
Driver: 40mm dạng vòm màng LCP mạ nhôm
Dải tần: 4Hz - 40.000Hz (Cắm dây) / 20Hz - 40.000Hz (LDAC)
Chuẩn âm thanh: Hi-Res Audio, Hi-Res Wireless, 360 Reality Audio, DSEE Extreme
Kết nối: Bluetooth 5.0 (LDAC, AAC, SBC) và Jack 3.5mm
Thời lượng pin: 30 giờ (bật ANC) / 38 giờ (tắt ANC)
Sạc nhanh: Sạc 10 phút nghe 5 giờ qua cổng Type-C
Tính năng: Speak-to-Chat, Cảm biến đeo tự dừng nhạc, Kết nối cùng lúc 2 thiết bị
Trọng lượng: Khoảng 254g
Phần mềm: Sony Headphones Connect (iOS & Android)');

-- SP 26: Tai nghe gaming chụp tai DareU EH416 RGB 7.1
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (26, N'Tai nghe gaming chụp tai DareU EH416 RGB 7.1', N'DareU EH416 RGB 7.1 là chiếc tai nghe gaming có giả lập âm thanh vòm 7.1 giá tốt bậc nhất thị trường, lựa chọn lý tưởng cho các bạn học sinh, sinh viên muốn trải nghiệm không gian âm thanh game chân thực mà không tốn nhiều chi phí.

Trang bị chip giải mã âm thanh vòm 7.1 ảo tích hợp ngay trong cổng USB, giúp tái tạo hướng di chuyển, tiếng súng nổ và tiếng bước chân trong các tựa game sinh tồn như PUBG, Rules of Survival và CS:GO vô cùng chính xác.

Củ loa đường kính lớn 50mm cho âm bass dày khỏe, âm trung trong rõ. Khung choàng đầu kim loại dẻo bọc đệm êm ái tự co giãn vừa vặn với mọi kích thước vòng đầu mà không gây cấn đau đỉnh đầu.

Hệ thống đèn LED RGB viền tròn trên chụp tai tự động chuyển màu mượt mà, tạo hiệu ứng thị giác rực rỡ và chuyên nghiệp cho góc chơi game tại nhà.', 350000, 35, N'images/products/tai-nghe/sp25-dareu-eh416/main.jpg', 3, GETDATE(), 1, N'Hãng sản xuất: DareU
Model: EH416 RGB 7.1
Kiểu tai nghe: Chụp tai Over-ear có dây
Driver: 50mm Dynamic
Dải tần số: 20Hz – 20kHz
Trở kháng: 32 Ω / Độ nhạy: 111dB (+- 3dB)
Âm thanh vòm: Giả lập 7.1 Surround Sound qua chip USB
Đèn LED: RGB đổi màu tự động trên hai bên củ tai
Microphone: Micro mềm dẻo đa hướng bắt giọng nói rõ ràng
Đệm tai: Da nhân tạo êm ái cách âm tốt
Khung tai nghe: Khung thép không gỉ đàn hồi tự ôm sát đầu
Kết nối: Cổng USB 2.0 (tích hợp truyền âm thanh, mic và cấp nguồn LED)
Chiều dài cáp: 2.0m bọc cao su dày chống gãy gập
Trọng lượng: Khoảng 300g
Tương thích: PC, Laptop chạy Windows 10/11');

-- SP 27: Tai nghe True Wireless gaming Edifier Hecate GX07
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (27, N'Tai nghe True Wireless gaming Edifier Hecate GX07', N'Edifier Hecate GX07 là mẫu tai nghe True Wireless gaming đỉnh cao phong cách Cyberpunk với thiết kế hộp sạc mở cánh chim hải âu (gull-wing) độc nhất vô nhị cùng dải đèn LED RGB tương lai cực ngầu.

Tai nghe trang bị công nghệ chống ồn chủ động ANC lai (Hybrid ANC) đạt mức triệt tiêu tiếng ồn lên tới -38dB, kết hợp chế độ xuyên âm Ambient Sound giúp bạn nghe rõ cảnh báo bên ngoài khi cần thiết.

Chế độ Gaming Mode kích hoạt độ trễ siêu thấp chỉ 60ms cùng công nghệ giải mã âm thanh HECATE H+ giúp tăng cường tiếng bước chân và tiếng súng trong game mobile bắn súng như Free Fire, PUBG Mobile, Tốc Chiến.

Sở hữu củ loa 8mm màng phức hợp hỗ trợ codec LHDC chuẩn Hi-Res Audio 24bit/96kHz, mang lại chất lượng nghe nhạc audiophile sống động với âm trường tách bạch và âm bass bùng nổ.', 1890000, 15, N'images/products/tai-nghe/sp26-edifier-gx07/main.jpg', 3, GETDATE(), 1, N'Hãng sản xuất: EDIFIER (Dòng gaming cao cấp HECATE)
Model: Hecate GX07
Kiểu tai nghe: True Wireless In-ear Gaming
Thiết kế hộp sạc: Cửa mở cánh chim hải âu (Gull-wing doors) kèm LED RGB
Driver: 8mm Complex Diaphragm Unit
Chống ồn: Hybrid ANC (Triệt tiêu ồn tới -38dB) + Chế độ Ambient Sound
Độ trễ chơi game: Siêu thấp 60ms (Game Mode tối ưu hóa)
Chuẩn âm thanh: Hi-Res Wireless với codec LHDC, AAC, SBC
Thời lượng pin tai nghe: 5 giờ (ANC Bật) / 6.5 giờ (ANC Tắt)
Tổng thời lượng kèm hộp: Lên tới 26 giờ sử dụng
Sạc nhanh: Sạc 15 phút nghe được 2 giờ qua cổng USB-C
Kháng nước kháng bụi: Chuẩn IP54 bền bỉ
Trọng lượng: 5g mỗi bên tai nghe');

-- SP 28: Tai nghe chụp tai Bluetooth Marshall Major IV
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (28, N'Tai nghe chụp tai Bluetooth Marshall Major IV', N'Marshall Major IV là chiếc tai nghe chụp tai không dây biểu tượng của văn hóa Rock ''n'' Roll, kết hợp thiết kế cổ điển vuông vắn đặc trưng của Marshall với thời lượng pin kỷ lục trên 80 giờ liên tục.

Sở hữu củ loa Dynamic 40mm được cân chỉnh theo chất âm huyền thoại của Marshall: dải âm bass sâu trầm bùng nổ, âm mid mượt mà quyến rũ và âm treble chi tiết sắc bén, hoàn hảo cho thể loại Rock, Jazz, Acoustic và Pop.

Khả năng chơi nhạc hơn 80 giờ chỉ với một lần sạc giúp bạn có thể nghe nhạc thoải mái suốt cả tháng mà không cần cắm sạc. Hỗ trợ sạc không dây chuẩn Qi tiện lợi hoặc sạc nhanh Type-C chỉ 15 phút cho 15 giờ nghe.

Núm điều khiển đa hướng (Control Knob) bằng đồng mạ vàng duy nhất trên củ tai cho phép bạn phát/dừng nhạc, chuyển bài, chỉnh âm lượng và nhận cuộc gọi chỉ bằng thao tác gạt ngón tay đơn giản.', 3290000, 14, N'images/products/tai-nghe/sp27-marshall-major-iv/main.jpg', 3, GETDATE(), 1, N'Hãng sản xuất: Marshall Headphones
Model: Major IV Bluetooth
Kiểu tai nghe: Chụp tai On-ear gấp gọn
Driver: 40mm Dynamic Drivers độc quyền
Dải tần số: 20Hz – 20kHz
Trở kháng: 32 Ω / Độ nhạy: 99 dB SPL (100mV @ 1kHz)
Thời lượng pin khủng: Hơn 80 giờ nghe nhạc không dây
Sạc nhanh: 15 phút sạc nghe được 15 giờ
Công nghệ sạc: Hỗ trợ sạc không dây chuẩn Qi và sạc dây Type-C
Nút điều khiển: Núm xoay đa hướng Brass Multi-directional Knob bằng đồng
Cổng kết nối thêm: Jack 3.5mm chia sẻ nhạc cho bạn bè hoặc nghe có dây
Trọng lượng: Siêu nhẹ 165g
Khả năng gấp gọn: Khớp gập kim loại thu nhỏ kích thước cất túi');

-- SP 29: Tai nghe in-ear gaming Asus ROG Cetra True Wireless
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (29, N'Tai nghe in-ear gaming Asus ROG Cetra True Wireless', N'Asus ROG Cetra True Wireless là tai nghe không dây gaming cao cấp mang thương hiệu Republic of Gamers danh tiếng, thiết kế để mang lại trải nghiệm âm thanh chiến game đỉnh cao mọi lúc mọi nơi.

Trang bị công nghệ chống ồn chủ động ANC lai phát hiện và lọc sạch các tạp âm môi trường, cho phép bạn hoàn toàn đắm chìm vào thế giới game mà không bị xao lãng.

Chế độ Gaming Mode kích hoạt kết nối không dây độ trễ cực thấp, đảm bảo sự đồng bộ hoàn hảo giữa hình ảnh và âm thanh trong các pha giao tranh nảy lửa trên PC, Nintendo Switch hay smartphone.

Củ loa độc quyền ASUS Essence 10mm cùng buồng cách âm kín khí mang lại chất âm giàu chi tiết và âm bass uy lực. Hộp sạc hỗ trợ sạc không dây chuẩn Qi và cho tổng thời lượng pin lên đến 27 giờ.', 1790000, 18, N'images/products/tai-nghe/sp28-rog-cetra/main.jpg', 3, GETDATE(), 1, N'Hãng sản xuất: ASUS (Dòng ROG - Republic of Gamers)
Model: ROG Cetra True Wireless
Kiểu tai nghe: In-ear Gaming không dây
Driver âm thanh: 10mm ASUS Essence Drivers nam châm Neodymium
Trở kháng: 32 Ω / Dải tần số: 20Hz – 20kHz
Chống ồn: Công nghệ Hybrid Active Noise Cancellation (ANC)
Độ trễ không dây: Chế độ Gaming Mode đồng bộ siêu tốc
Thời lượng pin: 5.5 giờ tai nghe + 21.5 giờ hộp sạc (tắt ANC) / 4.8h + 17h (bật ANC)
Sạc nhanh: Sạc 10 phút dùng được 90 phút
Sạc không dây: Hỗ trợ sạc không dây chuẩn Qi
Kháng nước: Chuẩn IPX4 chống mồ hôi và mưa nhẹ
Phần mềm hỗ trợ: Armoury Crate điều chỉnh EQ và hiệu ứng âm thanh');

-- SP 30: Tai nghe gaming Corsair HS55 Stereo
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (30, N'Tai nghe gaming Corsair HS55 Stereo', N'Corsair HS55 Stereo là mẫu tai nghe gaming chụp tai thế hệ mới chú trọng vào sự thoải mái tối đa với trọng lượng siêu nhẹ chỉ 273g cùng chất lượng âm thanh chuẩn xác cho cả chơi game và nghe nhạc.

Chụp tai sử dụng đệm mút hoạt tính bọc da nhân tạo êm ái, kết hợp headband có đệm dày êm giúp phân tán trọng lực đều lên đầu, không gây cảm giác ê buốt vành tai khi đeo liên tục 5-6 tiếng.

Sở hữu củ loa âm thanh Neodymium 50mm tùy chỉnh cao cấp, HS55 tái hiện âm trường rộng lớn với độ méo tiếng cực thấp, giúp nhận biết chính xác vị trí phát ra tiếng động trong không gian 3D.

Micro đa hướng bắt âm thanh đàm thoại trong trẻo, tích hợp cơ chế lật lên để tắt mic (Flip-to-mute) siêu nhạy, đạt chứng nhận Discord Certified cho các cuộc trò chuyện voice chat mượt mà.', 990000, 20, N'images/products/tai-nghe/sp29-corsair-hs55/main.png', 3, GETDATE(), 1, N'Hãng sản xuất: CORSAIR
Model: HS55 Stereo
Kiểu tai nghe: Chụp tai Over-ear Closed-back
Driver âm thanh: Củ loa Neodymium 50mm tinh chỉnh theo chuẩn eSports
Dải tần số đáp ứng: 20Hz – 20kHz
Trở kháng: 32 Ω tại 1kHz
Độ nhạy: 114dB (+- 3dB)
Microphone: Micro đa hướng (Omni-directional) đạt chuẩn Discord Certified
Tính năng mic: Lật lên để ngắt mic (Flip-to-mute)
Đệm tai: Mút hoạt tính Memory Foam bọc da nhân tạo cao cấp
Kết nối: Jack cắm 3.5mm kèm đầu chia chữ Y cắm PC
Trọng lượng: Chỉ 273g
Tương thích: PC, Mac, PS5/PS4, Xbox Series X/S, Nintendo Switch, Điện thoại');

-- SP 31: Tai nghe kiểm âm chụp tai Audio-Technica ATH-M20x
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (31, N'Tai nghe kiểm âm chụp tai Audio-Technica ATH-M20x', N'Audio-Technica ATH-M20x là mẫu tai nghe kiểm âm phòng thu chuyên nghiệp thuộc dòng M-Series huyền thoại đến từ thương hiệu âm thanh Audio-Technica lừng danh của Nhật Bản.

Được thiết kế chuyên biệt cho công việc thu âm, mix nhạc, edit video và nghe nhạc chất lượng cao, tai nghe mang lại chất âm cân bằng, trung thực chuẩn monitor mà không bị nịnh tai hay tăng bass quá đà.

Trang bị củ loa độc quyền 40mm với nam châm đất hiếm Neodymium và dây nhôm bọc đồng (CCAW), mang lại độ phản hồi dải tần số thấp cực tốt và âm sắc rõ ràng đến từng chi tiết nhạc cụ.

Thiết kế Circumural ôm trọn toàn bộ vành tai giúp cách ly tiếng ồn thụ động xuất sắc trong môi trường thu âm ồn ào, cáp cắm thẳng dài 3.0m tiện lợi kết nối với soundcard và máy tính để bàn.', 1350000, 16, N'images/products/tai-nghe/sp30-audio-technica-m20x/main.png', 3, GETDATE(), 1, N'Hãng sản xuất: Audio-Technica (Nhật Bản)
Model: ATH-M20x Professional Monitor Headphones
Kiểu tai nghe: Chụp tai kiểm âm chuyên nghiệp (Closed-back Studio Monitor)
Driver: 40mm với nam châm Neodymium và cuộn dây đồng bọc nhôm CCAW
Dải tần số: 15Hz – 20.000Hz
Công suất đầu vào tối đa: 700 mW tại 1kHz
Độ nhạy: 96 dB / Trở kháng: 47 Ω
Thiết kế đệm tai: Vành đệm bọc da cao cấp cách âm thụ động vượt trội
Dây cáp: Cáp thẳng dài 3.0m ra một bên tai nghe tiện lợi
Jack cắm: Đầu cắm 3.5mm mạ vàng kèm đầu chuyển ren vặn 6.3mm mạ vàng
Trọng lượng: Khoảng 190g (không tính dây cáp)
Ứng dụng: Kiểm âm phòng thu, livestream, podcast, edit video, nghe nhạc audiophile');

-- SP 32: Webcam Logitech C920 Pro HD 1080P
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (32, N'Webcam Logitech C920 Pro HD 1080P', N'Logitech C920 Pro HD là mẫu webcam hội họp và livestream chuẩn mực quốc tế được tin dùng nhất trên thế giới, mang đến video Full HD 1080p sắc nét và âm thanh nổi trung thực trong mọi cuộc gọi video.

Trang bị ống kính thủy tinh 5 thấu kính Full HD cao cấp cùng tính năng tự động lấy nét (Autofocus) siêu tốc độ, giữ hình ảnh khuôn mặt luôn sắc nét và chi tiết ngay cả khi bạn di chuyển gần hoặc xa camera.

Công nghệ tự động điều chỉnh ánh sáng RightLight 2 độc quyền của Logitech tự động bù sáng thông minh khi phòng thiếu sáng hoặc bị chói ngược sáng, đảm bảo làn da và khuôn mặt luôn sáng rõ rạng rỡ.

Hệ thống micro kép thu âm đa hướng bố trí hai bên ống kính ghi lại âm thanh nổi tự nhiên, lọc bớt tạp âm nền giúp giọng nói đàm thoại luôn to rõ và trong trẻo.', 1590000, 25, N'images/products/webcam/sp31-logitech-c920/main.jpg', 4, GETDATE(), 1, N'Hãng sản xuất: Logitech
Model: C920 Pro HD Webcam
Độ phân giải tối đa: Full HD 1080p @ 30fps / 720p @ 30fps
Loại ống kính: Ống kính kính Full HD 5 thấu kính cao cấp
Lấy nét: Tự động lấy nét siêu tốc (Autofocus)
Góc quan sát (FOV): Đường chéo 78 độ
Cân bằng sáng: Công nghệ RightLight 2 tự động bù sáng thông minh
Microphone: Micro kép tích hợp thu âm thanh Stereo nổi đa hướng
Kẹp gắn: Chân kẹp đa năng bọc cao su chống trầy gắn màn hình hoặc gắn chân tripod ren 1/4 inch
Kết nối: Dây cáp USB-A gắn liền dài 1.5m
Kích thước: 94 x 43.3 x 71 mm (kèm kẹp)
Trọng lượng: 162g
Tương thích: Windows 10/11, macOS 10.10+, Chrome OS, phần mềm Zoom, Teams, Skype, OBS Studio');

-- SP 33: Webcam Logitech C270 HD 720P
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (33, N'Webcam Logitech C270 HD 720P', N'Logitech C270 là mẫu webcam HD 720p bán chạy hàng đầu thế giới dành cho nhu cầu học tập trực tuyến, làm việc từ xa tại nhà và gọi video gia đình qua Zalo, Messenger, Zoom hay Google Meet.

Cung cấp độ phân giải chuẩn HD 720p ở tốc độ 30 khung hình/giây mượt mà, màu sắc hiển thị chân thực và hình ảnh ổn định ngay cả với đường truyền mạng Internet gia đình thông thường.

Tích hợp micro đơn khử tiếng ồn (Noise-reducing mic) có thể bắt giọng nói rõ ràng từ khoảng cách lên tới 1.5 mét, đồng thời lọc bớt tạp âm từ tiếng quạt gió hay tiếng gõ bàn phím.

Công nghệ điều chỉnh ánh sáng RightLight tự động nhận diện và cân bằng độ sáng khi điều kiện ánh sáng trong phòng bị tối, chân kẹp linh hoạt gắn chắc chắn lên màn hình laptop hoặc máy tính để bàn.', 490000, 40, N'images/products/webcam/sp32-logitech-c270/main.jpg', 4, GETDATE(), 1, N'Hãng sản xuất: Logitech
Model: C270 HD Webcam
Độ phân giải tối đa: HD 720p @ 30fps (1280 x 720 pixels)
Loại tiêu cự: Tiêu cự cố định (Fixed focus)
Góc quan sát chéo (FOV): 60 độ
Cân bằng sáng: Công nghệ RightLight tự động bù sáng phòng tối
Microphone: Micro tích hợp đơn hướng với công nghệ lọc tạp âm nền
Khoảng cách thu âm mic: Lên đến 1.5 mét
Chân kẹp: Chân kẹp phổ dụng gắn vừa màn hình laptop và LCD
Kết nối: USB-A 2.0 cắm là chạy (Plug and Play)
Chiều dài cáp: 1.5m
Kích thước: 71.15 x 31.3 x 68.5 mm
Trọng lượng: 75g
Tương thích: Windows 11/10/8/7, macOS, Chrome OS');

-- SP 34: Webcam 2K QHD Rapoo C280 góc rộng
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (34, N'Webcam 2K QHD Rapoo C280 góc rộng', N'Rapoo C280 là mẫu webcam độ phân giải cao 2K QHD (2560x1440) giá cực kỳ hấp dẫn, mang lại độ chi tiết gấp đôi so với các webcam Full HD thông thường cho các buổi thuyết trình và họp trực tuyến chuyên nghiệp.

Ống kính góc siêu rộng 85 độ (Wide-angle lens) cho phép bao quát toàn cảnh nhiều người ngồi họp trong một phòng hoặc thể hiện trọn vẹn không gian bảng viết, bài giảng của giáo viên.

Webcam đi kèm nắp che bảo mật vật lý (Privacy Cover) tích hợp, chỉ cần gạt nhẹ là có thể che kín ống kính camera khi không sử dụng, bảo vệ tuyệt đối sự riêng tư cá nhân.

Trang bị micro kép khử tiếng ồn đa hướng bắt âm thanh đàm thoại trong trẻo từ khoảng cách 3 mét, chân đế xoay 360 độ ngang và 90 độ dọc giúp tùy chỉnh góc nhìn dễ dàng.', 690000, 30, N'images/products/webcam/sp33-rapoo-c280/main.jpg', 4, GETDATE(), 1, N'Hãng sản xuất: Rapoo
Model: C280 2K QHD Webcam
Độ phân giải: 2K QHD (2560 x 1440 pixels) @ 30fps
Ống kính: Ống kính quang học góc siêu rộng 85 độ
Microphone: Micro kép tích hợp lọc tiếng ồn đa hướng thông minh
Khoảng cách bắt âm: Lên tới 3 mét
Nắp bảo mật: Nắp che ống kính vật lý Privacy Shutter trượt bảo vệ an toàn
Khả năng xoay: Khớp cầu xoay ngang 360 độ và gập nghiêng 90 độ
Chân kẹp: Chân kẹp đa năng kẹp màn hình hoặc đặt bàn, có ren cắm tripod
Kết nối: USB 2.0 cắm là chạy không cần cài đặt driver
Chiều dài dây: 1.5m
Kích thước: 90 x 45 x 50 mm
Trọng lượng: Khoảng 118g
Hỗ trợ: Windows 10/11, macOS, Linux, Chrome OS');

-- SP 35: Webcam Logitech Brio 4K Ultra HD HDR
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (35, N'Webcam Logitech Brio 4K Ultra HD HDR', N'Logitech Brio 4K Ultra HD là chiếc webcam cao cấp nhất dành cho các CEO, streamer chuyên nghiệp và nhà sáng tạo nội dung, định hình tiêu chuẩn phát sóng video đỉnh cao toàn cầu.

Hỗ trợ độ phân giải Ultra HD 4K ở tốc độ 30fps hoặc Full HD 1080p ở tốc độ siêu mượt 60fps, kết hợp công nghệ HDR (High Dynamic Range) và RightLight 3 mang lại hình ảnh sống động, rực rỡ và chân thực dưới mọi điều kiện ánh sáng.

Tích hợp cảm biến hồng ngoại và công nghệ nhận diện khuôn mặt quang học tương thích hoàn hảo với Windows Hello, cho phép đăng nhập máy tính an toàn chỉ trong một cái chớp mắt.

Khả năng điều chỉnh trường nhìn linh hoạt giữa 3 góc độ: 65 độ (tập trung chân dung), 78 độ (góc tiêu chuẩn) và 90 độ (bao quát phòng họp), cùng zoom kỹ thuật số 5x Full HD siêu nét.', 3990000, 12, N'images/products/webcam/sp34-logitech-brio-4k/main.jpg', 4, GETDATE(), 1, N'Hãng sản xuất: Logitech
Model: Brio 4K Ultra HD Webcam
Độ phân giải: 4K Ultra HD @ 30fps / 1080p @ 60fps / 720p @ 90fps
Công nghệ hình ảnh: RightLight 3 với HDR tự động cân bằng tương phản sáng tối
Trường nhìn (FOV): Tùy chỉnh 3 góc độ (65 độ, 78 độ và 90 độ)
Zoom kỹ thuật số: 5x Digital Zoom ở chất lượng Full HD
Bảo mật: Cảm biến hồng ngoại nhận diện khuôn mặt Windows Hello
Microphone: Cặp micro đa hướng chống ồn lọc âm cao cấp
Kết nối: Cáp USB Type-C sang Type-A tháo rời bọc dù dài 2.2m (hỗ trợ USB 3.0)
Nắp che: Kèm nắp che ống kính gắn rời bảo vệ riêng tư
Phần mềm hỗ trợ: Logi Tune, G HUB tùy biến độ phơi sáng, màu sắc chuyên sâu
Trọng lượng: 63g (thân camera)');

-- SP 36: Webcam Elgato Facecam Full HD 60FPS
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (36, N'Webcam Elgato Facecam Full HD 60FPS', N'Elgato Facecam là mẫu webcam chuyên dụng hàng đầu dành riêng cho Streamer và Content Creator với tiêu chí chất lượng hình ảnh đẳng cấp studio phát sóng truyền hình mà không bị nén dữ liệu.

Sử dụng cảm biến hình ảnh lừng danh Sony STARVIS CMOS kích thước lớn kết hợp ống kính cao cấp Elgato Prime Lens khẩu độ mở lớn f/2.4 toàn bộ bằng thủy tinh, tối ưu hóa thu nhận ánh sáng trong nhà và kiểm soát độ nhiễu hạt tuyệt vời.

Truyền tải tín hiệu video không nén (Uncompressed 1080p60) trực tiếp qua cổng USB 3.0 Type-C, triệt tiêu hoàn toàn hiện tượng vỡ hạt hay giật khung hình khi phát trực tiếp trên Twitch, YouTube Gaming, Facebook Live.

Bộ nhớ trong tích hợp cho phép lưu trực tiếp các thiết lập phơi sáng, cân bằng trắng, ISO vào phần cứng camera, giữ nguyên chất lượng hình ảnh hoàn hảo khi chuyển sang máy tính khác.', 3690000, 10, N'images/products/webcam/sp35-elgato-facecam/main.jpg', 4, GETDATE(), 1, N'Hãng sản xuất: Elgato (CORSAIR)
Model: Facecam
Độ phân giải: 1080p60 (Full HD 60 khung hình/giây không nén tín hiệu)
Cảm biến: Sony STARVIS CMOS cao cấp chuyên dụng thiếu sáng
Ống kính: Elgato Prime Lens (8 thấu kính thủy tinh, khẩu độ f/2.4, tiêu cự 24mm)
Góc nhìn (FOV): 82 độ (đường chéo)
Khoảng lấy nét: Lấy nét cố định chuẩn phòng thu 30 - 120 cm
Giao tiếp: USB 3.0 Type-C (băng thông truyền dữ liệu video không nén cực đại)
Bộ nhớ trong: Lưu profile cài đặt trực tiếp vào bo mạch camera
Chân đế: Ngàm kẹp màn hình cao cấp kèm ren vặn 1/4 inch cắm tay đỡ Elgato Wave
Kích thước: 79 x 48 x 58 mm
Trọng lượng: 96g (không tính chân kẹp)
Phần mềm: Elgato Camera Hub chỉnh tay ISO, Shutter Speed, Color Temperature chuyên nghiệp');

-- SP 37: Webcam EMEET SmartCam C960 Full HD 1080P
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (37, N'Webcam EMEET SmartCam C960 Full HD 1080P', N'EMEET SmartCam C960 là chiếc webcam Full HD 1080p được cộng đồng làm việc từ xa đánh giá cao nhờ khả năng thu âm chống ồn vượt trội và góc nhìn rộng 90 độ chuẩn hội nghị.

Cung cấp độ phân giải sắc nét 1080p ở tốc độ 30fps với ống kính phủ 4 lớp thấu kính quang học, màu sắc cân bằng tự nhiên và khả năng tự động hiệu chỉnh độ sáng trong phòng tối.

Điểm mạnh nhất của C960 là hệ thống 2 micro đa hướng tích hợp chip xử lý tín hiệu số DSP lọc tiếng ồn độc quyền, triệt tiêu tiếng vang vọng trong phòng và tiếng ồn xung quanh, bắt giọng nói trong bán kính 2.5m.

Thiết kế chân kẹp linh hoạt có lót cao su chống xước và tích hợp lỗ gắn ren tripod chuẩn quốc tế, đi kèm nắp đậy bảo vệ ống kính tăng cường tính an toàn bảo mật thông tin.', 550000, 28, N'images/products/webcam/sp36-emeet-c960/main.png', 4, GETDATE(), 1, N'Hãng sản xuất: EMEET
Model: SmartCam C960
Độ phân giải: 1080p Full HD @ 30fps
Ống kính: 4 lớp kính quang học chống lóa
Góc quan sát (FOV): Góc rộng 90 độ bao quát toàn cảnh
Lấy nét: Tiêu cự cố định từ 50cm đến 5 mét
Microphone: 2 micro đa hướng với chip lọc ồn DSP thông minh
Khoảng cách thu âm: Lên tới 2.5 mét
Nắp bảo mật: Nắp che vật lý chống nhìn trộm gắn sẵn
Chân kẹp: Kẹp màn hình đa năng xoay gập 180 độ, có lỗ ren cắm tripod
Kết nối: Dây cáp USB 2.0 dài 1.8m cắm dùng ngay
Kích thước: 100 x 48 x 54 mm
Trọng lượng: 120g
Tương thích: Windows, macOS, Android TV, Linux');

-- SP 38: Webcam Razer Kiyo Full HD kèm Ring Light
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (38, N'Webcam Razer Kiyo Full HD kèm Ring Light', N'Razer Kiyo là mẫu webcam độc đáo tiên phong trên thị trường tích hợp sẵn đèn trợ sáng Ring Light dạng vòng tròn bao quanh ống kính, giải quyết triệt để vấn đề thiếu sáng khi livestream ban đêm.

Vòng đèn LED Ring Light nhiệt độ màu 5600K ánh sáng trắng tự nhiên chiếu sáng đồng đều khuôn mặt, có thể tùy chỉnh nhanh độ sáng bằng cách xoay nhẹ vành khuyên đèn bên ngoài mà không cần mở phần mềm.

Cung cấp độ phân giải Full HD 1080p ở tốc độ 30fps hoặc HD 720p ở tốc độ 60fps mượt mà, giúp khung hình cử động tay và biểu cảm khuôn mặt của game thủ luôn đồng bộ theo nhịp độ game.

Khả năng tự động lấy nét nhanh và chính xác, tương thích hoàn hảo với các phần mềm phát sóng trực tuyến phổ biến như OBS Studio, Streamlabs và XSplit.', 1890000, 15, N'images/products/webcam/sp37-razer-kiyo/main.jpg', 4, GETDATE(), 1, N'Hãng sản xuất: Razer
Model: Kiyo
Độ phân giải: 1080p @ 30fps / 720p @ 60fps / 480p @ 30fps
Đèn trợ sáng: Vòng đèn LED Ring Light 5600K (12 bóng LED trắng ấm tự nhiên)
Điều chỉnh đèn: Vành xoay cơ học điều chỉnh độ sáng trực tiếp trên thân camera
Lấy nét: Tự động lấy nét nhanh (Autofocus)
Góc nhìn (FOV): Đường chéo 81.6 độ
Microphone: Micro đa hướng 16-bit 48kHz bắt âm thanh chuẩn
Chân đế: Chân đế gập chữ L thông minh kèm lỗ gắn tripod ren 1/4 inch
Kết nối: Cáp bọc dù USB 2.0 dài 1.5m
Kích thước: Đường kính 68.7 mm, độ dày 50 mm
Trọng lượng: Khoảng 200g
Phần mềm: Razer Synapse 3');

-- SP 39: Webcam Anker PowerConf C200 2K lấy nét tự động
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (39, N'Webcam Anker PowerConf C200 2K lấy nét tự động', N'Anker PowerConf C200 là mẫu webcam 2K Ultra-Clear nhỏ gọn tinh tế đến từ AnkerWork, giải pháp hoàn hảo nâng cấp hình ảnh cho các cuộc họp làm việc online và phỏng vấn tuyển dụng chuyên nghiệp.

Sở hữu độ phân giải siêu nét 2K QHD (2560x1440) với khẩu độ f/2.0 thu nhận nhiều ánh sáng hơn, giữ cho hình ảnh luôn trong trẻo và hạn chế độ hạt tối đa trong phòng làm việc thiếu sáng.

Trang bị công nghệ micro kép tích hợp trí tuệ nhân tạo AI Noise Canceling, chỉ thu giọng nói của người ngồi trực diện camera và triệt tiêu sạch sẽ tiếng ồn môi trường xung quanh như tiếng gõ phím, tiếng còi xe bên ngoài.

Nắp che ống kính vật lý Privacy Cover tích hợp ngay trên thân máy, cho phép khóa camera chỉ bằng một cú trượt ngón tay, đảm bảo an tâm tuyệt đối sau giờ làm việc.', 1290000, 20, N'images/products/webcam/sp38-anker-c200/main.jpg', 4, GETDATE(), 1, N'Hãng sản xuất: Anker (Dòng chuyên nghiệp AnkerWork)
Model: PowerConf C200
Độ phân giải: 2K QHD @ 30fps / 1080p @ 30fps
Khẩu độ ống kính: f/2.0 kích thước lớn thu sáng vượt trội
Trường nhìn (FOV): Tùy chỉnh góc 65 độ, 80 độ hoặc 95 độ qua phần mềm
Lấy nét: Tự động lấy nét siêu tốc (Fast Autofocus trong vòng 0.5s)
Microphone: Cặp micro kép tích hợp AI khử tạp âm định hướng giọng nói
Bảo mật: Cần gạt che ống kính Privacy Shutter cơ học
Chân kẹp: Chân kẹp đa năng xoay 360 độ kèm ren cắm tripod
Kết nối: Cáp USB Type-C sang Type-A tháo rời
Kích thước: 55 x 51 x 41 mm (siêu nhỏ gọn trong lòng bàn tay)
Trọng lượng: Khoảng 83g
Phần mềm hỗ trợ: AnkerWork App tùy chỉnh độ sáng, độ tương phản, FOV');

-- SP 40: Webcam Asus ROG Eye S Full HD 60FPS micro AI
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (40, N'Webcam Asus ROG Eye S Full HD 60FPS micro AI', N'Asus ROG Eye S là chiếc webcam gaming eSports siêu mỏng cao cấp chỉ dày 17mm khi gập lại, trang bị công nghệ micro khử tiếng ồn bằng trí tuệ nhân tạo AI Noise-Canceling độc quyền của ASUS.

Cung cấp chất lượng phát sóng Full HD 1080p ở tốc độ 60 khung hình/giây siêu mượt, loại bỏ hoàn toàn hiện tượng nhòe chuyển động khi game thủ tương tác biểu cảm nhanh trước ống kính.

Công nghệ Face Auto Exposure và Auto Focus tự động nhận diện khuôn mặt người dùng, làm sáng da và giữ độ nét hoàn hảo nổi bật trên nền phòng tối.

Ống kính lọc tia hồng ngoại (Blue glass) cao cấp ngăn chặn hiện tượng lóa màu và sai lệch sắc thái ánh sáng, chân đế hợp kim nhôm gấp gọn thông minh kèm lỗ ren tiêu chuẩn gắn lên mọi tripod máy ảnh.', 1990000, 14, N'images/products/webcam/sp39-asus-rog-eye-s/main.jpg', 4, GETDATE(), 1, N'Hãng sản xuất: ASUS (Dòng ROG Gaming)
Model: ROG Eye S
Độ phân giải: 1080p Full HD @ 60fps siêu mượt
Cảm biến: Cảm biến quang học chơi game chuyên dụng
Ống kính: Thấu kính kính xanh Blue Glass lọc tia hồng ngoại khử sai màu
Công nghệ xử lý: Face Auto Exposure và Auto-focus nhận diện khuôn mặt
Microphone: Micro khử ồn công nghệ AI thông minh (AI Noise-Canceling)
Thiết kế: Gập siêu mỏng chỉ 17mm (bỏ túi áo cực kỳ dễ dàng)
Chân đế: Hợp kim nhôm cao cấp chống rung kèm lỗ ren tripod
Kết nối: Cáp USB Type-A dài 1.0m cắm là nhận diện ngay
Kích thước: 81 x 28.8 x 16.6 mm (khi gập)
Trọng lượng: Khoảng 118g
Phần mềm: Armoury Crate tùy biến chất lượng hình ảnh và mic AI');

-- SP 41: Webcam A4Tech PK-910H Full HD 1080P chống lóa
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (41, N'Webcam A4Tech PK-910H Full HD 1080P chống lóa', N'A4Tech PK-910H là mẫu webcam Full HD 1080p giá rẻ bền bỉ nổi tiếng của thương hiệu A4Tech, sự lựa chọn kinh tế hàng đầu cho học sinh sinh viên học online và nhân viên văn phòng họp từ xa.

Trang bị cảm biến 1080p Full HD sắc nét cùng lớp phủ thấu kính chống lóa (Anti-glare coating), ngăn chặn hiện tượng bóng lóa phản xạ ánh sáng đèn tuýp hay ánh sáng cửa sổ phòng học.

Khớp xoay thông minh 360 độ cho phép bạn dễ dàng điều chỉnh góc quay ngang và gập lên xuống linh hoạt mà không cần phải xê dịch chân đế kẹp.

Microphone tích hợp công nghệ chống ồn kỹ thuật số lọc bớt tiếng gió quạt và tiếng vang trong phòng, chân đế gập chữ Z đa năng kẹp chắc chắn lên màn hình hoặc đặt vững trên mặt bàn.', 420000, 35, N'images/products/webcam/sp40-a4tech-pk910h/main.jpg', 4, GETDATE(), 1, N'Hãng sản xuất: A4Tech
Model: PK-910H Full HD Webcam
Độ phân giải: 1080p Full HD (1920 x 1080 pixels) @ 30fps
Loại ống kính: Ống kính phủ lớp chống phản xạ ánh sáng (Anti-Glare Coating)
Góc nhìn: 70 độ
Lấy nét: Tiêu cự cố định (Fixed focus)
Microphone: Micro kỹ thuật số tích hợp chống ồn đơn hướng
Khả năng xoay: Xoay ngang 360 độ và gập nghiêng dọc 90 độ
Chân kẹp: Chân đế gấp dạng chữ Z kẹp màn hình hoặc đứng bàn
Kết nối: USB 2.0 (chiều dài cáp 1.5m)
Kích thước: 60 x 50 x 30 mm
Trọng lượng: Khoảng 90g
Tương thích: Windows 11/10/8/7, macOS, Linux, Chrome OS');

-- SP 42: Hub chuyển đổi USB-C 8in1 Baseus Metal Gleam Series
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (42, N'Hub chuyển đổi USB-C 8in1 Baseus Metal Gleam Series', N'Hub chuyển đổi Baseus Metal Gleam Series 8in1 là trung tâm kết nối đa năng mạnh mẽ với vỏ hợp kim nhôm Anodized nguyên khối cao cấp, bổ sung cổng mạng LAN Gigabit Ethernet tốc độ 1000Mbps cực kỳ ổn định.

Trang bị 8 cổng giao tiếp đa dụng trên một thân máy nhỏ gọn: cổng HDMI 4K@30Hz cho màn hình ngoài, 3 cổng USB-A 3.0 truyền dữ liệu 5Gbps, cổng mạng RJ45 Gigabit 1000Mbps, khe cắm thẻ nhớ SD, thẻ microSD và cổng sạc nhanh Type-C PD 100W.

Cổng mạng LAN RJ45 giải quyết triệt để vấn đề mất kết nối hoặc chập chờn của Wi-Fi khi tải file lớn, họp trực tuyến quan trọng hoặc thi đấu game online mượt mà không độ trễ.

Tích hợp dải đèn LED báo nguồn màu xanh băng phong cách công nghệ cùng chip vi xử lý độc lập cho từng cổng, đảm bảo hiệu suất truyền tải tối đa ngay cả khi cắm kín tất cả các cổng cùng lúc.', 690000, 25, N'images/products/hub-cap/sp42-baseus-metal-gleam-8in1/main.jpg', 5, GETDATE(), 1, N'Hãng sản xuất: Baseus
Model: Metal Gleam Series 8-in-1 Multifunctional Type-C HUB
Cổng đầu vào: USB Type-C bọc dù gia cường chống gãy đứt
Cổng kết nối mở rộng (8 cổng):
  + 1x HDMI: Hỗ trợ xuất hình 4K @ 30Hz HD
  + 3x USB 3.0: Tốc độ truyền tải siêu tốc 5Gbps (tương thích ngược USB 2.0)
  + 1x RJ45 Gigabit Ethernet: Tốc độ mạng dây 10/100/1000 Mbps ổn định
  + 1x USB-C PD: Hỗ trợ sạc nhanh Power Delivery 100W
  + 1x Khe thẻ nhớ SD: Hỗ trợ thẻ SDXC/SDHC tốc độ 60MB/s
  + 1x Khe thẻ nhớ Micro SD (TF): Tốc độ truyền tải 60MB/s
Chất liệu vỏ: Hợp kim nhôm Anodized mờ xám vũ trụ Space Gray tản nhiệt nhanh
Đèn báo: Đèn LED chỉ báo trạng thái màu xanh băng (Ice Blue Indicator)
Kích thước: 131.5 x 44.5 x 16.5 mm
Trọng lượng: Khoảng 86.5g
Tương thích: MacBook Pro/Air, iPad Pro, Dell, Asus, Lenovo, HP, Surface, máy tính bảng và smartphone Type-C');

-- SP 43: Hub USB 3.0 4 cổng Ugreen 20291 tốc độ 5Gbps
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (43, N'Hub USB 3.0 4 cổng Ugreen 20291 tốc độ 5Gbps', N'Ugreen 20291 là bộ chia cổng USB 3.0 4 trong 1 quốc dân bán chạy nhất của Ugreen, giải pháp kinh tế và nhanh gọn giúp nhân thêm 4 cổng USB tốc độ cao từ một cổng USB duy nhất trên máy tính để bàn hoặc laptop.

Cả 4 cổng USB đều đạt chuẩn USB 3.0 SuperSpeed với tốc độ truyền tải lý thuyết lên đến 5Gbps (nhanh gấp 10 lần USB 2.0 cũ kỹ), cho phép sao chép một bộ phim chuẩn Full HD nặng 1GB chỉ trong vỏn vẹn 3 giây.

Tích hợp thêm một cổng cấp nguồn phụ Micro USB 5V thông minh, hỗ trợ cấp nguồn điện bổ sung khi cần kết nối các thiết bị tiêu thụ điện năng lớn như ổ cứng di động HDD 2.5 inch dung lượng cao lên tới 10TB.

Thiết kế dạng hộp bo tròn nhỏ gọn bỏ vừa túi quần, tích hợp chip xử lý cao cấp GL3510 đảm bảo kết nối chuột, bàn phím, USB và máy in đồng thời luôn mượt mà không bao giờ bị giật lag.', 199000, 50, N'images/products/hub-cap/sp43-ugreen-20291-hub4port/main.jpg', 5, GETDATE(), 1, N'Hãng sản xuất: UGREEN
Model: 20291 (CR106)
Cổng đầu vào: USB 3.0 Type-A đực
Cổng đầu ra: 4x USB 3.0 Type-A cái tốc độ 5Gbps
Tương thích ngược: Hoàn toàn tương thích với USB 2.0 và 1.1
Cổng nguồn phụ: Micro USB 5V (hỗ trợ cắm thêm nguồn ngoài cho ổ cứng di động tới 10TB)
Chip xử lý: Genesys Logic GL3510 thông minh bảo vệ quá dòng
Đèn báo: Đèn LED hiển thị trạng thái hoạt động màu trắng êm dịu
Chiều dài dây cáp: 0.25m (25cm) bọc nhựa PVC dẻo dai chống xoắn
Kích thước: 77 x 45 x 20 mm
Trọng lượng: Khoảng 50g
Hệ điều hành hỗ trợ: Windows 11/10/8/7/XP, macOS, Linux, Chrome OS (Cắm là nhận ngay)');

-- SP 44: Hub USB-C 6in1 Orico PW11-6P vỏ hợp kim nhôm
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (44, N'Hub USB-C 6in1 Orico PW11-6P vỏ hợp kim nhôm', N'Orico PW11-6P là bộ mở rộng Type-C 6 trong 1 với mức giá vô cùng hợp lý, sở hữu lớp vỏ hợp kim nhôm Anodized xám không gian chống vân tay và hỗ trợ xuất màn hình rời độ phân giải cao 4K@30Hz.

Sản phẩm trang bị 1 cổng HDMI 4K xuất hình sắc nét sang máy chiếu hoặc màn hình ngoài, 1 cổng sạc nhanh Type-C Power Delivery 100W, 3 cổng USB 3.0 tốc độ cao 5Gbps và 1 cổng USB 2.0 chuyên dụng cho chuột, bàn phím không dây chống nhiễu sóng.

Vỏ nhôm nguyên khối với các rãnh tản nhiệt bên trong giúp giải tỏa nhiệt lượng nhanh chóng khi truyền dữ liệu cường độ cao, đảm bảo các kết nối hoạt động bền bỉ và ổn định suốt ngày dài.

Tương thích đa nền tảng từ iPad Pro, MacBook M1/M2/M3, laptop Windows cho đến điện thoại Samsung có hỗ trợ chế độ xuất màn hình Samsung DeX.', 390000, 30, N'images/products/hub-cap/sp44-orico-pw11-6p/main.jpg', 5, GETDATE(), 1, N'Hãng sản xuất: ORICO
Model: PW11-6P
Cổng đầu vào: USB Type-C đực (dây bọc dù cao cấp dài 15cm)
Cổng kết nối (6 cổng):
  + 1x HDMI: Độ phân giải 4K @ 30Hz / Full HD 1080P @ 60Hz
  + 1x USB-C PD: Hỗ trợ sạc nhanh công suất tối đa 100W (PD 3.0)
  + 3x USB-A 3.0: Tốc độ truyền tải dữ liệu 5Gbps
  + 1x USB-A 2.0: Tối ưu cho chuột và bàn phím không dây 2.4GHz chống trễ
Chất liệu vỏ: Hợp kim nhôm + nhựa ABS tản nhiệt nhanh
Kích thước: 104 x 34 x 13 mm
Trọng lượng: Khoảng 55g
Tương thích: Windows, macOS, iPadOS, Android (hỗ trợ Samsung DeX), Linux');

-- SP 45: Cáp Type-C to Type-C 100W Anker 322 bọc dù 1.8m
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (45, N'Cáp Type-C to Type-C 100W Anker 322 bọc dù 1.8m', N'Cáp sạc Type-C to Type-C Anker 322 (100W) dài 1.8m là sợi cáp sạc siêu bền chuẩn công nghiệp thuộc dòng sản phẩm bọc sợi nylon bện kép danh tiếng của Anker, thương hiệu phụ kiện sạc số 1 tại Mỹ.

Hỗ trợ công suất sạc tối đa lên tới 100W (20V/5A) với chip e-Marker tích hợp thông minh, cáp có thể sạc nhanh tối đa cho cả MacBook Pro 16 inch, Dell XPS, iPad Pro cũng như các smartphone cao cấp hỗ trợ chuẩn PD và Quick Charge.

Lớp vỏ bọc bện sợi nylon kép chịu uốn cong hơn 12.000 lần và chịu tải kéo căng lên tới 50kg mà không hề bị đứt ngầm hay bong tróc đầu nối như các loại cáp nhựa thông thường.

Chiều dài 1.8m cực kỳ tiện lợi cho bạn thoải mái vừa cắm sạc ở ổ cắm xa dưới sàn nhà vừa nằm dùng laptop, máy tính bảng trên giường hoặc ghế sofa mà không bị hạn chế không gian.', 170000, 60, N'images/products/hub-cap/sp45-anker-322-typec-100w/main.png', 5, GETDATE(), 1, N'Hãng sản xuất: ANKER
Model: 322 USB-C to USB-C Cable (A81F6)
Chuẩn kết nối: Type-C sang Type-C
Công suất sạc hỗ trợ: Tối đa 100W (20V / 5A)
Chip quản lý nguồn: Tích hợp chip thông minh E-Marker tự điều chỉnh dòng sạc an toàn
Tốc độ truyền dữ liệu: USB 2.0 (480Mbps)
Độ bền uốn cong: Chịu hơn 12.000 lần bẻ cong theo thử nghiệm nghiêm ngặt của Anker
Chất liệu vỏ: Sợi Nylon bện kép chống rối, chịu lực kéo căng lớn
Chiều dài: 1.8 mét (6ft)
Tương thích: MacBook Pro/Air, iPad Pro, iPhone 15/16 Series, Samsung Galaxy S24 Ultra, laptop Windows Type-C');

-- SP 46: Cáp HDMI 2.1 8K@60Hz Ugreen 80403 bọc bện dù 2m
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (46, N'Cáp HDMI 2.1 8K@60Hz Ugreen 80403 bọc bện dù 2m', N'Cáp HDMI 2.1 Ugreen 80403 là dòng cáp truyền dẫn hình ảnh và âm thanh thế hệ mới nhất, đạt chứng nhận chuẩn HDMI 2.1 siêu tốc độ Ultra High Speed với băng thông khủng lên đến 48Gbps.

Hỗ trợ độ phân giải tối thượng 8K@60Hz và 4K@120Hz mượt mà đỉnh cao, hoàn hảo cho việc kết nối máy chơi game PlayStation 5, Xbox Series X hoặc card đồ họa RTX 4000 series lên TV OLED và màn hình gaming cao tần số quét.

Tích hợp đầy đủ các công nghệ gaming hàng đầu: Dynamic HDR, VRR (Variable Refresh Rate) chống xé hình, ALLM (Auto Low Latency Mode) giảm độ trễ đầu vào và eARC (Enhanced Audio Return Channel) hỗ trợ âm thanh vòm Dolby Atmos.

Đầu jack cắm bọc hợp kim nhôm mạ vàng 24K chống oxy hóa, thân cáp bọc lưới sợi dù cường lực chống mài mòn và lõi đồng nguyên chất chống nhiễu 3 lớp bảo vệ tín hiệu hoàn mỹ.', 260000, 40, N'images/products/hub-cap/sp46-ugreen-80403-hdmi8k/main.jpg', 5, GETDATE(), 1, N'Hãng sản xuất: UGREEN
Model: 80403
Chuẩn cáp: HDMI 2.1 Ultra High Speed HDMI Cable
Băng thông: Lên đến 48Gbps (gấp gần 3 lần chuẩn HDMI 2.0 18Gbps)
Độ phân giải hỗ trợ: 8K @ 60Hz, 4K @ 120Hz / 144Hz, 2K @ 165Hz / 240Hz
Công nghệ âm thanh: Hỗ trợ eARC, Dolby Atmos, DTS:X, 32 kênh âm thanh không nén
Công nghệ hình ảnh: Dynamic HDR, Dolby Vision, HDCP 2.2 & 2.3, 3D Video
Tính năng gaming: VRR (Biến thiên tần số quét), ALLM (Tự động giảm độ trễ), QFT, QMS
Đầu cắm: Chân cắm mạ vàng 24K chống oxy hóa, vỏ hợp kim kẽm siêu cứng
Chất liệu dây: Lõi đồng đóng hộp nguyên chất, vỏ bọc dù bện sợi chắc chắn
Chiều dài: 2.0 mét
Tương thích: PS5, PS4 Pro, Xbox Series X, Card đồ họa RTX 3000/4000, TV OLED 8K/4K, Apple TV 4K');

-- SP 47: Hub chuyển đổi đa năng HyperDrive 4K HDMI 6-in-1 USB-C
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (47, N'Hub chuyển đổi đa năng HyperDrive 4K HDMI 6-in-1 USB-C', N'HyperDrive 4K HDMI 6-in-1 là hub chuyển đổi Type-C cao cấp chuẩn USA của tập đoàn Sanho (Mỹ), thương hiệu phụ kiện được yêu thích hàng đầu bởi người dùng MacBook và iPad Pro trên toàn cầu.

Sở hữu thiết kế siêu tinh tế mỏng gọn với vỏ hợp kim nhôm Anodized nguyên khối gia công CNC sắc sảo, màu sắc Space Gray và Silver tương đồng 100% với màu vỏ của MacBook Apple.

Cung cấp 6 cổng kết nối thiết yếu: HDMI 4K@60Hz xuất hình ảnh siêu mượt, USB-C sạc nhanh Power Delivery 100W, 2 cổng USB-A 3.0 5Gbps, khe đọc thẻ nhớ MicroSD và thẻ SD tốc độ cao chuẩn UHS-I.

Điểm vượt trội là khả năng xuất hình HDMI 4K ở tần số quét 60Hz thực tế (thay vì chỉ 30Hz như các hub giá rẻ), mang lại trải nghiệm cuộn trang và xem video mượt mà không bị mỏi mắt.', 1190000, 15, N'images/products/hub-cap/sp47-hyperdrive-6in1/main.jpg', 5, GETDATE(), 1, N'Hãng sản xuất: HyperDrive (Sanho Corporation - USA)
Model: HyperDrive 4K HDMI 6-in-1 USB-C Hub (HD22E)
Cổng kết nối mở rộng (6 cổng):
  + 1x HDMI: Độ phân giải 4K @ 60Hz chuẩn mượt mà
  + 1x USB-C PD: Hỗ trợ sạc Pass-through lên tới 100W
  + 2x USB-A 3.0: Tốc độ truyền tải dữ liệu 5Gbps
  + 1x Khe đọc thẻ SD: Chuẩn UHS-I tốc độ 104MB/s
  + 1x Khe đọc thẻ MicroSD: Chuẩn UHS-I tốc độ 104MB/s
Chất liệu: Hợp kim nhôm Aluminum nguyên khối chuẩn Apple
Kích thước: 132 x 34 x 13 mm
Trọng lượng: Chỉ 68g
Tương thích: MacBook Pro, MacBook Air M1/M2/M3, iPad Pro, iPad Air, iMac, Dell XPS, HP Spectre');

-- SP 48: Cáp chuyển DisplayPort sang HDMI 4K Ugreen 40363 dài 1.5m
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (48, N'Cáp chuyển DisplayPort sang HDMI 4K Ugreen 40363 dài 1.5m', N'Cáp chuyển đổi DisplayPort sang HDMI Ugreen 40363 dài 1.5m là phụ kiện không thể thiếu để kết nối các máy tính để bàn PC hoặc card đồ họa có cổng DisplayPort (DP) sang màn hình ngoài, máy chiếu hoặc TV có cổng HDMI.

Hỗ trợ độ phân giải sắc nét lên tới 4K@30Hz hoặc Full HD 1080P@120Hz, truyền tải đồng thời cả hình ảnh sắc nét và âm thanh kỹ thuật số không nén chất lượng cao 7.1 kênh mà không cần thêm dây cáp âm thanh riêng biệt.

Đầu cắm DisplayPort được thiết kế chốt khóa bấm an toàn (Latch mechanism), giữ cho đầu cắm luôn gắn chặt vào cổng máy tính, loại bỏ hoàn toàn nguy cơ bị lỏng giắc hoặc tuột dây khi di chuyển bàn làm việc.

Tích hợp chip chuyển đổi tín hiệu cao cấp hỗ trợ chế độ mở rộng màn hình làm việc (Extend Mode) hoặc nhân bản màn hình (Mirror Mode) phục vụ thuyết trình chuyên nghiệp.', 190000, 35, N'images/products/hub-cap/sp48-ugreen-40363-dp-hdmi/main.jpg', 5, GETDATE(), 1, N'Hãng sản xuất: UGREEN
Model: 40363
Chuẩn chuyển đổi: DisplayPort (DP đực) sang HDMI (HDMI đực)
Độ phân giải hỗ trợ: 4K @ 30Hz (3840x2160), 2K @ 60Hz, 1080P Full HD @ 120Hz
Băng thông truyền dẫn: Lên đến 10.8Gbps
Âm thanh: Hỗ trợ âm thanh kỹ thuật số không nén 7.1, 5.1 hoặc 2 kênh
Tính năng đầu cắm DP: Có chốt bấm khóa chống tuột an toàn
Đầu cắm: Chân cắm mạ vàng 24K chống ăn mòn, truyền dẫn ổn định
Lõi cáp: Đồng nguyên chất chống nhiễu điện từ EMI
Chiều dài: 1.5 mét
Lưu ý kỹ thuật: Cáp chuyển đổi một chiều từ DisplayPort sang HDMI (Không chuyển ngược lại)');

-- SP 49: Cáp sạc nhanh 3 trong 1 Baseus Flash Series 2 100W
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (49, N'Cáp sạc nhanh 3 trong 1 Baseus Flash Series 2 100W', N'Baseus Flash Series 2 là sợi cáp sạc nhanh đa năng 3-trong-1 thế hệ mới hỗ trợ công suất khủng lên tới 100W trên cổng Type-C, giải pháp sạc tất cả trong một cho người sở hữu nhiều thiết bị công nghệ khác nhau.

Từ 1 đầu vào Type-C hoặc USB, cáp chia ra 3 đầu sạc phổ biến nhất: Type-C (hỗ trợ sạc nhanh tối đa 100W cho laptop và điện thoại), Lightning (hỗ trợ sạc nhanh 20W cho iPhone/iPad) và Micro USB (hỗ trợ sạc 10W cho loa, tai nghe, quạt mini).

Trang bị chip nhận diện sạc nhanh thông minh BPS II (Baseus Power Split) tự động phân bổ dòng điện an toàn khi cắm sạc đồng thời cả 3 thiết bị cùng lúc mà không gây quá nhiệt hay chai pin.

Thân cáp được bện sợi nylon mật độ cao với màu sắc cá tính, đầu nối hợp kim nhôm tích hợp đèn LED báo chuẩn sạc nhanh (đèn cam báo sạc nhanh, đèn xanh báo sạc thường) cực kỳ trực quan.', 230000, 45, N'images/products/hub-cap/sp49-baseus-flash-3in1/main.jpg', 5, GETDATE(), 1, N'Hãng sản xuất: Baseus
Model: Flash Series II One-for-three Fast Charging Data Cable
Đầu vào (Input): USB-C hoặc USB-A (có đầu chuyển tích hợp)
Đầu ra (Output - 3 đầu):
  + Type-C: Hỗ trợ sạc nhanh tối đa 100W (20V/5A) cho laptop và Android
  + Lightning: Hỗ trợ sạc nhanh Power Delivery 20W cho iPhone / iPad
  + Micro USB: Hỗ trợ dòng sạc chuẩn 10W (5V/2A)
Chip quản lý: Baseus Power Split II (BPS II) phân phối nguồn thông minh
Đèn báo: Đèn LED hiển thị chế độ sạc nhanh (Cam) / sạc tiêu chuẩn (Xanh)
Chất liệu: Hợp kim nhôm + Sợi bện dù Nylon cao cấp
Chiều dài: 1.2 mét
Truyền dữ liệu: Cổng Type-C hỗ trợ truyền dữ liệu 480Mbps');

-- SP 50: Đầu chuyển đổi Type-C sang USB 3.0 OTG Ugreen 50283
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (50, N'Đầu chuyển đổi Type-C sang USB 3.0 OTG Ugreen 50283', N'Đầu chuyển đổi OTG USB Type-C sang USB 3.0 Ugreen 50283 là phụ kiện chuyển đổi siêu nhỏ gọn với vỏ hợp kim nhôm Anodized sang trọng, giúp kết nối tức thì các thiết bị USB truyền thống vào cổng Type-C hiện đại.

Cho phép cắm USB flash drive, chuột, bàn phím, đầu đọc thẻ nhớ hoặc tay cầm chơi game vào trực tiếp MacBook, iPad Pro, máy tính bảng hoặc điện thoại thông minh Android hỗ trợ tính năng OTG (On-The-Go).

Đạt chuẩn tốc độ truyền dữ liệu USB 3.0 lên tới 5Gbps, cho phép đọc và sao chép các tệp ảnh dung lượng lớn, video 4K hay tài liệu công việc từ USB vào điện thoại chỉ trong tích tắc mà không cần qua máy tính trung gian.

Kích thước siêu nhỏ chỉ bằng đầu ngón tay và trọng lượng vài gram, đi kèm móc xích nhỏ để bạn có thể gắn thẳng vào chùm chìa khóa, sẵn sàng sử dụng mọi lúc mọi nơi.', 85000, 80, N'images/products/hub-cap/sp50-ugreen-50283-otg/main.jpg', 5, GETDATE(), 1, N'Hãng sản xuất: UGREEN
Model: 50283 (US270)
Cổng đầu vào: USB Type-C đực (Male)
Cổng đầu ra: USB 3.0 Type-A cái (Female)
Tốc độ truyền dữ liệu: Chuẩn USB 3.0 SuperSpeed lên tới 5Gbps
Tính năng OTG: Cắm là chạy trực tiếp trên smartphone, iPad, tablet, laptop
Chất liệu vỏ: Hợp kim nhôm xám nguyên khối tản nhiệt tốt, chống trầy xước
Trở kháng an toàn: Tích hợp điện trở kéo lên 56kΩ bảo vệ thiết bị an toàn tuyệt đối
Kích thước: 28 x 16 x 8.3 mm (siêu nhỏ gọn)
Trọng lượng: Khoảng 5g
Phụ kiện đi kèm: Dây móc treo chống thất lạc
Tương thích: MacBook Pro/Air, iPad Pro/Air, iPhone 15/16 Series, Samsung Galaxy, Xiaomi, Oppo');

-- SP 51: Giá đỡ laptop hợp kim nhôm gập gọn N3 chỉnh 6 cấp độ
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (51, N'Giá đỡ laptop hợp kim nhôm gập gọn N3 chỉnh 6 cấp độ', N'Giá đỡ laptop nhôm N3 là mẫu giá đỡ gập gọn quốc dân bán chạy nhất trên thị trường nhờ sự tiện lợi, độ chắc chắn cùng mức giá vô cùng bình dân phù hợp cho mọi học sinh sinh viên và dân văn phòng.

Toàn bộ thân giá đỡ được gia công từ hợp kim nhôm cao cấp qua quá trình xử lý cát mịn bề mặt và mạ Anodized chống oxy hóa, hỗ trợ điều chỉnh 6 nấc độ cao linh hoạt từ 5.5cm đến 15.5cm theo góc nghiêng từ 15 đến 45 độ.

Thiết kế nâng cao máy giúp màn hình laptop ngang tầm mắt tự nhiên, ngăn ngừa hiệu quả tật gù lưng, mỏi cổ vai gáy khi ngồi học và làm việc nhiều giờ liên tục trước màn hình máy tính.

Đáy giá đỡ khoét thoáng hoàn toàn giúp không khí lưu thông tối đa dưới mặt đáy laptop, hỗ trợ tản nhiệt tự nhiên hiệu quả. Các điểm tiếp xúc đều được trang bị đệm cao su silicon chống trơn trượt và chống trầy xước thân máy.', 95000, 70, N'images/products/gia-do-laptop/sp51-gia-do-n3/main.jpg', 6, GETDATE(), 1, N'Hãng sản xuất: N3 Stand
Model: N3 Aluminum Foldable Laptop Stand
Chất liệu: Hợp kim nhôm cao cấp kết hợp đệm silicon chống trượt
Số nấc điều chỉnh: 6 cấp độ cao linh hoạt (Góc nghiêng 15 độ - 45 độ)
Độ cao nâng: 55mm đến 155mm
Khả năng chịu tải: Tối đa 20kg vững chãi không rung lắc
Kích thước tương thích: Phù hợp laptop từ 11 inch đến 15.6 inch, máy tính bảng iPad, sách đọc
Tính năng tản nhiệt: Thiết kế mở thoáng đáy thông khí tự nhiên
Khả năng gập gọn: Gập lại thành một thanh dài nhỏ gọn
Kích thước khi gập: 240 x 45 x 15 mm
Trọng lượng: Khoảng 260g
Phụ kiện đi kèm: Túi vải nỉ nhung đựng giá đỡ chống bụi');

-- SP 52: Giá đỡ laptop công thái học Moft Z 4 tư thế đứng ngồi
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (52, N'Giá đỡ laptop công thái học Moft Z 4 tư thế đứng ngồi', N'MOFT Z là chiếc bàn đứng kiêm giá đỡ laptop gấp gọn nghệ thuật Origami từng đoạt giải thưởng thiết kế quốc tế Red Dot Design Award danh giá, mang đến giải pháp làm việc đứng (Sit-Stand Desk) linh hoạt mọi lúc mọi nơi.

Chỉ với thao tác gấp mở Origami đơn giản trong vòng 3 giây, MOFT Z chuyển đổi linh hoạt giữa 4 tư thế công thái học: 25 độ, 45 độ, 60 độ cho tư thế ngồi làm việc và nâng cao tới 25cm thành bàn làm việc đứng chuyên nghiệp.

Thói quen làm việc đứng xen kẽ trong ngày giúp đốt cháy calo, cải thiện lưu thông máu, giảm áp lực lên cột sống thắt lưng và tăng khả năng tập trung sáng tạo vượt bậc.

Được chế tạo từ vật liệu sợi thủy tinh gia cường bọc da PU cao cấp chống thấm nước, giá đỡ mỏng chỉ 1.2cm khi gấp phẳng nhưng có khả năng chịu tải trọng ấn tượng lên tới 10kg.', 1290000, 15, N'images/products/gia-do-laptop/sp52-moft-z/main.jpg', 6, GETDATE(), 1, N'Hãng sản xuất: MOFT
Model: MOFT Z 4-in-1 Invisible Sit-Stand Desk
Thiết kế: Cơ chế gấp nghệ thuật Origami độc quyền (Giải thưởng Red Dot Award)
Chế độ sử dụng (4 tư thế):
  + Chế độ đứng (Standing Mode): Nâng máy cao 25cm thành bàn đứng
  + Chế độ ngồi (Sitting Mode 25 độ): Tư thế gõ phím thoải mái nhất
  + Chế độ ngồi (Sitting Mode 45 độ): Góc nhìn lý tưởng duyệt tài liệu
  + Chế độ ngồi (Sitting Mode 60 độ): Chế độ hoàn hảo cho máy tính bảng vẽ hoặc đọc sách
Chất liệu: Sợi thủy tinh cứng cáp gia cường + Da PU cao cấp chống nước
Khả năng chịu tải: Lên tới 10kg (22 lbs)
Kích thước tương thích: Tất cả laptop từ 11 đến 17 inch
Độ dày khi gấp phẳng: Chỉ 1.2 cm
Kích thước: 239 x 279 x 12.7 mm
Trọng lượng: Khoảng 890g');

-- SP 53: Giá đỡ laptop xoay 360 độ Baseus Ultra Stable Pro
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (53, N'Giá đỡ laptop xoay 360 độ Baseus Ultra Stable Pro', N'Baseus Ultra Stable Pro là giá đỡ laptop xoay 360 độ cao cấp với đế xoay cơ học tích hợp tiếng click bánh cóc (mechanical ratchet) giòn giã sang trọng, cho phép chia sẻ màn hình làm việc tức thì với đồng nghiệp xung quanh.

Trang bị trục kép hợp kim nhôm hàng không siêu cứng với các vòng đệm giảm chấn chính xác, cho phép tùy chỉnh không giới hạn độ cao và độ nghiêng, giữ máy vững như bàn thạch mà không bao giờ bị trĩu xuống khi gõ phím.

Bề mặt đế đỡ được khoét các khe tản nhiệt hình học thông minh, tăng diện tích tiếp xúc với không khí giúp nhiệt lượng từ quạt tản nhiệt của laptop thoát ra nhanh chóng.

Toàn bộ giá đỡ hoàn thiện mạ kim loại xám không gian sang trọng đồng điệu với MacBook, chân đế có đệm silicon dày chống rung lắc tuyệt đối trên mặt bàn trơn.', 590000, 25, N'images/products/gia-do-laptop/sp53-baseus-ultra-stable-360/main.jpg', 6, GETDATE(), 1, N'Hãng sản xuất: Baseus
Model: Ultra Stable Series Pro Rotatable Laptop Stand
Tính năng xoay: Trục đế xoay 360 độ vô tận kèm âm thanh click bánh cóc cơ học đầm tai
Cấu trúc nâng: Trục tay đòn đôi điều chỉnh độ cao và góc nghiêng tùy ý
Chất liệu: Hợp kim nhôm siêu bền + Đệm silicon chống trượt
Tải trọng tối đa: Chịu lực tới 8kg không bị sụp lún
Tương thích kích thước: Dành cho laptop từ 11 đến 17.3 inch (MacBook, Dell, Asus, ThinkPad...)
Độ cao nâng tối đa: Lên đến 280mm
Thiết kế tản nhiệt: Mặt đỡ khoét lỗ thoáng khí khí động học
Trọng lượng: Khoảng 1150g (chân đế đầm chắc chống lật)');

-- SP 54: Giá đỡ laptop nhôm công thái học P11 nâng cao tản nhiệt
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (54, N'Giá đỡ laptop nhôm công thái học P11 nâng cao tản nhiệt', N'Giá đỡ laptop P11 Pro là mẫu giá đỡ hợp kim nhôm thế hệ mới với thiết kế tay đòn nâng đôi chịu lực vượt trội, giải pháp hoàn hảo để nâng cao màn hình laptop ngang tầm mắt và biến laptop thành máy trạm chuyên nghiệp.

Trang bị hai khớp xoay chịu tải lớn với ốc siết lục giác đi kèm, cho phép điều chỉnh độ cao từ 3cm lên tới 27cm và góc nghiêng từ 0 đến 180 độ, thích ứng hoàn hảo cho cả tư thế ngồi ghế hoặc đứng làm việc.

Mặt đỡ bằng nhôm dày 3mm được khoét các ô thoáng tản nhiệt lớn, hoạt động như một bộ tản nhiệt thụ động hấp thụ và phân tán nhiệt lượng tỏa ra từ đáy máy tính.

Hai móc đỡ phía trước uốn cong êm ái bọc đệm silicon chống trầy, giữ chắc laptop không bị trôi tuột ngay cả ở góc nghiêng dốc nhất.', 280000, 40, N'images/products/gia-do-laptop/sp54-gia-do-p11/main.jpg', 6, GETDATE(), 1, N'Hãng sản xuất: P11 Pro
Model: P11 Ergonomic Aluminum Laptop Stand
Chất liệu: Hợp kim nhôm dày 3mm sơn tĩnh điện cao cấp
Cơ chế điều chỉnh: Khớp xoay đôi vô cấp (Góc xoay 0 - 180 độ, nâng cao 30mm - 270mm)
Tải trọng hỗ trợ: Lên đến 10kg chắc chắn
Khả năng tương thích: Phù hợp cho laptop từ 10 inch đến 17 inch
Tản nhiệt: Mặt đỡ khoét ô thoáng diện tích lớn
Bảo vệ: Trang bị 6 miếng đệm silicon chống trượt và chống trầy xước viền máy
Kích thước mặt đỡ: 260 x 220 mm
Trọng lượng: Khoảng 750g
Phụ kiện đi kèm: Khóa lục giác siết chặt khớp xoay theo thời gian');

-- SP 55: Giá đỡ laptop 2 khe cắm đứng Orico nhôm nguyên khối
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (55, N'Giá đỡ laptop 2 khe cắm đứng Orico nhôm nguyên khối', N'Giá đỡ laptop đứng Orico 2 khe cắm (Dual Slot Vertical Laptop Stand) là phụ kiện tối thượng cho những ai thích phong cách bàn làm việc tối giản Clean Setup khi kết nối laptop với màn hình ngoài ở chế độ gập màn hình (Clamshell Mode).

Thiết kế 2 khe cắm song song thông minh cho phép bạn dựng đứng cùng lúc 1 chiếc laptop và 1 chiếc máy tính bảng iPad hoặc 2 chiếc laptop làm việc cùng lúc, giải phóng tới 80% không gian mặt bàn.

Khoảng cách giữa hai thành kẹp có thể điều chỉnh linh hoạt từ 14mm đến 42mm thông qua vít vặn cơ học dưới đáy, vừa vặn hoàn hảo từ chiếc MacBook Air mỏng nhẹ đến những chiếc laptop gaming dày dặn.

Được đúc từ hợp kim nhôm nguyên khối với trọng lượng đầm chắc chống đổ ngã, toàn bộ mặt trong của khe cắm đều bọc lớp đệm silicon cao cấp bảo vệ tuyệt đối lớp sơn vỏ máy khỏi mọi vết xước.', 350000, 30, N'images/products/gia-do-laptop/sp55-orico-kep-dung/main.jpg', 6, GETDATE(), 1, N'Hãng sản xuất: ORICO
Model: Dual-Slot Vertical Laptop Stand (NCS2)
Chất liệu: Hợp kim nhôm đúc nguyên khối dày dặn
Số khe cắm: 2 khe cắm đứng song song
Độ rộng khe cắm: Điều chỉnh linh hoạt từ 14mm đến 42mm bằng ốc vặn cơ học
Bảo vệ: Toàn bộ thành khe và đáy rãnh phủ đệm cao su silicon chống xước 100%
Tính năng: Dựng laptop gọn gàng khi cắm màn hình rời (Clamshell Mode)
Kích thước tương thích: Tất cả dòng MacBook Pro, MacBook Air, Dell XPS, ThinkPad, iPad
Kích thước đế: 150 x 120 x 47 mm
Trọng lượng: Khoảng 680g (chân đế đầm vững chãi chống lật tuyệt đối)
Phụ kiện đi kèm: Dụng cụ lục giác điều chỉnh độ rộng khe cắm');

-- SP 56: Giá đỡ laptop gỗ sồi tự nhiên SAMDI phong cách tối giản
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (56, N'Giá đỡ laptop gỗ sồi tự nhiên SAMDI phong cách tối giản', N'Giá đỡ laptop gỗ sồi tự nhiên SAMDI mang phong cách thiết kế mộc mạc Scandinavian Bắc Âu, đem hơi thở ấm áp của thiên nhiên vào không gian làm việc hiện đại của bạn.

Được uốn cong thủ công tinh xảo từ các lớp gỗ sồi (Oak Wood) tự nhiên nguyên khối qua kỹ thuật ép nhiệt cao tần, bề mặt được mài mịn và phủ lớp dầu thực vật bảo vệ vân gỗ tự nhiên sang trọng.

Góc nâng nghiêng 18 độ công thái học tiêu chuẩn giúp nâng cao màn hình laptop ngang tầm mắt và tạo tư thế đặt cổ tay gõ phím cực kỳ thư thái, tự nhiên.

Khoảng trống bên dưới giá đỡ là không gian lưu trữ lý tưởng để bạn cất gọn bàn phím cơ hoặc chuột sau khi hết giờ làm việc, giữ cho góc bàn luôn ngăn nắp và tinh tươm.', 390000, 20, N'images/products/gia-do-laptop/sp56-samdi-go-soi/main.jpg', 6, GETDATE(), 1, N'Hãng sản xuất: SAMDI
Model: Curved Wooden Laptop Stand
Chất liệu: Gỗ sồi tự nhiên (Natural Oak Wood) ép uốn cong nhiều lớp
Xử lý bề mặt: Mài nhẵn thủ công phủ sơn gốc nước thân thiện môi trường
Góc nghiêng: 18 độ công thái học nâng đỡ cổ tay tự nhiên
Khả năng chịu tải: Lên tới 15kg
Tương thích: MacBook 12/13/15/16 inch, laptop từ 11 đến 15.6 inch
Tính năng: Nâng cao tầm mắt, tản nhiệt đáy thoáng khí và tạo hộc cất bàn phím
Đệm chống trượt: 4 miếng đệm nỉ cao su dưới chân đế chống trượt trên mặt bàn
Kích thước: 260 x 255 x 125 mm
Trọng lượng: Khoảng 450g');

-- SP 57: Giá đỡ laptop kiêm máy tính bảng N8 hợp kim nhôm đôi
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (57, N'Giá đỡ laptop kiêm máy tính bảng N8 hợp kim nhôm đôi', N'Giá đỡ laptop N8 Pro là phiên bản nâng cấp hai tầng (Dual-layer) đột phá từ dòng N3 kinh điển, trang bị hệ thống thanh giằng đôi kép cho phép điều chỉnh cả độ cao tầng trên lẫn góc nghiêng tầng dưới.

Cung cấp tới 10 nấc điều chỉnh độ cao tầng dưới và 6 nấc điều chỉnh tầng trên, cho phép nâng máy cao tới hơn 20cm, biến màn hình laptop ngang tầm mắt tương đương một màn hình PC chuyên dụng.

Chế tác từ hợp kim nhôm đúc gia cường cứng cáp gấp đôi so với các dòng giá đỡ đơn tầng, hỗ trợ nâng đỡ an toàn các dòng máy trạm nặng và laptop gaming kích thước lớn tới 17.3 inch.

Khả năng gập rút thông minh thu nhỏ thành một thanh dài nhỏ gọn, dễ dàng bỏ vào túi vải đi kèm mang theo làm việc tại văn phòng, thư viện hay đi công tác xa.', 180000, 50, N'images/products/gia-do-laptop/sp57-gia-do-n8/main.jpg', 6, GETDATE(), 1, N'Hãng sản xuất: N8 Pro Stand
Model: N8 Dual-Tier Folding Laptop Stand
Chất liệu: Hợp kim nhôm dày dặn mạ Anodized + Đệm cao su silicon
Cơ chế nâng: Thiết kế 2 tầng thanh giằng kép nâng cao tối đa
Số nấc điều chỉnh: 16 cấp độ điều chỉnh kết hợp giữa 2 tầng
Độ cao nâng tối đa: Lên đến 210mm (vượt trội so với giá đỡ 1 tầng)
Khả năng chịu tải: Tối đa 25kg cực kỳ vững vàng
Tương thích: Laptop 11 - 17.3 inch, máy tính bảng, máy vẽ đồ họa, sách
Khả năng gập: Gập rút 2 chiều thành thanh dài bỏ túi
Kích thước khi gập: 290 x 45 x 25 mm
Trọng lượng: Khoảng 450g
Phụ kiện: Túi nỉ đựng chống trầy xước cao cấp');

-- SP 58: Giá đỡ laptop công thái học cao cấp Rain Design mStand
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (58, N'Giá đỡ laptop công thái học cao cấp Rain Design mStand', N'Rain Design mStand là chiếc giá đỡ laptop cao cấp mang tính biểu tượng toàn cầu đến từ San Francisco (USA), được bình chọn là chiếc giá đỡ laptop hoàn hảo nhất dành cho người dùng Apple MacBook.

Được gia công từ một tấm hợp kim nhôm Anodized nguyên khối duy nhất uốn cong hình giọt nước liền mạch, mStand sở hữu chất lượng hoàn thiện đỉnh cao tương đồng 100% với thân nhôm của máy tính Apple.

Nâng màn hình laptop lên độ cao chuẩn công thái học 150mm giúp cải thiện tư thế ngồi làm việc, góc nghiêng nhẹ hướng về phía trước đưa màn hình lại gần mắt hơn đồng thời tăng cường đối lưu luồng khí mát làm mát đáy máy.

Lỗ khoét luồn dây cáp hình giọt nước phía sau giúp sắp xếp các sợi dây nguồn và cáp kết nối gọn gàng tinh tế, tạo nên một góc làm việc đẳng cấp chuẩn doanh nhân.', 1490000, 12, N'images/products/gia-do-laptop/sp58-rain-design-mstand/main.jpg', 6, GETDATE(), 1, N'Hãng sản xuất: Rain Design Inc. (San Francisco, USA)
Model: mStand Laptop Stand (10032)
Chất liệu: Một tấm hợp kim nhôm nguyên khối (Single solid piece of aluminum)
Độ cao nâng: 150mm (5.9 inch) chuẩn công thái học y tế
Màu sắc: Space Gray / Silver chuẩn màu MacBook Apple
Thiết kế tản nhiệt: Tấm nhôm hoạt động như bộ tản nhiệt tản nhiệt thụ động khổng lồ
Quản lý dây cáp: Lỗ luồn cáp hình giọt nước đặc trưng phía sau
Tương thích: Tất cả các dòng MacBook Air, MacBook Pro và laptop có độ dày dưới 26mm
Kích thước: 253 x 190 x 150 mm
Trọng lượng: 1360g (cực kỳ đầm chắc và kiên cố trên bàn làm việc)');

-- SP 59: Giá đỡ laptop Ugreen 40289 hợp kim nhôm gập mở linh hoạt
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (59, N'Giá đỡ laptop Ugreen 40289 hợp kim nhôm gập mở linh hoạt', N'Giá đỡ laptop Ugreen 40289 (LP310) là dòng giá đỡ hợp kim nhôm chính hãng cao cấp của Ugreen với cấu trúc khung đỡ tam giác kép siêu vững chãi, chống rung lắc hoàn toàn khi gõ phím trực tiếp trên laptop.

Hỗ trợ 5 nấc điều chỉnh góc nghiêng công thái học từ 15 độ đến 33 độ, cho phép bạn dễ dàng lựa chọn tư thế nhìn màn hình và gõ phím thoải mái nhất, hạn chế tối đa cảm giác đau mỏi cổ tay và đốt sống cổ.

Toàn bộ các góc cạnh đều được cắt vát kim cương CNC sắc sảo, bề mặt mạ kim loại nhám mờ chống bám vân tay và hệ thống đệm silicon chống trượt bao phủ toàn diện mặt đỡ và chân đế.

Cơ chế gấp gọn phẳng mỏng chỉ 1.5cm, tặng kèm túi vải nỉ chống trầy cao cấp tiện lợi cho bạn cất gọn vào ngăn chống sốc của balo để đồng hành trên mọi chuyến đi.', 390000, 28, N'images/products/gia-do-laptop/sp59-ugreen-40289/main.jpg', 6, GETDATE(), 1, N'Hãng sản xuất: UGREEN
Model: 40289 (LP310)
Chất liệu: Hợp kim nhôm cao cấp gia công CNC + Silicon chống trượt
Số nấc điều chỉnh: 5 cấp độ góc nghiêng linh hoạt (15 độ - 33 độ)
Độ cao nâng: 86.8mm đến 131.6mm
Khả năng chịu tải: Lên đến 20kg vững vàng
Tương thích: Phù hợp cho laptop từ 11 inch đến 17.3 inch
Thiết kế tản nhiệt: Mặt đáy khoét rỗng hoàn toàn tăng luồng gió làm mát
Kích thước khi mở: 270 x 235 x 131 mm
Kích thước khi gập: 270 x 55 x 15 mm
Trọng lượng: Khoảng 235g
Phụ kiện đi kèm: Túi đựng nỉ xám cao cấp của Ugreen');

-- SP 60: Giá đỡ laptop dựng dọc Ugreen LP258 nhôm xám cho Macbook
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (60, N'Giá đỡ laptop dựng dọc Ugreen LP258 nhôm xám cho Macbook', N'Giá đỡ laptop dựng dọc Ugreen LP258 là giải pháp thông minh giúp giải phóng tối đa diện tích mặt bàn làm việc, bảo vệ chiếc máy tính xách tay yêu quý khỏi nguy cơ bị đổ nước hay cà phê vô ý trên bàn.

Trang bị núm vặn cơ học lớn mạ crôm ở cạnh bên, cho phép bạn nới rộng hoặc siết chặt khe kẹp từ 12mm đến 26mm một cách nhẹ nhàng mà không cần dùng đến bất kỳ công cụ vít hay lục giác phức tạp nào.

Được đúc từ hợp kim nhôm nguyên khối với chân đế mở rộng bản lớn đầm chắc, giữ cho laptop luôn đứng thẳng tắp kiên cố, không bao giờ bị chông chênh hay ngã đổ ngay cả khi chạm tay vào.

Lòng khe kẹp và mặt đáy giá đỡ được bọc đệm silicon dẻo mềm dày dặn 360 độ, đảm bảo chiếc MacBook Pro hay ThinkPad đắt tiền của bạn không bị một vết trầy xước nhỏ nào.', 320000, 35, N'images/products/gia-do-laptop/sp60-ugreen-lp258-doc/main.jpg', 6, GETDATE(), 1, N'Hãng sản xuất: UGREEN
Model: LP258 (Vertical Laptop Stand)
Chất liệu: Hợp kim nhôm nguyên khối phay CNC cao cấp
Cơ chế điều chỉnh: Núm xoay tay cơ học tiện lợi (không cần dùng dụng cụ)
Độ rộng khe kẹp: Điều chỉnh vô cấp từ 12mm đến 26mm
Bảo vệ: Toàn bộ mặt trong khe kẹp lót cao su silicon mềm chống xước 360 độ
Đế chống trượt: Đệm cao su silicon lớn dưới đáy bám dính chắc chắn trên mặt bàn
Tương thích: MacBook Pro, MacBook Air M1/M2/M3, Surface, Dell XPS, HP, Lenovo có độ dày dưới 26mm
Kích thước đế: 150 x 78 x 50 mm
Trọng lượng: Khoảng 290g
Màu sắc: Xám không gian (Space Gray) sang trọng');

-- SP 61: Đế tản nhiệt laptop Cooler Master Notepal X-Slim
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (61, N'Đế tản nhiệt laptop Cooler Master Notepal X-Slim', N'Cooler Master Notepal X-Slim là mẫu đế tản nhiệt laptop mỏng nhẹ kinh điển của thương hiệu tản nhiệt máy tính số 1 thế giới Cooler Master, thiết kế để giải nhiệt hiệu quả cho laptop làm việc và gaming.

Sở hữu quạt làm mát kích thước khổng lồ 160mm đặt chính giữa, tạo ra luồng gió làm mát diện rộng bao phủ toàn bộ khu vực CPU và GPU dưới đáy laptop với tốc độ 1400 vòng/phút nhưng độ ồn cực thấp chỉ 21 dBA.

Bề mặt đế làm từ lưới kim loại đục lỗ khí động học hình chữ X mang tính biểu tượng, tối đa hóa lưu lượng khí mát đối lưu và tăng khả năng thoát nhiệt nhanh chóng khỏi khung máy.

Thiết kế siêu mỏng chỉ 27.5mm cùng trọng lượng nhẹ chỉ 700g, tích hợp rãnh quấn dây USB thông minh dưới đáy và cổng cắm USB Pass-through không làm mất cổng USB của laptop.', 390000, 30, N'images/products/de-tan-nhiet/sp61-cm-notepal-xslim/main.jpg', 7, GETDATE(), 1, N'Hãng sản xuất: Cooler Master
Model: NotePal X-Slim (R9-NBC-XSLI-GP)
Kích thước quạt: 1x Quạt lớn 160 x 160 x 15 mm
Tốc độ quạt: 1400 +- 15% RPM
Lưu lượng gió: 70 CFM luồng gió làm mát cực mạnh
Độ ồn: 21 dBA (hoạt động cực kỳ êm ái trong phòng yên tĩnh)
Chất liệu: Lưới kim loại đục lỗ khí động học + Nhựa gia cường cao cấp
Góc nâng: Chân đế chỉnh 2 nấc độ nghiêng công thái học
Cổng kết nối: Cổng USB Pass-Through (Cắm nguồn quạt mà vẫn giữ lại cổng cắm USB cho thiết bị khác)
Tương thích kích thước: Hỗ trợ laptop từ 12 inch đến 17 inch
Kích thước: 380 x 270 x 27.5 mm
Trọng lượng: Khoảng 700g');

-- SP 62: Đế tản nhiệt laptop Cooler Master Notepal L2 LED xanh
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (62, N'Đế tản nhiệt laptop Cooler Master Notepal L2 LED xanh', N'Cooler Master Notepal L2 là giải pháp làm mát mỏng nhẹ giá hợp lý tiếp theo của Cooler Master, trang bị quạt tản nhiệt đường kính lớn 160mm kết hợp dải đèn LED xanh lam dịu mắt tạo điểm nhấn ấn tượng.

Bề mặt lưới nhôm hoàn thiện tỉ mỉ giúp luồng không khí mát được phân tán đều khắp đáy laptop, hạ nhiệt độ tức thì cho phần cứng khi làm việc đồ họa render hoặc cày game liên tục.

Góc nghiêng 8 độ công thái học được tính toán tối ưu để nâng đỡ cổ tay tự nhiên, cải thiện tư thế mắt nhìn vào màn hình và tạo khoảng trống đáy cho luồng khí lưu thông tốt hơn.

Tích hợp thêm một cổng USB bổ sung ở mặt sau và công tắc bật/tắt quạt tiện lợi, trọng lượng nhẹ chỉ 640g giúp bạn dễ dàng di chuyển từ bàn làm việc ra phòng khách hay quán cà phê.', 420000, 25, N'images/products/de-tan-nhiet/sp62-cm-notepal-l2/main.jpg', 7, GETDATE(), 1, N'Hãng sản xuất: Cooler Master
Model: NotePal L2 (MNW-SWTS-14FN-R1)
Kích thước quạt: 160 x 160 x 15 mm
Tốc độ quạt: 1400 +- 15% RPM / Lưu lượng gió: 6 - 20 CFM
Độ ồn: 29 dBA
Đèn LED: LED màu xanh lam (Blue LED) phát sáng qua cánh quạt trong suốt
Góc nâng: 8 độ công thái học chống mỏi cổ tay
Cổng kết nối: Cổng USB 2.0 cấp nguồn + Cổng USB mở rộng tiện ích
Chất liệu: Mặt lưới nhôm tản nhiệt kim loại + Khung nhựa ABS
Kích thước tương thích: Laptop lên tới 17 inch
Kích thước: 379 x 285 x 47.5 mm
Trọng lượng: Khoảng 640g');

-- SP 63: Đế tản nhiệt gaming IETS GT500 tốc độ hút gió 5000 RPM
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (63, N'Đế tản nhiệt gaming IETS GT500 tốc độ hút gió 5000 RPM', N'IETS GT500 là ''quái vật tản nhiệt'' laptop gaming mạnh nhất hành tinh hiện nay, trang bị quạt tuabin phản lực công nghiệp tốc độ khủng khiếp lên tới 5000 RPM có khả năng hạ nhiệt độ CPU và GPU tức thì từ 15 đến 25 độ C.

Điểm đột phá làm nên tên tuổi của GT500 là vòng đệm mút cao su hoạt tính (Sealing Foam Ring) ôm khít 100% đáy máy tính, tạo thành khoang kín áp suất dương cưỡng bức ép toàn bộ luồng khí lạnh trực tiếp vào các khe hút gió của laptop mà không bị thất thoát ra ngoài.

Núm xoay chiết áp vô cấp cho phép điều chỉnh tốc độ quạt mượt mà từ 0 đến 5000 vòng/phút tùy theo nhu cầu làm việc tĩnh âm hay kéo game nặng nề như Cyberpunk 2077, Black Myth: Wukong.

Tích hợp màng lọc bụi có thể tháo rời ở đáy hút gió, ngăn chặn triệt để xơ vải và bụi mịn xâm nhập vào bên trong tản nhiệt của chiếc laptop đắt tiền.', 1890000, 12, N'images/products/de-tan-nhiet/sp63-iets-gt500/main.png', 7, GETDATE(), 1, N'Hãng sản xuất: IETS
Model: GT500 Powerful Turbo-Fan Laptop Cooling Pad
Loại quạt: Quạt tuabin công nghiệp áp suất cao (Industrial Grade Turbofan)
Tốc độ quạt: Điều chỉnh vô cấp từ 0 lên tới 5000 RPM qua núm xoay chiết áp
Công nghệ độc quyền: Vòng đệm mút xốp Sealing Foam tạo buồng áp suất kín 360 độ
Khả năng hạ nhiệt: Giảm 15 - 25 độ C nhiệt độ CPU/GPU tức thì trong 2 phút
Lọc bụi: Trang bị màng lọc bụi tháo rời giặt sạch được (Removable Dust Filter)
Nguồn cấp: Bộ nguồn adapter rời DC 12V công suất cao chuyên dụng
Chân đế: Chân đế kim loại chỉnh 7 nấc độ cao vững vàng
Tương thích: Tất cả laptop gaming tản nhiệt đáy từ 13 đến 17.3 inch
Kích thước: 400 x 312 x 66 mm
Trọng lượng: Khoảng 1200g');

-- SP 64: Đế tản nhiệt laptop 6 quạt LED RGB Kootek Chill Control
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (64, N'Đế tản nhiệt laptop 6 quạt LED RGB Kootek Chill Control', N'Đế tản nhiệt laptop Kootek Chill Control 6 quạt là sự lựa chọn làm mát toàn diện nhờ bố trí tới 6 quạt tản nhiệt độc lập, giải quyết đồng thời mọi điểm nóng cục bộ trên bo mạch chủ của máy tính xách tay.

Bao gồm 3 quạt lớn 100mm ở trung tâm và 3 quạt nhỏ 70mm ở các góc, hỗ trợ điều chỉnh độc lập 3 chế độ quạt: bật 3 quạt, bật 4 quạt hoặc bật toàn bộ 6 quạt để tối ưu hóa theo vị trí tỏa nhiệt của từng dòng máy.

Hệ thống đèn LED RGB viền cạnh chuyển màu sống động với nhiều hiệu ứng ánh sáng gaming rực rỡ, kèm màn hình LCD nhỏ và phím bấm điều chỉnh tốc độ gió trực quan ngay trước mặt.

Chân đế có thể điều chỉnh 7 nấc độ cao công thái học khác nhau, tích hợp thanh gạt chống trượt gập mở ở phía trước giữ laptop cố định vững vàng ngay cả ở góc nghiêng cao nhất.', 450000, 35, N'images/products/de-tan-nhiet/sp64-kootek-chill-6quat/main.jpg', 7, GETDATE(), 1, N'Hãng sản xuất: Kootek (Chill Series)
Model: 6-Fan RGB Laptop Cooling Pad
Cấu hình quạt: 6 quạt (3x quạt 100mm tốc độ cao + 3x quạt 70mm làm mát góc)
Tốc độ quạt: 1200 - 2400 RPM (điều chỉnh 6 mức tốc độ qua màn hình LCD)
Đèn nền: Đèn LED xanh trong quạt + Dải viền LED RGB 10 hiệu ứng màu sắc
Màn hình điều khiển: Màn hình LCD mini hiển thị tốc độ gió kèm phím bấm chuyển chế độ
Độ ồn: 23 - 26 dBA
Góc nghiêng: 7 nấc điều chỉnh độ cao từ 10 đến 45 độ
Cổng kết nối: 2 cổng USB 2.0 (1 cổng nhận nguồn, 1 cổng cắm phụ kiện)
Tương thích: Laptop từ 12 inch đến 17.3 inch
Kích thước: 410 x 296 x 40 mm
Trọng lượng: Khoảng 850g');

-- SP 65: Đế tản nhiệt laptop Deepcool U-Pal hình chữ U quạt kép 140mm
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (65, N'Đế tản nhiệt laptop Deepcool U-Pal hình chữ U quạt kép 140mm', N'Deepcool U-Pal là mẫu đế tản nhiệt mang thiết kế hình chữ U độc đáo lấy cảm hứng từ cấu trúc cung điện vòm cung, kết hợp giữa luồng khí động học rỗng trung tâm và cặp quạt đôi 140mm hiệu năng cao.

Khe hở rỗng chữ U ở giữa chia tách hai luồng khí nóng lạnh riêng biệt, giúp luồng khí nóng tỏa ra từ đáy laptop thoát ra nhanh chóng sang hai bên mà không bị quạt hút ngược trở lại như các đế thông thường.

Trang bị cặp quạt kép đường kính lớn 140mm siêu tĩnh với tốc độ 1000 RPM, tạo lưu lượng gió dồi dào trực tiếp vào hai khe tản nhiệt chính của CPU và GPU trên laptop.

Chân đế kim loại có thể tùy chỉnh 6 góc độ nghiêng làm việc thoải mái, đầu cáp kết nối USB 3.0 Pass-through thông minh tốc độ cao không chiếm mất cổng USB 3.0 quý giá trên laptop của bạn.', 350000, 25, N'images/products/de-tan-nhiet/sp65-deepcool-upal/main.jpg', 7, GETDATE(), 1, N'Hãng sản xuất: Deepcool
Model: U-Pal (U-Shaped Laptop Cooler)
Thiết kế khí động học: Cấu trúc chữ U rỗng trung tâm chống hút ngược khí nóng
Cấu hình quạt: 2x Quạt lớn 140 x 140 x 15 mm
Tốc độ quạt: 1000 +- 10% RPM / Lưu lượng gió: 92.22 CFM cực lớn
Độ ồn: Siêu êm 26.3 dBA
Góc nâng: Chân chống điều chỉnh 6 cấp độ cao công thái học
Cổng kết nối: Cổng cắm USB 3.0 Pass-through tốc độ 5Gbps
Chất liệu: Mặt lưới kim loại tổ ong + Nhựa ABS kỹ thuật
Khả năng chịu tải: Laptop lên đến 15.6 inch
Kích thước: 390 x 280 x 27.5 mm
Trọng lượng: Khoảng 765g');

-- SP 66: Đế tản nhiệt laptop gaming Llano RGB điều tốc tuabin phản lực
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (66, N'Đế tản nhiệt laptop gaming Llano RGB điều tốc tuabin phản lực', N'Đế tản nhiệt Llano RGB là dòng tản nhiệt cao cấp sử dụng quạt tuabin phản lực ly tâm đường kính siêu lớn 14cm, đối thủ xứng tầm nhất của IETS GT500 với phong cách thiết kế hiện đại và dải LED RGB đậm chất gaming.

Áp dụng nguyên lý tản nhiệt áp suất kín khí với đệm mút silicon từ tính đàn hồi cao, ép kín không gian đáy laptop và đẩy toàn bộ luồng khí lạnh cực mạnh xuyên qua từng lá tản nhiệt tản nhiệt bên trong máy.

Bảng điều khiển cảm ứng kỹ thuật số với màn hình LED sắc nét hiển thị chính xác tốc độ vòng quay của quạt, cho phép bạn tăng giảm tốc độ quạt từ 300 RPM đến 2800 RPM chỉ bằng một cú chạm ngón tay.

Tích hợp dải đèn viền LED RGB rực rỡ với nhiều hiệu ứng sóng màu đồng bộ, màng lọc bụi kim loại có thể tháo rời bảo vệ laptop khỏi mọi bụi bẩn.', 1450000, 15, N'images/products/de-tan-nhiet/sp66-llano-rgb-tuabin/main.jpg', 7, GETDATE(), 1, N'Hãng sản xuất: Llano
Model: Gaming Turbofan Laptop Cooler Pad (V12 RGB)
Loại quạt: Quạt tuabin ly tâm kích thước lớn 140mm áp lực gió cực cao
Tốc độ quạt: 300 - 2800 RPM (Điều khiển cảm ứng kỹ thuật số kèm màn hình LED hiển thị tốc độ)
Cơ chế làm mát: Đệm bọt biển silicon kín áp suất cao 360 độ
Hiệu quả giảm nhiệt: Giảm từ 15 đến 22 độ C cho CPU/GPU
Đèn nền: Dải viền LED RGB đa hiệu ứng chuyển động gaming
Lọc bụi: Màng lọc bụi kim loại mật độ cao tháo lắp nhanh
Cổng kết nối: Cổng Type-C cấp nguồn kèm bộ nguồn chuyên dụng
Tương thích: Laptop gaming từ 13 inch đến 19 inch (Asus ROG, Acer Predator, Lenovo Legion, MSI, Alienware)
Trọng lượng: Khoảng 1100g');

-- SP 67: Đế tản nhiệt laptop 2 quạt 140mm N191 siêu bền
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (67, N'Đế tản nhiệt laptop 2 quạt 140mm N191 siêu bền', N'Đế tản nhiệt laptop N191 là chiếc đế tản nhiệt giá rẻ quốc dân bền bỉ quen thuộc với nhiều thế hệ học sinh, sinh viên và nhân viên văn phòng tại Việt Nam nhờ độ bền vượt thời gian và chi phí cực kỳ tiết kiệm.

Trang bị cặp quạt đôi đường kính 140mm hoạt động êm ả với tốc độ 1200 RPM, kết hợp đèn LED xanh dương dịu mắt mang lại luồng gió mát mẻ xua tan hơi nóng từ mặt đáy laptop.

Mặt đỡ bằng lưới kim loại sơn tĩnh điện chống gỉ sét với hàng trăm lỗ thông khí li ti, tạo điều kiện cho luồng không khí được lưu thông liên tục và đối lưu nhiệt tự nhiên.

Chân chống gập mở tạo góc nghiêng công thái học 9 độ gõ phím thoải mái, dây cáp nguồn USB tích hợp đầu cắm Pass-through tiện lợi không chiếm mất cổng cắm USB của máy tính.', 120000, 60, N'images/products/de-tan-nhiet/sp67-n191-2quat/main.jpg', 7, GETDATE(), 1, N'Hãng sản xuất: N191 Series
Model: N191 Dual-Fan Cooling Pad
Cấu hình quạt: 2x Quạt 140 x 140 x 15 mm
Tốc độ quạt: 1200 +- 10% RPM
Đèn LED: Đèn LED màu xanh dương (Blue LED) gắn trong tâm quạt
Độ ồn: 15 dBA (hoạt động gần như hoàn toàn tĩnh âm)
Chất liệu: Mặt lưới sắt sơn tĩnh điện màu đen + Khung nhựa ABS
Góc nâng: Chân đế nẹp nâng nghiêng 9 độ công thái học
Cổng cắm: Đầu cắm USB lấy nguồn kiêm cổng cắm Pass-Through tiện ích
Kích thước tương thích: Phù hợp cho laptop từ 11 inch đến 15.6 inch
Kích thước: 350 x 250 x 25 mm
Trọng lượng: Khoảng 480g');

-- SP 68: Đế tản nhiệt laptop Cooler Master Ergostand IV cao cấp
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (68, N'Đế tản nhiệt laptop Cooler Master Ergostand IV cao cấp', N'Cooler Master Ergostand IV là dòng đế tản nhiệt công thái học công nghiệp cao cấp nhất của Cooler Master, kết hợp hoàn hảo giữa khả năng làm mát cực đỉnh và khả năng điều chỉnh độ cao linh hoạt như một giá đỡ chuyên dụng.

Trang bị quạt làm mát kích thước khủng 140mm với cánh quạt khí động học hình lưỡi liềm (aerodynamic fan blades) cho luồng khí mát mạnh mẽ bao trọn đáy máy nhưng độ ồn cực thấp chỉ 21 dBA.

Khung đỡ kim loại gia cường chịu lực nặng cho phép tùy chỉnh tới 5 nấc độ cao công thái học từ góc phẳng đến góc nghiêng dốc đứng, giúp đưa màn hình laptop ngang tầm mắt để giải phóng áp lực cổ vai gáy.

Tích hợp cụm Hub mở rộng 4 cổng USB 2.0 phía sau và dải đèn LED xanh lam trang nhã viền quanh thân, cùng con lăn chiết áp điều chỉnh tốc độ quạt cơ học mượt mà.', 950000, 16, N'images/products/de-tan-nhiet/sp68-cm-ergostand-iv/main.jpg', 7, GETDATE(), 1, N'Hãng sản xuất: Cooler Master
Model: ErgoStand IV (R9-NBS-E42K-GP)
Kích thước quạt: 1x Quạt lớn 140 x 140 x 20 mm cánh lưỡi liềm
Tốc độ quạt: 700 - 1400 +- 150 RPM (điều chỉnh qua núm xoay chiết áp)
Lưu lượng gió: 46.8 CFM / Áp suất gió: 1.45 mmH2O / Độ ồn: 29 dBA
Góc nâng: 5 nấc điều chỉnh độ cao công thái học vững chắc
Hub kết nối mở rộng: 4x Cổng USB 2.0 + 1x Cổng Micro USB nguồn phụ + 1x Cổng Mini USB cấp nguồn
Chất liệu: Lưới kim loại dày dặn + Khung nhựa kỹ thuật và thép chịu lực
Tương thích: Hỗ trợ mọi laptop lên đến 17 inch
Kích thước: 370 x 265 x 40 mm
Trọng lượng: Khoảng 1020g');

-- SP 69: Đế tản nhiệt laptop Opolar LC05 dạng hút gió gắn sườn hiển thị LED
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (69, N'Đế tản nhiệt laptop Opolar LC05 dạng hút gió gắn sườn hiển thị LED', N'Opolar LC05 là thiết bị tản nhiệt dạng hút gió cưỡng bức (Vacuum Cooler) độc đáo gắn trực tiếp vào khe thoát nhiệt bên sườn hoặc phía sau của laptop, hút thẳng khí nóng bên trong buồng tản nhiệt ra ngoài.

Khác với đế thổi gió từ dưới lên, cơ chế hút gió chân không của LC05 hoạt động như một máy hút phản lực, cưỡng bức rút khí nóng từ cụm heatsink của CPU và GPU ra ngoài với tốc độ gấp nhiều lần, hạ từ 10 đến 18 độ C nhanh chóng.

Màn hình LED kỹ thuật số thông minh phía trên tự động hiển thị nhiệt độ luồng khí nóng thoát ra theo thời gian thực, cho bạn theo dõi chính xác mức độ mát mẻ của hệ thống khi chạy tải nặng.

Hỗ trợ 2 chế độ: Chế độ tự động Auto điều tốc theo nhiệt độ máy và chế độ chỉnh tay Manual với 13 nấc tốc độ quạt tối đa lên tới 4200 RPM, đi kèm 3 miếng đệm silicon tương thích hầu hết khe tản nhiệt laptop.', 380000, 25, N'images/products/de-tan-nhiet/sp69-opolar-lc05/main.jpg', 7, GETDATE(), 1, N'Hãng sản xuất: OPOLAR
Model: LC05 Laptop Vacuum Fan Cooler
Cơ chế làm mát: Hút chân không cưỡng bức trực tiếp từ khe thoát nhiệt heatsink
Tốc độ quạt tuabin: Lên tới 4200 RPM (13 nấc điều chỉnh tốc độ)
Màn hình hiển thị: Màn hình LED kỹ thuật số hiển thị nhiệt độ luồng khí nóng thời gian thực
Chế độ hoạt động: Tự động điều tốc (Auto Mode) và Chỉnh tay (Manual Mode)
Hiệu quả giảm nhiệt: Giảm 10 - 18 độ C trong vòng 5 phút chơi game
Phụ kiện silicon: Kèm 3 đầu hút bọc silicon kích cỡ khác nhau ôm khít mọi khe thoát gió
Cách cố định: Cánh tay kẹp kim loại cố định đáy máy tính chống rơi tuột
Nguồn điện: Cáp USB 5V cắm trực tiếp từ cổng laptop
Kích thước: 125 x 82 x 40 mm (nhỏ gọn bỏ túi áo)
Trọng lượng: Khoảng 150g');

-- SP 70: Đế tản nhiệt laptop Havit HV-F2056 siêu mỏng 3 quạt êm ái
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (70, N'Đế tản nhiệt laptop Havit HV-F2056 siêu mỏng 3 quạt êm ái', N'Havit HV-F2056 là mẫu đế tản nhiệt laptop siêu mỏng bán chạy nhất trên sàn thương mại điện tử quốc tế Amazon với hàng trăm nghìn đánh giá 5 sao nhờ thiết kế thanh lịch, độ êm tuyệt đối và độ bền đáng kinh ngạc.

Sở hữu 3 quạt tản nhiệt kích thước lớn 110mm phân bổ đều theo hình tam giác, quay ở tốc độ 1100 RPM nhẹ nhàng với độ ồn gần như bằng không (dưới 20 dBA), không gây bất kỳ tiếng vo ve khó chịu nào khi làm việc trong đêm tĩnh mịch.

Mặt lưới kim loại cao cấp đa hướng vừa tạo vẻ ngoài hiện đại, vừa tối ưu hóa luồng gió làm mát vào mọi vị trí khe tản nhiệt của laptop từ 15.6 đến 17 inch.

Thân đế siêu mỏng nhẹ chỉ dày khoảng 2.8cm, mặt sau trang bị 2 cổng cắm USB và công tắc xoay điều chỉnh tốc độ gió kết hợp chân nẹp 2 cấp độ cao công thái học.', 320000, 30, N'images/products/de-tan-nhiet/sp70-havit-hvf2056/main.jpg', 7, GETDATE(), 1, N'Hãng sản xuất: HAVIT
Model: HV-F2056 Slim Laptop Cooling Pad
Cấu hình quạt: 3x Quạt lớn 110 x 110 x 20 mm
Tốc độ quạt: 1100 +- 200 RPM
Lưu lượng gió: 65 CFM / Độ ồn: Dưới 20 dBA (siêu tĩnh âm)
Đèn nền: Đèn LED xanh lam dịu mát xuyên cánh quạt
Mặt lưới: Kim loại dập lỗ đa hướng tản nhiệt kim loại nguyên khối
Góc nâng: Chân đế lật nâng 2 cấp độ cao công thái học
Cổng kết nối: 2x Cổng USB 2.0 (1 cổng cấp nguồn, 1 cổng cắm chuột/bàn phím)
Tương thích kích thước: Dành cho laptop từ 15.6 inch đến 17 inch
Kích thước: 380 x 280 x 28 mm
Trọng lượng: Khoảng 680g');

-- SP 71: Loa máy tính để bàn Edifier R1280DB Bluetooth Studio
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (71, N'Loa máy tính để bàn Edifier R1280DB Bluetooth Studio', N'Edifier R1280DB là biểu tượng loa để bàn kiểm âm phòng thu mini chuẩn mực và bán chạy hàng đầu thế giới của Edifier, sở hữu thùng loa bằng gỗ MDF cổ điển sang trọng và chất âm tự nhiên mộc mạc.

Thùng loa chế tác từ gỗ MDF cao cấp dày dặn giúp triệt tiêu tối đa hiện tượng cộng hưởng âm khó chịu, mang lại dải âm trầm (Bass) ấm áp, sâu lắng cùng âm cao (Treble) trong trẻo, mượt mà chuẩn audiophile.

Trang bị củ loa trầm đường kính 4 inch cùng củ loa dải cao vòm lụa 13mm (silk dome tweeter), tổng công suất thực 42W RMS lấp đầy âm nhạc sống động trong căn phòng diện tích 20 - 30m2.

Hỗ trợ đa dạng kết nối hiện đại: Bluetooth không dây, cổng quang học Optical, cổng đồng trục Coaxial và 2 cổng RCA mạ vàng, đi kèm điều khiển từ xa không dây nhỏ gọn tiện lợi.', 2490000, 15, N'images/products/loa/sp71-edifier-r1280db/main.jpg', 8, GETDATE(), 1, N'Hãng sản xuất: EDIFIER
Model: R1280DB Bluetooth Studio Bookshelf Speakers
Hệ thống loa: Loa vi tính 2.0 Stereo chất lượng cao
Tổng công suất (RMS): 42W (21W + 21W)
Củ loa trầm (Bass Unit): 4 inch (116mm) nam châm kép
Củ loa cao (Tweeter Unit): 13mm màng lụa Silk Dome Tweeter
Dải tần số đáp ứng: 55Hz - 20kHz / Tỷ lệ tín hiệu trên nhiễu (SNR): >= 85dBA
Kết nối đầu vào: Bluetooth, Cổng Optical quang học, Coaxial, 2x Cặp cổng RCA (Line In)
Điều khiển: Cụm núm vặn chỉnh Bass, Treble, Volume bên hông thùng loa + Remote điều khiển từ xa
Chất liệu thùng loa: Gỗ MDF cao cấp dán vân gỗ sang trọng
Kích thước: 146 x 234 x 196 mm mỗi loa
Trọng lượng: Khoảng 4.9kg cả bộ');

-- SP 72: Loa vi tính 2.0 Logitech Z120 cổng nguồn USB jack 3.5mm
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (72, N'Loa vi tính 2.0 Logitech Z120 cổng nguồn USB jack 3.5mm', N'Logitech Z120 là bộ loa vi tính 2.0 stereo mini quốc dân nhỏ gọn và bền bỉ bậc nhất, giải pháp nâng cấp âm thanh tiện lợi cho góc làm việc văn phòng, phòng học hoặc máy tính laptop.

Sử dụng nguồn điện 5V trực tiếp qua cổng USB máy tính mà không cần cắm củ sạc rời vào ổ cắm tường, kết hợp dây cắm âm thanh 3.5mm tiêu chuẩn cắm là nhận ngay trên mọi PC, laptop hay điện thoại.

Thiết kế tông màu trắng tinh tế kết hợp viền đen hiện đại, mặt sau tích hợp khoang thu gọn và quấn dây cáp thừa thông minh giúp bàn làm việc của bạn luôn ngăn nắp không bị rối dây.

Núm vặn cơ học lớn tích hợp công tắc nguồn và điều chỉnh âm lượng ngay mặt trước loa phải, cho phép bạn bật tắt và tăng giảm âm lượng một cách dễ dàng và trực quan.', 299000, 45, N'images/products/loa/sp72-logitech-z120/main.png', 8, GETDATE(), 1, N'Hãng sản xuất: Logitech
Model: Z120 Stereo Speakers
Hệ thống âm thanh: 2.0 Stereo mini
Tổng công suất tối đa (Peak): 2.4W / Công suất thực (RMS): 1.2W
Cấp nguồn: Cổng USB 5V (cắm từ laptop, thùng PC hoặc củ sạc)
Đầu vào âm thanh: Jack cắm 3.5mm analog tiêu chuẩn
Điều khiển: Núm xoay tích hợp công tắc nguồn và chỉnh âm lượng trên loa phải
Quản lý cáp: Rãnh cuộn thu dây cáp thông minh phía sau loa
Kích thước: 110 x 90 x 88 mm mỗi loa (siêu nhỏ gọn)
Trọng lượng: Khoảng 250g
Tương thích: Tất cả thiết bị có cổng ra âm thanh 3.5mm và cổng USB cấp nguồn');

-- SP 73: Loa vi tính 2.1 Logitech Z313 kèm Subwoofer công suất 50W
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (73, N'Loa vi tính 2.1 Logitech Z313 kèm Subwoofer công suất 50W', N'Logitech Z313 là hệ thống loa vi tính 2.1 mạnh mẽ đi kèm loa siêu trầm Subwoofer chuyên biệt, mang lại trải nghiệm âm thanh rạp hát sống động và âm trầm rung chuyển căn phòng cho nhu cầu xem phim, nghe nhạc và chơi game.

Cung cấp công suất cực đại 50W (công suất thực 25W RMS), loa siêu trầm subwoofer đánh sàn (down-firing) tái tạo những tiếng nổ uy lực trong game hành động và những nhịp đập bass đầy nội lực trong các bản nhạc EDM.

Trang bị cụm điều khiển có dây (Control Pod) tròn trịa đặt ngay trên bàn làm việc, tích hợp công tắc nguồn, núm vặn âm lượng và cổng cắm tai nghe 3.5mm tiện lợi để bạn chuyển đổi nghe riêng tư trong đêm.

Hai loa vệ tinh nhỏ gọn với chân đế vát chéo hướng âm thanh thẳng tới tai người nghe, tạo ra không gian âm trường stereo tách bạch và chi tiết.', 890000, 22, N'images/products/loa/sp73-logitech-z313/main.jpg', 8, GETDATE(), 1, N'Hãng sản xuất: Logitech
Model: Z313 Speaker System with Subwoofer
Hệ thống âm thanh: 2.1 (2 loa vệ tinh + 1 loa siêu trầm Subwoofer)
Tổng công suất cực đại (Peak): 50 Watts / Công suất thực (RMS): 25 Watts
Công suất loa vệ tinh: 2 x 5 Watts / Công suất loa siêu trầm: 15 Watts
Dải tần số đáp ứng: 48Hz – 20kHz
Loa Subwoofer: Loa trầm củ loa hướng sàn (Down-firing Subwoofer) kích thước 4 inch
Cụm điều khiển: Control Pod để bàn tích hợp núm volume, công tắc nguồn và jack cắm tai nghe 3.5mm
Kết nối: Jack cắm 3.5mm kết nối với máy tính PC, laptop, TV, điện thoại
Kích thước loa vệ tinh: 146 x 89 x 81 mm mỗi loa
Kích thước loa Subwoofer: 228 x 150 x 220 mm
Trọng lượng: Khoảng 3.2kg cả bộ');

-- SP 74: Loa soundbar máy tính gaming Edifier Hecate G1500 Bar RGB
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (74, N'Loa soundbar máy tính gaming Edifier Hecate G1500 Bar RGB', N'Edifier Hecate G1500 Bar là thanh loa soundbar gaming chuyên dụng đặt dưới màn hình máy tính với thiết kế góc cạnh viễn tưởng Cyberpunk cùng hệ thống đèn LED RGB đa hiệu ứng cực chất.

Trang bị cấu trúc âm thanh kép với 2 củ loa toàn dải và 2 màng cộng hưởng thụ động (passive radiators), mang lại âm thanh vòm 7.1 ảo định vị âm thanh bước chân và tiếng súng trong game chuẩn xác đến từng góc phòng.

Tích hợp 3 chế độ âm thanh chuyên nghiệp chuyển đổi nhanh: Chế độ Game (tăng cường định vị), Chế độ Movie (mở rộng âm trường điện ảnh) và Chế độ Music (cân bằng âm sắc mượt mà).

Đặc biệt tích hợp micro thu âm đàm thoại đa hướng kèm thuật toán khử ồn thông minh, cho phép bạn voice chat trực tiếp cùng đồng đội mà không cần phải đeo tai nghe cồng kềnh.', 990000, 20, N'images/products/loa/sp74-edifier-g1500-bar/main.jpg', 8, GETDATE(), 1, N'Hãng sản xuất: EDIFIER (Dòng Gaming HECATE)
Model: Hecate G1500 Bar
Kiểu loa: Soundbar Gaming để bàn (Desktop Soundbar)
Cấu hình củ loa: 2 củ loa toàn dải + 2 màng rung thụ động Passive Radiators kép
Công suất: 8W Peak (4W + 4W RMS)
Dải tần số: 120Hz – 20kHz / Độ ồn: <= 20 dBA
Đèn LED: RGB 13 chế độ hiệu ứng ánh sáng động rực rỡ
Hiệu ứng âm thanh: Giả lập 7.1 Surround Sound với 3 chế độ (Game / Movie / Music)
Microphone: Tích hợp micro thu âm đa hướng lọc tiếng vang đàm thoại
Kết nối: Bluetooth 5.3 hiện đại, USB Audio cắm máy tính và AUX 3.5mm
Kích thước: 378 x 65 x 68 mm (vừa vặn dưới đáy màn hình máy tính)
Trọng lượng: Khoảng 760g');

-- SP 75: Loa để bàn Edifier R1700BT Bluetooth công suất 66W RMS
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (75, N'Loa để bàn Edifier R1700BT Bluetooth công suất 66W RMS', N'Edifier R1700BT là mẫu loa để bàn công suất khủng 66W RMS với thiết kế vát nghiêng 10 độ công thái học cùng ốp gỗ óc chó (Walnut) sang trọng, mang lại chất âm đẳng cấp Hi-Fi trung thực và giàu nhạc tính.

Góc nghiêng 10 độ hướng thẳng củ loa lên tầm tai người nghe, triệt tiêu phản xạ âm dội từ mặt bàn và tạo nên sân khấu âm thanh nổi rộng mở, tách bạch từng lớp nhạc cụ và giọng ca sĩ.

Trang bị củ loa trầm 4 inch màng composite cho âm bass chắc nịch, sâu lắng kết hợp củ loa treble vòm lụa ''Eagle Eye'' 19mm tái tạo dải cao tinh tế, bay bổng mà không hề bị chói gắt.

Tích hợp công nghệ xử lý tín hiệu số DSP (Digital Signal Processing) và kiểm soát dải động DRC (Dynamic Range Control), giảm thiểu tối đa hiện tượng méo tiếng ngay cả khi mở ở mức âm lượng cao nhất.', 2990000, 12, N'images/products/loa/sp75-edifier-r1700bt/main.jpg', 8, GETDATE(), 1, N'Hãng sản xuất: EDIFIER
Model: R1700BT Bluetooth Bookshelf Speaker
Hệ thống âm thanh: 2.0 Hi-Fi Active Bookshelf Speakers
Tổng công suất (RMS): 66 Watts (15W x 2 dải cao + 18W x 2 dải trầm)
Củ loa trầm: 4 inch (116mm) Bass Driver màng sợi composite
Củ loa cao: 19mm ''Eagle Eye'' Silk Dome Tweeter màng lụa cao cấp
Công nghệ xử lý: DSP (Digital Signal Processing) & DRC (Dynamic Range Control)
Dải tần số: 60Hz - 20kHz / SNR: >= 85dBA / Độ méo tiếng: <= 0.5%
Kết nối: Bluetooth không dây và 2 cổng RCA mạ vàng (Line In 1, Line In 2)
Thiết kế thùng loa: Vát nghiêng 10 độ bọc gỗ óc chó Walnut tự nhiên
Điều khiển: Núm xoay vô cực bên hông chỉnh Volume, Bass, Treble + Remote từ xa
Kích thước: 154 x 254 x 214 mm mỗi loa
Trọng lượng: Khoảng 6.6kg cả bộ');

-- SP 76: Loa bluetooth để bàn Creative Pebble V3 USB-C Bluetooth 5.0
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (76, N'Loa bluetooth để bàn Creative Pebble V3 USB-C Bluetooth 5.0', N'Creative Pebble V3 là phiên bản nâng cấp hoàn hảo nhất của dòng loa máy tính hình viên sỏi cuội tròn xinh xắn nổi tiếng thế giới của tập đoàn âm thanh Creative Technology (Singapore).

Nâng cấp củ loa lên kích thước 2.25 inch với công suất khuếch đại cực đại lên đến 16W Peak, kết hợp màng cộng hưởng thụ động ở mặt sau mang lại âm bass chắc khỏe và âm lượng to hơn 50% so với thế hệ trước.

Góc nâng 45 độ đặc trưng đưa âm thanh trực diện vào tai người nghe, tạo ra điểm ngọt âm thanh (sweet spot) hoàn hảo cho người ngồi làm việc trước máy tính.

Đặc biệt hỗ trợ truyền dẫn cả nguồn điện lẫn âm thanh kỹ thuật số USB Audio chất lượng cao chỉ qua một sợi cáp USB-C duy nhất, đồng thời tích hợp thêm Bluetooth 5.0 không dây kết nối điện thoại tiện lợi.', 990000, 25, N'images/products/loa/sp76-creative-pebble-v3/main.png', 8, GETDATE(), 1, N'Hãng sản xuất: Creative Technology (Singapore)
Model: Pebble V3 (Artisan Edition)
Hệ thống loa: 2.0 USB-C Desktop Speakers
Củ loa: Củ loa toàn dải 2.25 inch vát góc 45 độ hướng tai
Công suất khuếch đại: 8W RMS (Công suất cực đại lên tới 16W Peak khi cắm cổng PD 10W)
Công nghệ âm thanh: Clear Dialog tăng độ rõ nét giọng nói hội thoại và lời bài hát
Màng bass thụ động: Passive Radiator mặt sau tăng cường độ sâu âm trầm
Kết nối: USB-C Audio (vừa cấp nguồn vừa truyền âm thanh số), Bluetooth 5.0, AUX 3.5mm
Điều khiển: Núm vặn chỉnh âm lượng tích hợp đèn LED mặt trước
Kích thước: 123 x 120 x 118 mm mỗi loa hình viên sỏi
Trọng lượng: Khoảng 730g cả cặp
Phụ kiện đi kèm: Đầu chuyển đổi USB-C sang USB-A chính hãng');

-- SP 77: Loa vi tính 2.1 Microlab M-108 công suất 11W RMS
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (77, N'Loa vi tính 2.1 Microlab M-108 công suất 11W RMS', N'Microlab M-108 là dòng loa vi tính 2.1 giá bình dân huyền thoại gắn liền với nhiều thế hệ người dùng máy tính tại Việt Nam, sở hữu độ bền bỉ vượt trội và chất âm hài hòa trong tầm giá.

Bao gồm 1 thùng loa siêu trầm Subwoofer bằng gỗ MDF và 2 loa vệ tinh nhỏ gọn, tổng công suất thực 11W RMS đủ sức khuấy động không gian phòng học, phòng trọ sinh viên hay góc làm việc cá nhân.

Thùng loa trầm sử dụng ống thông hơi bass phản xạ (Bass Reflex) phía trước, tạo ra những âm trầm sâu lắng và chắc nịch hơn hẳn các dòng loa 2.0 mini thông thường.

Núm vặn chỉnh âm lượng lớn mạ viền sáng bóng ở mặt trước loa sub giúp thao tác tăng giảm âm lượng nhanh chóng, cổng cắm jack 3.5mm tương thích mọi PC, laptop và smartphone.', 420000, 35, N'images/products/loa/sp77-microlab-m108/main.jpg', 8, GETDATE(), 1, N'Hãng sản xuất: Microlab
Model: M-108
Hệ thống âm thanh: 2.1 kênh (1 Subwoofer + 2 loa vệ tinh)
Tổng công suất thực (RMS): 11 Watts (Loa Sub 6W + 2 loa vệ tinh 2.5W x 2)
Dải tần số đáp ứng: 50Hz – 20kHz / Tỷ số nén nhiễu (SNR): > 70dB
Củ loa Subwoofer: 4 inch thùng gỗ MDF triệt tiêu rung chấn
Củ loa vệ tinh: 3 inch màng loa cân bằng âm dải trung và cao
Núm điều khiển: Núm vặn Master Volume lớn mặt trước + Núm chỉnh Bass mặt sau
Cổng kết nối: Cổng âm thanh đầu vào Jack 3.5mm analog
Nguồn điện: Điện lưới trực tiếp 220V - 50Hz ổn định
Kích thước loa Sub: 149 x 210 x 190 mm
Kích thước loa vệ tinh: 96 x 136 x 94 mm mỗi loa
Trọng lượng: Khoảng 2.5kg cả bộ');

-- SP 78: Loa soundbar máy tính Dell Slim Soundbar SB521A gắn màn hình
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (78, N'Loa soundbar máy tính Dell Slim Soundbar SB521A gắn màn hình', N'Dell Slim Soundbar SB521A là chiếc loa soundbar siêu mỏng nhẹ thanh lịch nhất thế giới được thiết kế chuyên biệt để gắn hít nam châm từ tính trực tiếp vào mép dưới của các dòng màn hình Dell UltraSharp và Dell P-Series.

Với cơ chế gắn từ tính nam châm thông minh, chiếc loa soundbar này không hề chiếm một centimet vuông diện tích nào trên bàn làm việc, biến góc setup của bạn thành một không gian làm việc tối giản Clean Desk hoàn mỹ.

Cung cấp công suất 3.6W RMS với củ loa kép dải tần rộng từ 180Hz đến 20kHz, mang lại chất âm đàm thoại trong trẻo, rõ nét cho các cuộc họp Microsoft Teams, Zoom hội nghị và nghe nhạc nhẹ nhàng.

Kết nối và cấp nguồn tiện lợi chỉ bằng một đầu cắm cáp USB duy nhất cắm thẳng vào cổng USB phía sau màn hình Dell, đi kèm núm xoay âm lượng cơ học có đèn LED trắng báo trạng thái.', 790000, 18, N'images/products/loa/sp78-dell-sb521a/main.jpg', 8, GETDATE(), 1, N'Hãng sản xuất: DELL Technologies
Model: Slim Soundbar - SB521A
Kiểu loa: Soundbar siêu mỏng gắn màn hình máy tính
Cơ chế gắn: Hít nam châm từ tính (Magnetic snap-on) trực tiếp vào viền đáy màn hình Dell
Công suất: 3.6 Watts RMS
Dải tần số đáp ứng: 180Hz – 20.000Hz
Kết nối: Dây cáp USB-A (vừa truyền tín hiệu âm thanh kỹ thuật số vừa cấp nguồn)
Điều khiển: Núm xoay điều chỉnh âm lượng cơ học bên hông kèm đèn LED chỉ báo
Độ dày loa: Siêu mỏng thanh mảnh hòa quyện hoàn hảo vào cạnh màn hình
Kích thước: 298 x 18 x 24 mm
Trọng lượng: Chỉ 114g
Tương thích: Màn hình Dell UltraSharp và Dell dòng P hỗ trợ ngàm nam châm (U2421E, U2722D, P2422H, P2723D...)');

-- SP 79: Loa gaming để bàn Razer Nommo V2 X âm thanh vòm THX Spatial
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (79, N'Loa gaming để bàn Razer Nommo V2 X âm thanh vòm THX Spatial', N'Razer Nommo V2 X là bộ đôi loa vi tính 2.0 gaming cao cấp hình trụ tròn độc đáo của Razer, được cân chỉnh để tái hiện không gian âm trường điện ảnh 3D và định vị âm thanh eSports vượt trội.

Trang bị hai củ loa toàn dải kích thước lớn 3.2 inch (83mm) màng nhôm anodized cùng ống thoát âm bass phía sau (rear-facing bass ports), tái tạo âm trầm sâu uy lực lên tới 96dB mà không cần thêm cục subwoofer rời cồng kềnh.

Tích hợp công nghệ âm thanh không gian THX Spatial Audio định vị chuẩn xác hướng phát ra âm thanh của tiếng súng, tiếng bước chân kẻ địch trong không gian 360 độ ảo.

Hỗ trợ kết nối âm thanh kỹ thuật số qua cổng USB máy tính PC, PlayStation 4/5 và kết nối không dây Bluetooth 5.0 độ trễ thấp với máy tính bảng, điện thoại di động.', 3490000, 10, N'images/products/loa/sp79-razer-nommo-v2x/main.png', 8, GETDATE(), 1, N'Hãng sản xuất: Razer
Model: Nommo V2 X Full-Range 2.0 PC Gaming Speakers
Hệ thống âm thanh: Loa vi tính 2.0 hình trụ tròn khí động học
Củ loa: 2x Củ loa toàn dải lớn 3.2 inch (83mm) màng nhôm
Dải tần số: 75Hz – 20.000Hz / Áp suất âm thanh tối đa: 96dB tại 1m
Công nghệ âm thanh: THX Spatial Audio 7.1 chuẩn phòng chiếu phim
Ống thông hơi: Ống thoát âm bass phản xạ phía sau tăng cường độ rền âm trầm
Kết nối: USB Type-C sang USB-A Audio và Bluetooth 5.0
Điều khiển: Cụm phím bấm nguồn, chuyển ngõ vào và âm lượng trên đỉnh loa phải
Kích thước: 130 x 184 x 180 mm mỗi loa
Trọng lượng: Khoảng 2.4kg cả cặp
Phần mềm hỗ trợ: Razer Synapse tùy biến EQ âm thanh');

-- SP 80: Loa bluetooth di động JBL GO 3 kháng nước kháng bụi IP67
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (80, N'Loa bluetooth di động JBL GO 3 kháng nước kháng bụi IP67', N'JBL GO 3 là chiếc loa Bluetooth di động mini cá tính được giới trẻ và dân văn phòng cực kỳ yêu thích nhờ chất âm JBL Pro Sound đầy nội lực trong một thân hình nhỏ nhắn trong lòng bàn tay.

Đạt chuẩn kháng nước và kháng bụi chuẩn quân đội IP67 cao cấp nhất, cho phép bạn thoải mái mang loa đi bơi, đi dã ngoại hay rửa trực tiếp dưới vòi nước mà loa vẫn phát nhạc vô tư.

Vỏ ngoài bọc lớp vải dệt sợi thể thao cao cấp chống rách kết hợp quai xỏ ngón tay tiện lợi, dễ dàng móc vào balo, quai xe đạp hay ngón tay khi di chuyển dạo phố.

Thời lượng pin bền bỉ lên đến 5 giờ phát nhạc liên tục, sạc nhanh qua cổng USB Type-C hiện đại không nắp đậy chống nước thông minh.', 890000, 40, N'images/products/loa/sp80-jbl-go-3/main.jpg', 8, GETDATE(), 1, N'Hãng sản xuất: JBL (Harman International)
Model: GO 3 Portable Waterproof Speaker
Công nghệ âm thanh: JBL Pro Sound âm bass sâu vượt trội kích thước
Công suất phát: 4.2 Watts RMS
Củ loa: 43 x 47 mm / Dải tần số: 110Hz – 20kHz
Chuẩn chống nước chống bụi: IP67 (ngâm nước sâu 1m trong 30 phút vẫn an toàn)
Kết nối: Bluetooth 5.1 kết nối xa và ổn định
Thời lượng pin: Lên đến 5 giờ nghe nhạc liên tục
Thời gian sạc: Khoảng 2.5 giờ qua cổng USB Type-C
Chất liệu: Vải dệt thể thao chống mài mòn + Cao su đúc chống sốc
Kích thước: 87.5 x 75 x 41.3 mm (nhỏ gọn trong lòng bàn tay)
Trọng lượng: Siêu nhẹ 209g');

-- SP 81: Ổ cứng SSD di động Kingston XS1000 1TB USB 3.2 Gen 2
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (81, N'Ổ cứng SSD di động Kingston XS1000 1TB USB 3.2 Gen 2', N'Kingston XS1000 1TB là mẫu ổ cứng thể rắn SSD di động siêu nhỏ gọn bỏ túi chỉ nặng chưa đầy 29g, giải pháp sao lưu dữ liệu tốc độ cao đáng tin cậy cho dân đồ họa, dựng phim và người dùng văn phòng.

Sử dụng giao thức USB 3.2 Gen 2 cho tốc độ đọc lên tới 1.050 MB/s và tốc độ ghi lên tới 1.000 MB/s, cho phép sao chép các tệp video 4K dung lượng hàng chục GB chỉ trong vài giây, nhanh gấp 10 lần các ổ cứng HDD di động truyền thống.

Vỏ ngoài hoàn thiện từ sự kết hợp giữa kim loại và nhựa cao cấp màu đen lì sang trọng, chịu va đập tốt và kích thước chỉ bằng một nửa chiếc thẻ ngân hàng, dễ dàng bỏ vào túi áo sơ mi hay ngăn ví.

Dung lượng lưu trữ 1TB rộng rãi cho phép bạn cất giữ hàng trăm nghìn bức ảnh độ phân giải cao, thư viện tài liệu công việc và các tựa game yêu thích mà không lo hết bộ nhớ.', 1990000, 25, N'images/products/thiet-bi-luu-tru/sp81-kingston-xs1000/main.jpg', 9, GETDATE(), 1, N'Hãng sản xuất: Kingston Technology
Model: XS1000 External SSD (SXS1000/1000G)
Dung lượng: 1TB (1000GB)
Giao tiếp kết nối: USB 3.2 Gen 2 Type-C
Tốc độ đọc tuần tự: Lên tới 1.050 MB/s
Tốc độ ghi tuần tự: Lên tới 1.000 MB/s
Chất liệu vỏ: Kim loại nhôm + nhựa ABS bền bỉ
Phụ kiện đi kèm: Cáp USB-C sang USB-A kèm đầu chuyển Type-C
Kích thước siêu nhỏ: 69.54 x 32.58 x 13.5 mm
Trọng lượng: Siêu nhẹ chỉ 28.7g
Tương thích: Windows 11/10, macOS 10.15+, Linux, Chrome OS, Android, iPadOS');

-- SP 82: Ổ cứng SSD di động Samsung T7 Shield 1TB chống sốc IP65
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (82, N'Ổ cứng SSD di động Samsung T7 Shield 1TB chống sốc IP65', N'Samsung T7 Shield 1TB là dòng ổ cứng SSD di động ''nồi đồng cối đá'' bền bỉ nhất của Samsung, được bọc lớp vỏ cao su đàn hồi cao cấp đạt chuẩn chống nước bụi IP65 và khả năng chống rơi vỡ từ độ cao tới 3 mét.

Trang bị công nghệ bộ nhớ flash Samsung V-NAND kết hợp chuẩn USB 3.2 Gen 2, đạt tốc độ đọc/ghi lần lượt lên tới 1.050 MB/s và 1.000 MB/s, hỗ trợ chỉnh sửa và dựng video 4K/8K trực tiếp mượt mà ngay trên ổ cứng.

Công nghệ bảo vệ nhiệt độ Dynamic Thermal Guard tiên tiến tự động kiểm soát nhiệt độ bo mạch, giữ cho tốc độ truyền tải file khổng lồ luôn ổn định mà không bao giờ bị giảm tốc độ do quá nóng.

Tích hợp mã hóa phần cứng AES 256-bit chuẩn quân sự với phần mềm Samsung Magician, cho phép đặt mật khẩu bảo vệ dữ liệu tuyệt mật khỏi nguy cơ xâm nhập trái phép.', 2790000, 20, N'images/products/thiet-bi-luu-tru/sp82-samsung-t7-shield/main.jpg', 9, GETDATE(), 1, N'Hãng sản xuất: SAMSUNG
Model: T7 Shield Portable SSD (MU-PE1T0S)
Dung lượng: 1TB
Chuẩn giao tiếp: USB 3.2 Gen 2 (10Gbps)
Tốc độ đọc: Lên đến 1.050 MB/s / Tốc độ ghi: Lên đến 1.000 MB/s
Độ bền & Bảo vệ: Chuẩn kháng nước kháng bụi IP65, chống rơi vỡ từ độ cao 3 mét
Kiểm soát nhiệt: Công nghệ Dynamic Thermal Guard chống hạ tốc độ
Bảo mật: Mã hóa phần cứng AES 256-bit cài mật khẩu an toàn
Chất liệu vỏ: Cao su Elastomer chống sốc + Khung nhôm tản nhiệt
Kèm theo: Cáp Type-C sang Type-C và Cáp Type-C sang Type-A
Kích thước: 88 x 59 x 13 mm
Trọng lượng: 98g');

-- SP 83: Ổ cứng di động HDD WD Elements 1TB 2.5 inch USB 3.0
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (83, N'Ổ cứng di động HDD WD Elements 1TB 2.5 inch USB 3.0', N'Western Digital Elements 1TB là mẫu ổ cứng di động HDD 2.5 inch bán chạy nhất mọi thời đại của thương hiệu lưu trữ số 1 thế giới Western Digital (WD), sự lựa chọn kinh tế hàng đầu để sao lưu dữ liệu dung lượng lớn dài hạn.

Sở hữu dung lượng lưu trữ 1000GB khổng lồ trong một thiết kế hình khối đen mờ nhỏ gọn, cung cấp không gian bao la để lưu trữ trọn đời album ảnh gia đình, video kỷ niệm, phim chất lượng cao và bộ cài đặt phần mềm.

Kết nối chuẩn USB 3.0 tốc độ cao cho phép truyền dữ liệu nhanh chóng lên đến 130MB/s, tương thích ngược hoàn toàn với cổng USB 2.0 trên các máy tính đời cũ.

Cơ chế cắm là chạy (Plug and Play) được định dạng sẵn chuẩn NTFS cho Windows, đi kèm lớp vỏ chống sốc bền bỉ được chứng nhận nghiêm ngặt về khả năng chống rung lắc khi di chuyển.', 1390000, 30, N'images/products/thiet-bi-luu-tru/sp83-wd-elements-1tb/main.jpg', 9, GETDATE(), 1, N'Hãng sản xuất: Western Digital (WD)
Model: WD Elements Portable 1TB (WDBUZG0010BBK)
Loại ổ cứng: Ổ đĩa cứng di động HDD 2.5 inch
Dung lượng: 1TB (1.000GB)
Chuẩn giao tiếp: USB 3.0 Micro-B tốc độ truyền tải tối đa 5Gbps
Tốc độ truyền thực tế: Lên đến 130 MB/s
Định dạng sẵn: NTFS cho Windows 11/10/8.1/7 (có thể format lại cho macOS)
Cấp nguồn: Cấp nguồn trực tiếp qua cáp USB không cần nguồn điện ngoài
Chất liệu vỏ: Nhựa Polycarbonate chống trầy xước, chịu lực va đập tốt
Kích thước: 110.5 x 82 x 15 mm
Trọng lượng: Khoảng 134g
Bảo hành: 24 tháng chính hãng');

-- SP 84: USB 3.2 Kingston DataTraveler Exodia M 64GB nắp trượt
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (84, N'USB 3.2 Kingston DataTraveler Exodia M 64GB nắp trượt', N'Kingston DataTraveler Exodia M 64GB là chiếc USB flash drive thời trang tiện ích hàng đầu của Kingston với thiết kế nắp trượt chuyển động thông minh, loại bỏ hoàn toàn nỗi lo làm rơi mất nắp đậy USB.

Trang bị chuẩn giao tiếp USB 3.2 Gen 1 SuperSpeed giúp việc sao chép tài liệu học tập, slide thuyết trình, bài hát và tệp tin công việc diễn ra nhanh chóng, mượt mà trên mọi máy tính và thiết bị văn phòng.

Vỏ ngoài thiết kế nhiều màu sắc trẻ trung với cơ chế trượt ngón tay mượt mà bảo vệ chân cắm USB khỏi bụi bẩn và va đập khi bỏ trong hộp bút hay balo.

Đuôi USB khoét vòng khuyên lớn tiện lợi giúp bạn dễ dàng móc vào móc khóa xe máy hay dây đeo cổ, mang theo dữ liệu cần thiết bên mình mọi lúc mọi nơi.', 120000, 80, N'images/products/thiet-bi-luu-tru/sp84-kingston-exodia-m/main.jpg', 9, GETDATE(), 1, N'Hãng sản xuất: Kingston Technology
Model: DataTraveler Exodia M (DTXM/64GB)
Dung lượng: 64GB
Chuẩn giao tiếp: USB 3.2 Gen 1 tốc độ cao (tương thích USB 3.0 và USB 2.0)
Thiết kế nắp: Nắp trượt cơ học chuyển động bảo vệ chân cắm (Moving cap design)
Tiện ích: Vòng khuyên lớn ở đuôi móc khóa chống thất lạc
Nhiệt độ hoạt động: 0°C đến 60°C
Kích thước: 67.4 x 21.8 x 11.6 mm
Trọng lượng: Siêu nhẹ chỉ 10g
Tương thích: Windows 11/10/8, macOS 10.15+, Chrome OS, Linux');

-- SP 85: USB 3.1 SanDisk Ultra Flair CZ73 64GB vỏ kim loại
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (85, N'USB 3.1 SanDisk Ultra Flair CZ73 64GB vỏ kim loại', N'SanDisk Ultra Flair CZ73 64GB là dòng USB kim loại sang trọng và bền bỉ hàng đầu của SanDisk, kết hợp vẻ đẹp bóng bẩy hiện đại với tốc độ truyền tải dữ liệu chuẩn USB 3.0 lên tới 150MB/s.

Tốc độ đọc dữ liệu cực nhanh lên tới 150MB/s (nhanh gấp 15 lần chuẩn USB 2.0 tiêu chuẩn), cho phép chuyển trọn vẹn một bộ phim Full HD dài tập chỉ trong chưa đầy 30 giây.

Lớp vỏ bằng hợp kim nhôm phay xước cao cấp không chỉ mang lại độ bền cơ học ấn tượng chống va đập, rơi rớt mà còn giúp tản nhiệt nhanh chóng cho chip nhớ bên trong.

Đi kèm phần mềm bảo mật SanDisk SecureAccess độc quyền, cho phép bạn tạo thư mục riêng tư được bảo vệ bằng mật khẩu mã hóa AES 128-bit an toàn.', 150000, 70, N'images/products/thiet-bi-luu-tru/sp85-sandisk-cz73-flair/main.png', 9, GETDATE(), 1, N'Hãng sản xuất: SanDisk (Western Digital)
Model: Ultra Flair CZ73 (SDCZ73-064G-G46)
Dung lượng: 64GB
Chuẩn kết nối: USB 3.0 / USB 3.1 Gen 1
Tốc độ đọc dữ liệu: Lên đến 150 MB/s (nhanh gấp 15 lần USB 2.0)
Chất liệu vỏ: Kim loại nhôm nguyên khối phay xước bóng bẩy chịu va đập
Phần mềm bảo mật: SanDisk SecureAccess mã hóa mật khẩu 128-bit AES
Khôi phục dữ liệu: Hỗ trợ phần mềm khôi phục RescuePRO Deluxe
Kích thước: 42.42 x 13.21 x 6.6 mm (siêu thanh mảnh mỏng nhẹ)
Trọng lượng: Chỉ 4.5g
Tương thích: Windows, macOS, smart TV, loa nghe nhạc, đầu đĩa ô tô');

-- SP 86: Thẻ nhớ MicroSDXC SanDisk Extreme Pro 128GB 200MB/s A2 V30
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (86, N'Thẻ nhớ MicroSDXC SanDisk Extreme Pro 128GB 200MB/s A2 V30', N'SanDisk Extreme Pro MicroSDXC 128GB là dòng thẻ nhớ cao cấp nhất của SanDisk chuyên dụng cho Flycam DJI, máy quay hành trình GoPro, máy ảnh chuyên nghiệp và smartphone flagship quay phim 4K UHD.

Trang bị công nghệ SanDisk QuickFlow độc quyền mang lại tốc độ đọc siêu khủng lên tới 200MB/s và tốc độ ghi tới 90MB/s, đạt chuẩn Video Speed Class 30 (V30) và UHS Speed Class 3 (U3) cho phép quay video 4K UHD mượt mà không bao giờ bị rớt khung hình.

Đạt chuẩn hiệu năng ứng dụng A2 (Application Performance Class 2) với tốc độ xử lý ngẫu nhiên cực nhanh, giúp mở và tải các ứng dụng, game 3D nặng trên điện thoại Android và máy chơi game Nintendo Switch nhanh như chớp.

Khả năng chống chịu khắc nghiệt đạt chuẩn quân sự: chống sốc, chống nước, chống tia X sân bay và chịu được biên độ nhiệt độ từ -25 độ C đến 85 độ C.', 390000, 50, N'images/products/thiet-bi-luu-tru/sp86-sandisk-extreme-pro-128gb/main.jpg', 9, GETDATE(), 1, N'Hãng sản xuất: SanDisk (Western Digital)
Model: Extreme PRO MicroSDXC UHS-I Card (SDSQXCD-128G-GN6MA)
Dung lượng: 128GB
Chuẩn tốc độ: Class 10, UHS-I, U3, V30, A2
Tốc độ đọc tối đa: Lên đến 200 MB/s (công nghệ QuickFlow)
Tốc độ ghi tối đa: Lên đến 90 MB/s
Quay video chuyên nghiệp: Hỗ trợ 4K UHD và Full HD video recording chuẩn V30
Hiệu năng ứng dụng: Chuẩn A2 tối ưu hóa chạy ứng dụng và game trên mobile/Nintendo Switch
Độ bền cao cấp: Chống nước, chống tia X, chống nhiệt độ khắc nghiệt và chống sốc
Phụ kiện đi kèm: Adapter chuyển đổi sang thẻ nhớ SD tiêu chuẩn cho máy ảnh
Bảo hành: Lên đến 5 năm chính hãng');

-- SP 87: Thẻ nhớ MicroSD Kingston Canvas Select Plus 64GB Class 10
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (87, N'Thẻ nhớ MicroSD Kingston Canvas Select Plus 64GB Class 10', N'Kingston Canvas Select Plus 64GB là mẫu thẻ nhớ MicroSD quốc dân đáng tin cậy và bán chạy hàng đầu cho camera an ninh gia đình, camera hành trình ô tô và điện thoại thông minh Android.

Được tối ưu hóa cho thiết bị di động với chuẩn hiệu năng ứng dụng A1, thẻ nhớ cho phép người dùng mở ứng dụng nhanh chóng, chụp ảnh độ phân giải cao và quay video Full HD 1080p sắc nét mà không bị nghẽn bộ nhớ đệm.

Tốc độ đọc nhanh lên tới 100MB/s chuẩn Class 10 UHS-I giúp việc sao chép hình ảnh và video từ camera vào máy tính diễn ra chỉ trong vài phút ngắn ngủi.

Được kiểm nghiệm nghiêm ngặt về độ bền trong các điều kiện khắc nghiệt nhất: chống nước ngâm, chịu nhiệt độ từ -25°C đến 85°C, chống sốc và chống rung lắc, đảm bảo an toàn tuyệt đối cho các đoạn video giám sát quan trọng.', 110000, 65, N'images/products/thiet-bi-luu-tru/sp87-kingston-canvas-select-64gb/main.jpg', 9, GETDATE(), 1, N'Hãng sản xuất: Kingston Technology
Model: Canvas Select Plus MicroSDHC (SDCS2/64GB)
Dung lượng: 64GB
Chuẩn tốc độ: Class 10, UHS-I, U1, A1
Tốc độ đọc tuần tự: Lên tới 100 MB/s
Tốc độ ghi: Đạt chuẩn Class 10 tối thiểu 10MB/s quay video Full HD liên tục
Chuẩn A1: Tối ưu tải ứng dụng nhanh cho Android
Độ bền: Chống nước, chống va đập rung động, chống tia X và chịu nhiệt độ cao
Ứng dụng tối ưu: Camera an ninh giám sát 24/7 (Imou, Ezviz, TP-Link Tapo), điện thoại, camera hành trình
Phụ kiện: Tặng kèm Adapter chuyển đổi thẻ SD cho máy tính và laptop
Bảo hành: Trọn đời (Lifetime warranty) chính hãng');

-- SP 88: Hộp đựng ổ cứng Box SSD M.2 NVMe/SATA Orico PWM2 tốc độ 10Gbps
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (88, N'Hộp đựng ổ cứng Box SSD M.2 NVMe/SATA Orico PWM2 tốc độ 10Gbps', N'Box di động Orico PWM2 là hộp đựng biến ổ cứng SSD M.2 bên trong thành ổ cứng di động siêu tốc độ 10Gbps với thiết kế nắp gài không cần ốc vít thông minh và vỏ hợp kim nhôm tản nhiệt sọc viền độc đáo.

Trang bị chip điều khiển kép thông minh Realtek RTL9210B cao cấp, hỗ trợ đồng thời cả hai chuẩn ổ cứng M.2 NVMe (PCIe) và M.2 NGFF (SATA) với các kích thước thông dụng 2230, 2242, 2260 và 2280.

Băng thông truyền tải USB 3.2 Gen 2 lên tới 10Gbps, cho tốc độ truyền tải thực tế đạt tới 1.000 MB/s khi gắn ổ cứng M.2 NVMe, giúp bạn tận dụng lại các thanh SSD thừa sau khi nâng cấp laptop.

Thiết kế lắp đặt Tool-free hoàn toàn bằng tay không cần dùng tua-vít, đi kèm miếng đệm tản nhiệt silicon Thermal Pad và thanh nhôm tản nhiệt chuyên dụng giúp giải nhiệt cực mát cho thanh SSD.', 320000, 35, N'images/products/thiet-bi-luu-tru/sp88-orico-pwm2-nvme/main.jpg', 9, GETDATE(), 1, N'Hãng sản xuất: ORICO
Model: PWM2 (M.2 Dual Protocol Enclosure)
Giao thức hỗ trợ: Chuẩn kép (Hỗ trợ cả M.2 NVMe PCIe và M.2 SATA NGFF)
Kích thước SSD tương thích: Hỗ trợ kích thước 2230, 2242, 2260, 2280 dung lượng lên tới 4TB
Cổng đầu ra: USB 3.2 Gen 2 Type-C (10Gbps)
Tốc độ truyền tối đa: Lên đến 1.000 MB/s (1GB file chuyển trong 1 giây)
Cơ chế lắp ráp: Tool-Free (Lắp đặt bằng tay nắp trượt thông minh không cần tua-vít)
Tản nhiệt: Mặt ốp hợp kim nhôm sọc vân tản nhiệt + Miếng dán silicon dẫn nhiệt Thermal Pad
Tính năng: Tự động ngủ tiết kiệm điện sau 10 phút không hoạt động
Cáp đi kèm: Cáp 2-in-1 Type-C sang Type-C / Type-A dài 30cm
Kích thước: 124 x 35 x 14 mm
Trọng lượng: Khoảng 65g');

-- SP 89: Ổ cứng SSD di động SanDisk Extreme Portable SSD 1TB E61
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (89, N'Ổ cứng SSD di động SanDisk Extreme Portable SSD 1TB E61', N'SanDisk Extreme Portable SSD 1TB (V2 - E61) là chiếc ổ cứng SSD di động biểu tượng của giới nhiếp ảnh gia và nhà sáng tạo nội dung du lịch mạo hiểm trên toàn thế giới, sở hữu độ bền bỉ và tốc độ vượt trội.

Trang bị công nghệ NVMe thế hệ mới với tốc độ đọc tuần tự lên đến 1.050 MB/s và tốc độ ghi 1.000 MB/s, cho phép chỉnh sửa video 4K trực tiếp mượt mà ngay trên ổ đĩa từ phần mềm Adobe Premiere, Final Cut Pro hay DaVinci Resolve.

Thiết kế móc khuyên carabiner bằng cao su silicon màu cam đặc trưng ở góc trên, giúp bạn dễ dàng móc chặt ổ cứng vào quai đeo balo du lịch khi leo núi hay tác nghiệp ngoài trời.

Lớp vỏ bọc cao su silicon êm ái chống sốc đạt chuẩn kháng bụi nước IP65 và chịu được cú rơi từ độ cao 3 mét, bảo vệ an toàn tuyệt đối mọi cảnh quay và bức ảnh vô giá.', 2690000, 18, N'images/products/thiet-bi-luu-tru/sp89-sandisk-extreme-e61/main.jpg', 9, GETDATE(), 1, N'Hãng sản xuất: SanDisk (Western Digital)
Model: Extreme Portable SSD V2 (SDSSDE61-1T00-G25)
Dung lượng: 1TB (1.000GB)
Giao thức kết nối: USB 3.2 Gen 2 Type-C (tương thích Thunderbolt 3/4)
Tốc độ đọc: Lên tới 1.050 MB/s
Tốc độ ghi: Lên tới 1.000 MB/s
Độ bền chuẩn dã ngoại: Chuẩn kháng nước kháng bụi IP65, chống rơi từ độ cao 3 mét
Bảo mật: Mã hóa phần cứng 256-bit AES bằng mật khẩu qua SanDisk Security
Thiết kế: Khung bọc cao su silicon chống sốc kèm móc khuyên treo balo
Cáp đi kèm: Cáp USB-C sang USB-C và đầu chuyển USB-C sang USB-A
Kích thước: 100.5 x 52.4 x 8.95 mm
Trọng lượng: Siêu nhẹ chỉ 52g');

-- SP 90: USB Type-C 2 đầu SanDisk Ultra Dual Drive Go 128GB
INSERT INTO Products (ProductID, ProductName, Description, Price, Stock, ImageURL, CategoryID, CreatedDate, IsActive, Specifications)
VALUES (90, N'USB Type-C 2 đầu SanDisk Ultra Dual Drive Go 128GB', N'SanDisk Ultra Dual Drive Go 128GB là chiếc USB flash drive 2-trong-1 đa năng thông minh với 2 đầu cắm tích hợp: 1 đầu USB Type-C hiện đại và 1 đầu USB Type-A truyền thống, giải quyết triệt để vấn đề truyền file giữa máy tính và smartphone.

Cho phép bạn giải phóng bộ nhớ tức thì cho iPhone 15/16 series, điện thoại thông minh Android, máy tính bảng iPad và dễ dàng chuyển ảnh, video sang máy tính để bàn PC hoặc MacBook mà không cần dây cáp hay mạng Internet.

Thiết kế nắp xoay bảo vệ 360 độ (Swivel design) bằng kim loại thông minh, vừa bảo vệ an toàn cho cả hai đầu cắm vừa không bao giờ sợ bị thất lạc nắp đậy.

Đạt chuẩn tốc độ USB 3.2 Gen 1 với tốc độ đọc dữ liệu lên tới 400MB/s siêu nhanh, đi kèm ứng dụng SanDisk Memory Zone hỗ trợ tự động sao lưu ảnh và danh bạ điện thoại.', 290000, 45, N'images/products/thiet-bi-luu-tru/sp90-sandisk-dual-drive-go/main.jpg', 9, GETDATE(), 1, N'Hãng sản xuất: SanDisk (Western Digital)
Model: Ultra Dual Drive Go USB Type-C (SDDDC3-128G-G46)
Dung lượng: 128GB
Đầu cắm tích hợp: 2 đầu (1x USB Type-C + 1x USB 3.2 Gen 1 Type-A)
Tốc độ đọc dữ liệu: Siêu nhanh lên tới 400 MB/s
Thiết kế xoay: Nắp xoay kim loại 360 độ bảo vệ hai đầu cắm chống bụi xước
Tính năng OTG: Tự nhận diện trên smartphone, tablet, MacBook, PC
Ứng dụng hỗ trợ: SanDisk Memory Zone tự động sao lưu ảnh và danh bạ điện thoại
Lỗ xỏ móc khóa: Tích hợp móc khuyên đeo chìa khóa chống thất lạc
Kích thước: 44.41 x 12.1 x 8.6 mm
Trọng lượng: Chỉ 3.7g
Tương thích: iPhone 15/16 Series, smartphone Android Type-C, iPad Pro/Air, MacBook, Windows PC');

SET IDENTITY_INSERT Products OFF;
GO

-- 4. CHEN TOAN BO HINH ANH VAO BANG PRODUCTIMAGES (440+ ANH CHO 90 SAN PHAM)
DBCC CHECKIDENT ('ProductImages', RESEED, 0);
GO
INSERT INTO ProductImages (ProductID, ImageURL, Caption, DisplayOrder, IsMain) VALUES
(1, N'images/products/ban-phim/sp01-aula-f75/main.jpg', N'Góc chụp chính diện bàn phím cơ AULA F75', 1, 1),
(1, N'images/products/ban-phim/sp01-aula-f75/image-02.jpg', N'Góc nghiêng bàn phím và núm xoay kim loại', 2, 0),
(1, N'images/products/ban-phim/sp01-aula-f75/image-03.png', N'Cấu trúc Gasket Mount 5 lớp tiêu âm', 3, 0),
(1, N'images/products/ban-phim/sp01-aula-f75/image-04.png', N'Chi tiết switch LEOBOG và keycap PBT', 4, 0),
(1, N'images/products/ban-phim/sp01-aula-f75/image-05.png', N'Bàn phím trong không gian làm việc gaming', 5, 0),
(2, N'images/products/chuot/sp11-logitech-g102/main.jpg', N'Chuột gaming Logitech G102 Gen2 chính diện', 1, 1),
(2, N'images/products/chuot/sp11-logitech-g102/image-02.jpg', N'Góc nghiêng trên với dải LED RGB LIGHTSYNC', 2, 0),
(2, N'images/products/chuot/sp11-logitech-g102/image-03.png', N'Cạnh bên với 2 nút phụ tiện lợi', 3, 0),
(2, N'images/products/chuot/sp11-logitech-g102/image-04.jpg', N'Mặt đáy với cảm biến quang học 8000 DPI và feet chuột', 4, 0),
(2, N'images/products/chuot/sp11-logitech-g102/image-05.jpg', N'Chi tiết tổng thể chuột trong studio', 5, 0),
(3, N'images/products/tai-nghe/sp21-hyperx-stinger-2/main.png', N'Tai nghe HyperX Cloud Stinger 2 chụp chính diện', 1, 1),
(3, N'images/products/tai-nghe/sp21-hyperx-stinger-2/image-02.png', N'Chụp tai xoay 90 độ và microphone gạt tắt tiếng', 2, 0),
(3, N'images/products/tai-nghe/sp21-hyperx-stinger-2/image-03.png', N'Góc nhìn nghiêng hiển thị đệm đầu êm ái', 3, 0),
(3, N'images/products/tai-nghe/sp21-hyperx-stinger-2/image-04.jpg', N'Cận cảnh củ loa 50mm và đệm tai memory foam', 4, 0),
(3, N'images/products/tai-nghe/sp21-hyperx-stinger-2/image-05.png', N'Tai nghe với phụ kiện cáp chia âm thanh cho PC', 5, 0),
(4, N'images/products/hub-cap/sp41-ugreen-60515/main.jpg', N'Hub chuyển đổi Ugreen 60515 7-trong-1', 1, 1),
(4, N'images/products/hub-cap/sp41-ugreen-60515/image-02.jpg', N'Các cổng kết nối HDMI 4K, USB 3.0, khe thẻ nhớ', 2, 0),
(4, N'images/products/hub-cap/sp41-ugreen-60515/image-03.png', N'Cổng xuất hình ảnh HDMI 4K siêu nét', 3, 0),
(4, N'images/products/hub-cap/sp41-ugreen-60515/image-04.png', N'Cổng sạc USB-C PD công suất 100W', 4, 0),
(4, N'images/products/hub-cap/sp41-ugreen-60515/image-05.jpg', N'Vỏ nhôm tản nhiệt nguyên khối và đầu cắm bọc dù', 5, 0),
(5, N'images/products/ban-phim/sp02-akko-3087-steam-engine/main.png', N'Bàn phím cơ Akko 3087 v2 Steam Engine phối màu cổ điển', 1, 1),
(5, N'images/products/ban-phim/sp02-akko-3087-steam-engine/image-02.jpg', N'Góc chụp nghiêng cận cảnh cụm phím điều hướng và keycap PBT', 2, 0),
(5, N'images/products/ban-phim/sp02-akko-3087-steam-engine/image-03.jpg', N'Chi tiết phím và switch Akko v2 mượt mà', 3, 0),
(5, N'images/products/ban-phim/sp02-akko-3087-steam-engine/image-04.jpg', N'Mặt sau với chân đế nâng độ cao 2 nấc và rãnh đi dây 3 hướng', 4, 0),
(5, N'images/products/ban-phim/sp02-akko-3087-steam-engine/image-05.jpg', N'Trọn bộ sản phẩm và keycap tặng kèm phong cách Steam Engine', 5, 0),
(6, N'images/products/ban-phim/sp03-logitech-k380/main.png', N'Bàn phím không dây Logitech K380 chính diện', 1, 1),
(6, N'images/products/ban-phim/sp03-logitech-k380/image-02.png', N'Cận cảnh 3 nút Easy-Switch chuyển đổi thiết bị màu vàng', 2, 0),
(6, N'images/products/ban-phim/sp03-logitech-k380/image-03.png', N'Góc nghiêng siêu mỏng gọn nhẹ của bàn phím', 3, 0),
(6, N'images/products/ban-phim/sp03-logitech-k380/image-04.png', N'Bàn phím kết nối cùng lúc laptop, iPad và điện thoại', 4, 0),
(6, N'images/products/ban-phim/sp03-logitech-k380/image-05.png', N'Bố trí phím tròn công thái học êm ái khi gõ văn bản', 5, 0),
(7, N'images/products/ban-phim/sp04-keychron-k2-v2/main.jpg', N'Bàn phím cơ Keychron K2 V2 với layout 84 phím chuẩn Mac/Win', 1, 1),
(7, N'images/products/ban-phim/sp04-keychron-k2-v2/image-02.jpg', N'Góc nghiêng hiển thị hàng phím chức năng và đèn nền', 2, 0),
(7, N'images/products/ban-phim/sp04-keychron-k2-v2/image-03.jpg', N'Cạnh bên với nút gạt chuyển chế độ Mac/Win và Bluetooth/Type-C', 3, 0),
(7, N'images/products/ban-phim/sp04-keychron-k2-v2/image-04.jpg', N'Tính năng Hot-swap cho phép thay switch dễ dàng', 4, 0),
(7, N'images/products/ban-phim/sp04-keychron-k2-v2/image-05.png', N'Bộ phụ kiện cáp Type-C góc chữ L và keycap Mac/Windows đi kèm', 5, 0),
(8, N'images/products/ban-phim/sp05-razer-blackwidow-v4-x/main.png', N'Bàn phím cơ Razer BlackWidow V4 X với đèn Razer Chroma RGB', 1, 1),
(8, N'images/products/ban-phim/sp05-razer-blackwidow-v4-x/image-02.jpg', N'Cụm 6 phím Macro chuyên dụng cạnh trái cho game thủ', 2, 0),
(8, N'images/products/ban-phim/sp05-razer-blackwidow-v4-x/image-03.jpg', N'Con lăn chỉnh âm lượng kim loại và dãy phím media', 3, 0),
(8, N'images/products/ban-phim/sp05-razer-blackwidow-v4-x/image-04.jpg', N'Chi tiết switch Razer cơ học độ bền 100 triệu lượt bấm', 4, 0),
(8, N'images/products/ban-phim/sp05-razer-blackwidow-v4-x/image-05.jpg', N'Khung hợp kim nhôm 5052 cao cấp phay xước tinh tế', 5, 0),
(9, N'images/products/ban-phim/sp06-dareu-ek87/main.jpg', N'Bàn phím cơ DareU EK87 với dải LED Rainbow rực rỡ', 1, 1),
(9, N'images/products/ban-phim/sp06-dareu-ek87/image-02.jpg', N'Góc nghiêng bàn phím hiển thị font chữ keycap rõ nét xuyên LED', 2, 0),
(9, N'images/products/ban-phim/sp06-dareu-ek87/image-03.jpg', N'Chi tiết switch cơ học DareU D-Switch bền bỉ', 3, 0),
(9, N'images/products/ban-phim/sp06-dareu-ek87/image-04.jpg', N'Mặt đáy với đệm cao su chống trượt và nẹp nâng độ cao', 4, 0),
(9, N'images/products/ban-phim/sp06-dareu-ek87/image-05.jpg', N'Góc setup bàn phím cùng chuột gaming DareU', 5, 0),
(10, N'images/products/ban-phim/sp07-corsair-k70-rgb-pro/main.png', N'Bàn phím cơ Corsair K70 RGB PRO mặt nhôm phay xước đẳng cấp', 1, 1),
(10, N'images/products/ban-phim/sp07-corsair-k70-rgb-pro/image-02.png', N'Cụm con lăn chỉnh âm lượng kim loại và phím điều khiển media', 2, 0),
(10, N'images/products/ban-phim/sp07-corsair-k70-rgb-pro/image-03.png', N'Công tắc Tournament Switch chuyên dụng cho thi đấu eSports', 3, 0),
(10, N'images/products/ban-phim/sp07-corsair-k70-rgb-pro/image-04.jpg', N'Switch CHERRY MX chính hãng Đức và keycap PBT Pro 1.5mm', 4, 0),
(10, N'images/products/ban-phim/sp07-corsair-k70-rgb-pro/image-05.jpg', N'Bàn phím gắn kèm đệm kê tay nam châm công thái học', 5, 0);
GO
INSERT INTO ProductImages (ProductID, ImageURL, Caption, DisplayOrder, IsMain) VALUES
(11, N'images/products/ban-phim/sp08-logitech-wave-keys/main.png', N'Bàn phím công thái học Logitech Wave Keys thiết kế uốn lượn sóng', 1, 1),
(11, N'images/products/ban-phim/sp08-logitech-wave-keys/image-02.png', N'Cận cảnh đệm kê tay 3 lớp memory foam êm ái', 2, 0),
(11, N'images/products/ban-phim/sp08-logitech-wave-keys/image-03.png', N'Góc nghiêng mô tả độ cong công thái học chuẩn tự nhiên của bàn tay', 3, 0),
(11, N'images/products/ban-phim/sp08-logitech-wave-keys/image-04.png', N'Khả năng kết nối chuyển đổi 3 thiết bị Mac, Windows và iPad', 4, 0),
(11, N'images/products/ban-phim/sp08-logitech-wave-keys/image-05.png', N'Bàn phím đồng bộ tone-sur-tone cùng chuột công thái học Logitech Lift', 5, 0),
(12, N'images/products/ban-phim/sp09-rapoo-e9050g/main.jpg', N'Bàn phím không dây Rapoo E9050G khung nhôm siêu mỏng', 1, 1),
(12, N'images/products/ban-phim/sp09-rapoo-e9050g/image-02.jpg', N'Góc nghiêng cho thấy độ mỏng ấn tượng chỉ 5.6mm', 2, 0),
(12, N'images/products/ban-phim/sp09-rapoo-e9050g/image-03.jpg', N'Cận cảnh cấu trúc phím cắt kéo Scissor Switch êm ái', 3, 0),
(12, N'images/products/ban-phim/sp09-rapoo-e9050g/image-04.jpg', N'Cổng sạc USB Type-C hiện đại và nút nguồn cạnh bên', 4, 0),
(12, N'images/products/ban-phim/sp09-rapoo-e9050g/image-05.jpg', N'Bàn phím đặt cạnh laptop thể hiện sự gọn nhẹ tinh tế', 5, 0),
(13, N'images/products/ban-phim/sp10-monsgeek-m1w-v3-sp/main.jpg', N'Bàn phím cơ nhôm nguyên khối MonsGeek M1W V3 SP cao cấp', 1, 1),
(13, N'images/products/ban-phim/sp10-monsgeek-m1w-v3-sp/image-02.jpg', N'Góc nghiêng hiển thị keycap in ký tự cạnh bên Side-printed xuyên LED', 2, 0),
(13, N'images/products/ban-phim/sp10-monsgeek-m1w-v3-sp/image-03.jpg', N'Núm xoay kim loại CNC và dải LED viền hông sắc nét', 3, 0),
(13, N'images/products/ban-phim/sp10-monsgeek-m1w-v3-sp/image-04.jpg', N'Khung nhôm Anodized đầm chắc gần 2kg', 4, 0),
(13, N'images/products/ban-phim/sp10-monsgeek-m1w-v3-sp/image-05.png', N'Chi tiết mạch xuôi South-facing và switch Akko Piano Pro', 5, 0),
(14, N'images/products/chuot/sp12-logitech-pebble-m350s/main.png', N'Chuột không dây Logitech Pebble M350s thiết kế hình viên sỏi siêu mỏng', 1, 1),
(14, N'images/products/chuot/sp12-logitech-pebble-m350s/image-02.png', N'Góc nghiêng cho thấy độ dày mỏng nhẹ dễ dàng đút túi áo', 2, 0),
(14, N'images/products/chuot/sp12-logitech-pebble-m350s/image-03.png', N'Nắp chuột nam châm dễ dàng tháo lắp thay pin AA', 3, 0),
(14, N'images/products/chuot/sp12-logitech-pebble-m350s/image-04.png', N'Nút Easy-Switch dưới đáy chuyển đổi nhanh 3 thiết bị', 4, 0),
(14, N'images/products/chuot/sp12-logitech-pebble-m350s/image-05.png', N'Chuột kết hợp cùng bàn phím Logitech K380 thành bộ đôi hoàn hảo', 5, 0),
(15, N'images/products/chuot/sp13-logitech-mx-master-3s/main.png', N'Chuột công thái học cao cấp Logitech MX Master 3S chính diện', 1, 1),
(15, N'images/products/chuot/sp13-logitech-mx-master-3s/image-02.png', N'Cận cảnh con lăn điện từ MagSpeed và con lăn phụ ngón tay cái', 2, 0),
(15, N'images/products/chuot/sp13-logitech-mx-master-3s/image-03.jpg', N'Thiết kế ôm trọn bàn tay nâng đỡ ngón tay cái công thái học', 3, 0),
(15, N'images/products/chuot/sp13-logitech-mx-master-3s/image-04.jpg', N'Cổng sạc nhanh USB-C phía trước đầu chuột', 4, 0),
(15, N'images/products/chuot/sp13-logitech-mx-master-3s/image-05.png', N'Cảm biến Darkfield 8000 DPI hoạt động mượt mà trên mặt kính', 5, 0),
(16, N'images/products/chuot/sp14-razer-deathadder-v2x/main.jpg', N'Chuột gaming không dây Razer DeathAdder V2 X HyperSpeed', 1, 1),
(16, N'images/products/chuot/sp14-razer-deathadder-v2x/image-02.png', N'Form dáng công thái học ôm trọn lòng bàn tay huyền thoại', 2, 0),
(16, N'images/products/chuot/sp14-razer-deathadder-v2x/image-03.jpg', N'Cụm 2 nút phụ bố trí ngay góc trái phím bấm chính', 3, 0),
(16, N'images/products/chuot/sp14-razer-deathadder-v2x/image-04.jpg', N'Khay chứa pin kép thông minh hỗ trợ cả pin AA và AAA', 4, 0),
(16, N'images/products/chuot/sp14-razer-deathadder-v2x/image-05.jpg', N'Feet chuột 100% PTFE nguyên chất lướt siêu êm trên bàn di chuột', 5, 0),
(17, N'images/products/chuot/sp15-dareu-em901x/main.jpg', N'Bộ đôi chuột DareU EM901X RGB đặt trên dock sạc nam châm', 1, 1),
(17, N'images/products/chuot/sp15-dareu-em901x/image-02.jpg', N'Góc nghiêng chuột thể hiện dải đèn LED RGB uốn lượn sắc sảo', 2, 0),
(17, N'images/products/chuot/sp15-dareu-em901x/image-03.jpg', N'Cận cảnh chân tiếp xúc sạc nam châm mạ vàng dưới đáy chuột', 3, 0),
(17, N'images/products/chuot/sp15-dareu-em901x/image-04.jpg', N'Dock sạc tích hợp cổng cắm USB receiver tiện lợi', 4, 0),
(17, N'images/products/chuot/sp15-dareu-em901x/image-05.jpg', N'Chuột cầm nắm thực tế trên tay thao tác mượt mà', 5, 0),
(18, N'images/products/chuot/sp16-logitech-lift/main.png', N'Chuột công thái học đứng Logitech Lift góc nghiêng 57 độ', 1, 1),
(18, N'images/products/chuot/sp16-logitech-lift/image-02.png', N'Tư thế đặt tay tự nhiên như bắt tay giúp giảm áp lực cổ tay', 2, 0),
(18, N'images/products/chuot/sp16-logitech-lift/image-03.png', N'Con lăn SmartWheel và 2 nút bấm tĩnh âm chống ồn', 3, 0),
(18, N'images/products/chuot/sp16-logitech-lift/image-04.png', N'Cạnh bên bọc cao su vân sọc êm ái chống trơn trượt', 4, 0),
(18, N'images/products/chuot/sp16-logitech-lift/image-05.png', N'Mặt đáy chuột với nút Easy-Switch và khay pin AA kèm khe cắm Logi Bolt', 5, 0),
(19, N'images/products/chuot/sp17-pulsar-x2-v2/main.jpg', N'Chuột gaming siêu nhẹ 53g Pulsar X2 V2 vỏ liền cao cấp', 1, 1),
(19, N'images/products/chuot/sp17-pulsar-x2-v2/image-02.jpg', N'Góc nghiêng thể hiện thiết kế đối xứng đối trọng hoàn hảo', 2, 0),
(19, N'images/products/chuot/sp17-pulsar-x2-v2/image-03.jpg', N'Mặt đáy chuột với cảm biến PixArt PAW3395 và nút chuyển DPI', 3, 0),
(19, N'images/products/chuot/sp17-pulsar-x2-v2/image-04.jpg', N'Switch quang học chống double-click siêu nhạy', 4, 0),
(19, N'images/products/chuot/sp17-pulsar-x2-v2/image-05.png', N'Trọn bộ sản phẩm gồm chuột, dây cáp Superflex Paracord và receiver', 5, 0),
(20, N'images/products/chuot/sp18-xiaomi-silent/main.jpg', N'Chuột không dây tĩnh âm Xiaomi Dual Mode Silent Edition', 1, 1),
(20, N'images/products/chuot/sp18-xiaomi-silent/image-02.jpg', N'Nút bấm chuyển đổi nhanh giữa Bluetooth và USB 2.4GHz', 2, 0),
(20, N'images/products/chuot/sp18-xiaomi-silent/image-03.jpg', N'Hông chuột thiết kế vân chấm bi chống trơn trượt', 3, 0),
(20, N'images/products/chuot/sp18-xiaomi-silent/image-04.jpg', N'Nắp chuột nam châm dễ dàng mở khay pin AAA và khe cất receiver', 4, 0),
(20, N'images/products/chuot/sp18-xiaomi-silent/image-05.png', N'Chuột gọn gàng đồng hành cùng laptop văn phòng', 5, 0);
GO
INSERT INTO ProductImages (ProductID, ImageURL, Caption, DisplayOrder, IsMain) VALUES
(21, N'images/products/chuot/sp19-corsair-harpoon-pro/main.jpg', N'Chuột gaming Corsair Harpoon RGB PRO chính diện', 1, 1),
(21, N'images/products/chuot/sp19-corsair-harpoon-pro/image-02.jpg', N'Hai cạnh hông bọc cao su đúc vân kim cương chống trượt', 2, 0),
(21, N'images/products/chuot/sp19-corsair-harpoon-pro/image-03.jpg', N'Logo thuyền buồm Corsair phát sáng LED RGB rực rỡ', 3, 0),
(21, N'images/products/chuot/sp19-corsair-harpoon-pro/image-04.jpg', N'Cụm 2 nút phụ bên hông bấm nhẹ và nảy', 4, 0),
(21, N'images/products/chuot/sp19-corsair-harpoon-pro/image-05.jpg', N'Cảm biến 12000 DPI và feet chuột lướt êm ái', 5, 0),
(22, N'images/products/chuot/sp20-atk-dragonfly-f1/main.jpg', N'Chuột gaming không dây ATK Dragonfly F1 Pro Max 55g', 1, 1),
(22, N'images/products/chuot/sp20-atk-dragonfly-f1/image-02.jpg', N'Form chuột cân xứng ôm tay thích hợp kiểu cầm Claw và Fingertip', 2, 0),
(22, N'images/products/chuot/sp20-atk-dragonfly-f1/image-03.jpg', N'Cảm biến PixArt PAW3395 26000 DPI đỉnh cao', 3, 0),
(22, N'images/products/chuot/sp20-atk-dragonfly-f1/image-04.jpg', N'Switch Kailh Golden Black Mamba 90 triệu lượt nhấn', 4, 0),
(22, N'images/products/chuot/sp20-atk-dragonfly-f1/image-05.jpg', N'Phụ kiện gồm dây sạc bọc dù Type-C và bộ grip tape dán chống trượt', 5, 0),
(23, N'images/products/tai-nghe/sp22-razer-blackshark-v2x/main.jpg', N'Tai nghe gaming Razer BlackShark V2 X màu đen mạnh mẽ', 1, 1),
(23, N'images/products/tai-nghe/sp22-razer-blackshark-v2x/image-02.png', N'Củ loa độc quyền Razer TriForce 50mm tái tạo âm thanh chi tiết', 2, 0),
(23, N'images/products/tai-nghe/sp22-razer-blackshark-v2x/image-03.png', N'Micro Razer HyperClear lọc tạp âm định hướng', 3, 0),
(23, N'images/products/tai-nghe/sp22-razer-blackshark-v2x/image-04.jpg', N'Đệm tai mút hoạt tính bọc da cách âm thụ động vượt trội', 4, 0),
(23, N'images/products/tai-nghe/sp22-razer-blackshark-v2x/image-05.png', N'Núm xoay chỉnh âm lượng vật lý lớn trên ốp tai trái', 5, 0),
(24, N'images/products/tai-nghe/sp23-logitech-g435/main.jpg', N'Tai nghe gaming không dây siêu nhẹ Logitech G435 165g', 1, 1),
(24, N'images/products/tai-nghe/sp23-logitech-g435/image-02.jpg', N'Đệm tai vải lưới thoáng khí và đệm đầu êm ái', 2, 0),
(24, N'images/products/tai-nghe/sp23-logitech-g435/image-03.png', N'Cụm mic tạo chùm kép ẩn bên trong thân chụp tai', 3, 0),
(24, N'images/products/tai-nghe/sp23-logitech-g435/image-04.png', N'Hệ thống nút bấm nguồn, volume và mic mute ở vành tai trái', 4, 0),
(24, N'images/products/tai-nghe/sp23-logitech-g435/image-05.jpg', N'Tai nghe phối màu cá tính trẻ trung năng động', 5, 0),
(25, N'images/products/tai-nghe/sp24-sony-wh1000xm4/main.jpg', N'Tai nghe chống ồn đỉnh cao Sony WH-1000XM4 màu đen sang trọng', 1, 1),
(25, N'images/products/tai-nghe/sp24-sony-wh1000xm4/image-02.jpg', N'Khả năng gập gọn linh hoạt cất trong bao cứng du lịch cao cấp', 2, 0),
(25, N'images/products/tai-nghe/sp24-sony-wh1000xm4/image-03.jpg', N'Cận cảnh đệm tai bằng uretan mềm giảm áp lực ôm sát tai', 3, 0),
(25, N'images/products/tai-nghe/sp24-sony-wh1000xm4/image-04.jpg', N'Mặt cảm ứng chạm điều khiển bài hát và âm lượng trên củ tai phải', 4, 0),
(25, N'images/products/tai-nghe/sp24-sony-wh1000xm4/image-05.jpg', N'Bộ phụ kiện cáp sạc Type-C, dây 3.5mm và adapter dùng trên máy bay', 5, 0),
(26, N'images/products/tai-nghe/sp25-dareu-eh416/main.jpg', N'Tai nghe gaming DareU EH416 RGB 7.1 chính diện', 1, 1),
(26, N'images/products/tai-nghe/sp25-dareu-eh416/image-02.jpg', N'Đèn LED RGB viền tròn đổi màu rực rỡ trên ốp tai', 2, 0),
(26, N'images/products/tai-nghe/sp25-dareu-eh416/image-03.jpg', N'Khung choàng đầu kim loại đàn hồi tự điều chỉnh theo cỡ đầu', 3, 0),
(26, N'images/products/tai-nghe/sp25-dareu-eh416/image-04.png', N'Cần micro dẻo có thể uốn chỉnh sát miệng tiện lợi', 4, 0),
(26, N'images/products/tai-nghe/sp25-dareu-eh416/image-05.jpg', N'Đệm tai dày bọc da mềm ôm kín vành tai cách âm tốt', 5, 0),
(27, N'images/products/tai-nghe/sp26-edifier-gx07/main.jpg', N'Tai nghe gaming TWS Edifier Hecate GX07 mở hộp cánh chim', 1, 1),
(27, N'images/products/tai-nghe/sp26-edifier-gx07/image-02.jpg', N'Dải đèn LED RGB Cyberpunk trên thân tai nghe và hộp sạc', 2, 0),
(27, N'images/products/tai-nghe/sp26-edifier-gx07/image-03.jpg', N'Thiết kế tai nghe in-ear công thái học bám chắc tai khi vận động', 3, 0),
(27, N'images/products/tai-nghe/sp26-edifier-gx07/image-04.jpg', N'Củ loa 8mm hỗ trợ chuẩn giải mã âm thanh cao cấp Hi-Res LHDC', 4, 0),
(27, N'images/products/tai-nghe/sp26-edifier-gx07/image-05.jpg', N'Bộ nút đệm tai silicon nhiều kích cỡ và dây sạc Type-C', 5, 0),
(28, N'images/products/tai-nghe/sp27-marshall-major-iv/main.jpg', N'Tai nghe Bluetooth Marshall Major IV phong cách cổ điển', 1, 1),
(28, N'images/products/tai-nghe/sp27-marshall-major-iv/image-02.jpg', N'Núm điều khiển đa hướng bằng đồng mạ vàng sang trọng', 2, 0),
(28, N'images/products/tai-nghe/sp27-marshall-major-iv/image-03.jpg', N'Khả năng gập gọn tiện lợi mang theo đi du lịch', 3, 0),
(28, N'images/products/tai-nghe/sp27-marshall-major-iv/image-04.jpg', N'Hỗ trợ sạc không dây chuẩn Qi ngay trên ốp tai', 4, 0),
(28, N'images/products/tai-nghe/sp27-marshall-major-iv/image-05.jpg', N'Chất liệu da nhân tạo vân sần cổ điển mang đậm chất Rock', 5, 0),
(29, N'images/products/tai-nghe/sp28-rog-cetra/main.jpg', N'Tai nghe in-ear gaming Asus ROG Cetra True Wireless', 1, 1),
(29, N'images/products/tai-nghe/sp28-rog-cetra/image-02.png', N'Logo ROG phát sáng trên hộp sạc và thân tai nghe', 2, 0),
(29, N'images/products/tai-nghe/sp28-rog-cetra/image-03.png', N'Củ loa 10mm ASUS Essence cho âm bass dày và sâu', 3, 0),
(29, N'images/products/tai-nghe/sp28-rog-cetra/image-04.jpg', N'Đệm tai silicon công thái học cách âm và bám chắc vành tai', 4, 0),
(29, N'images/products/tai-nghe/sp28-rog-cetra/image-05.png', N'Hộp sạc hỗ trợ sạc không dây chuẩn Qi tiện lợi', 5, 0),
(30, N'images/products/tai-nghe/sp29-corsair-hs55/main.png', N'Tai nghe gaming Corsair HS55 Stereo thiết kế tối giản tinh tế', 1, 1),
(30, N'images/products/tai-nghe/sp29-corsair-hs55/image-02.jpg', N'Cận cảnh củ loa Neodymium 50mm và đệm tai memory foam', 2, 0),
(30, N'images/products/tai-nghe/sp29-corsair-hs55/image-03.jpg', N'Cần micro gập thông minh Flip-to-mute đạt chuẩn Discord', 3, 0),
(30, N'images/products/tai-nghe/sp29-corsair-hs55/image-04.jpg', N'Con lăn chỉnh âm lượng kim loại tinh xảo ở vành tai trái', 4, 0),
(30, N'images/products/tai-nghe/sp29-corsair-hs55/image-05.jpg', N'Khớp xoay củ tai linh hoạt ôm khít theo góc đầu người đeo', 5, 0);
GO
INSERT INTO ProductImages (ProductID, ImageURL, Caption, DisplayOrder, IsMain) VALUES
(31, N'images/products/tai-nghe/sp30-audio-technica-m20x/main.png', N'Tai nghe kiểm âm chuyên nghiệp Audio-Technica ATH-M20x', 1, 1),
(31, N'images/products/tai-nghe/sp30-audio-technica-m20x/image-02.jpg', N'Logo Audio-Technica mạ bạc nổi bật trên hai bên củ tai', 2, 0),
(31, N'images/products/tai-nghe/sp30-audio-technica-m20x/image-03.jpg', N'Củ loa 40mm với nam châm đất hiếm tái tạo âm thanh trung thực', 3, 0),
(31, N'images/products/tai-nghe/sp30-audio-technica-m20x/image-04.jpg', N'Vành đệm bọc da mềm ôm kín tai cách ly tiếng ồn phòng thu', 4, 0),
(31, N'images/products/tai-nghe/sp30-audio-technica-m20x/image-05.jpg', N'Jack cắm 3.5mm mạ vàng kèm đầu chuyển 6.3mm chuyên dụng', 5, 0),
(32, N'images/products/webcam/sp31-logitech-c920/main.jpg', N'Webcam Logitech C920 Pro HD 1080P chính diện', 1, 1),
(32, N'images/products/webcam/sp31-logitech-c920/image-02.jpg', N'Ống kính thủy tinh 5 thành phần và cặp micro Stereo 2 bên', 2, 0),
(32, N'images/products/webcam/sp31-logitech-c920/image-03.jpg', N'Góc nghiêng cho thấy chân kẹp màn hình chắc chắn', 3, 0),
(32, N'images/products/webcam/sp31-logitech-c920/image-04.jpg', N'Mặt đáy tích hợp lỗ ren 1/4 inch gắn chân tripod để bàn', 4, 0),
(32, N'images/products/webcam/sp31-logitech-c920/image-05.jpg', N'Hình ảnh sắc nét trong cuộc gọi video họp trực tuyến', 5, 0),
(33, N'images/products/webcam/sp32-logitech-c270/main.jpg', N'Webcam Logitech C270 HD 720P nhỏ gọn thanh lịch', 1, 1),
(33, N'images/products/webcam/sp32-logitech-c270/image-02.jpg', N'Mặt trước với ống kính HD và đèn LED báo trạng thái hoạt động', 2, 0),
(33, N'images/products/webcam/sp32-logitech-c270/image-03.png', N'Chân kẹp linh hoạt dễ dàng gá lên viền màn hình laptop', 3, 0),
(33, N'images/products/webcam/sp32-logitech-c270/image-04.jpg', N'Micro đơn khử tiếng ồn tích hợp thu âm đàm thoại rõ nét', 4, 0),
(33, N'images/products/webcam/sp32-logitech-c270/image-05.png', N'Kích thước siêu nhỏ gọn thuận tiện bỏ túi mang theo', 5, 0),
(34, N'images/products/webcam/sp33-rapoo-c280/main.jpg', N'Webcam Rapoo C280 độ phân giải siêu nét 2K QHD', 1, 1),
(34, N'images/products/webcam/sp33-rapoo-c280/image-02.jpg', N'Nắp che ống kính bảo mật Privacy Shutter dạng trượt an toàn', 2, 0),
(34, N'images/products/webcam/sp33-rapoo-c280/image-03.jpg', N'Khớp xoay đa hướng 360 độ linh hoạt', 3, 0),
(34, N'images/products/webcam/sp33-rapoo-c280/image-04.jpg', N'Cụm micro kép lọc tạp âm hai bên ống kính', 4, 0),
(34, N'images/products/webcam/sp33-rapoo-c280/image-05.png', N'Chân kẹp đa năng gắn chắc chắn trên viền màn hình máy tính', 5, 0),
(35, N'images/products/webcam/sp34-logitech-brio-4k/main.jpg', N'Webcam cao cấp Logitech Brio 4K Ultra HD thiết kế kim loại sang trọng', 1, 1),
(35, N'images/products/webcam/sp34-logitech-brio-4k/image-02.jpg', N'Cảm biến hồng ngoại nhận diện khuôn mặt mở khóa Windows Hello', 2, 0),
(35, N'images/products/webcam/sp34-logitech-brio-4k/image-03.jpg', N'Ống kính 4K hỗ trợ HDR với 3 tùy chọn góc nhìn FOV', 3, 0),
(35, N'images/products/webcam/sp34-logitech-brio-4k/image-04.jpg', N'Cổng cắm cáp USB Type-C tháo rời linh hoạt phía sau', 4, 0),
(35, N'images/products/webcam/sp34-logitech-brio-4k/image-05.jpg', N'Hộp đựng du lịch cao cấp và nắp che bảo mật tặng kèm', 5, 0),
(36, N'images/products/webcam/sp35-elgato-facecam/main.jpg', N'Webcam chuyên nghiệp Elgato Facecam dành cho streamer', 1, 1),
(36, N'images/products/webcam/sp35-elgato-facecam/image-02.jpg', N'Cảm biến Sony STARVIS CMOS và ống kính thủy tinh 8 thành phần', 2, 0),
(36, N'images/products/webcam/sp35-elgato-facecam/image-03.jpg', N'Cổng cắm USB 3.0 Type-C truyền video không nén', 3, 0),
(36, N'images/products/webcam/sp35-elgato-facecam/image-04.jpg', N'Giao diện phần mềm Elgato Camera Hub tinh chỉnh thông số như máy ảnh cơ', 4, 0),
(36, N'images/products/webcam/sp35-elgato-facecam/image-05.jpg', N'Nắp che ống kính từ tính bảo vệ ống kính khỏi trầy xước và bụi bẩn', 5, 0),
(37, N'images/products/webcam/sp36-emeet-c960/main.png', N'Webcam EMEET SmartCam C960 góc rộng 90 độ', 1, 1),
(37, N'images/products/webcam/sp36-emeet-c960/image-02.jpg', N'Cụm micro kép tích hợp chip DSP chống ồn thông minh', 2, 0),
(37, N'images/products/webcam/sp36-emeet-c960/image-03.jpg', N'Nắp che ống kính bảo mật lật mở linh hoạt', 3, 0),
(37, N'images/products/webcam/sp36-emeet-c960/image-04.jpg', N'Góc nhìn rộng bao quát thích hợp họp nhóm nhiều người', 4, 0),
(37, N'images/products/webcam/sp36-emeet-c960/image-05.jpg', N'Chân kẹp màn hình có đệm mút cao su chống trầy viền LCD', 5, 0),
(38, N'images/products/webcam/sp37-razer-kiyo/main.jpg', N'Webcam Razer Kiyo tích hợp vòng đèn trợ sáng Ring Light', 1, 1),
(38, N'images/products/webcam/sp37-razer-kiyo/image-02.jpg', N'Vành xoay cơ học chỉnh độ sáng tiện lợi quanh viền đèn', 2, 0),
(38, N'images/products/webcam/sp37-razer-kiyo/image-03.jpg', N'Chân kẹp chữ L vững chãi gá trên màn hình hoặc để mặt bàn', 3, 0),
(38, N'images/products/webcam/sp37-razer-kiyo/image-04.jpg', N'Ánh sáng đèn 5600K tôn da và khử bóng tối trên gương mặt', 4, 0),
(38, N'images/products/webcam/sp37-razer-kiyo/image-05.jpg', N'Ống kính Full HD tự động lấy nét chuẩn xác', 5, 0),
(39, N'images/products/webcam/sp38-anker-c200/main.jpg', N'Webcam 2K siêu nét Anker PowerConf C200 thiết kế vuông vắn nhỏ gọn', 1, 1),
(39, N'images/products/webcam/sp38-anker-c200/image-02.jpg', N'Khẩu độ lớn f/2.0 thu sáng vượt trội cho hình ảnh trong trẻo', 2, 0),
(39, N'images/products/webcam/sp38-anker-c200/image-03.jpg', N'Cần gạt nắp che bảo mật Privacy Shutter ở mặt trước', 3, 0),
(39, N'images/products/webcam/sp38-anker-c200/image-04.jpg', N'Chân kẹp xoay 360 độ linh hoạt điều chỉnh mọi góc quay', 4, 0),
(39, N'images/products/webcam/sp38-anker-c200/image-05.jpg', N'Cổng cắm Type-C tháo rời tiện lợi khi cất gọn vào balo', 5, 0),
(40, N'images/products/webcam/sp39-asus-rog-eye-s/main.jpg', N'Webcam gaming Asus ROG Eye S thiết kế siêu mỏng phong cách eSports', 1, 1),
(40, N'images/products/webcam/sp39-asus-rog-eye-s/image-02.jpg', N'Khả năng gấp phẳng chỉ 17mm cực kỳ cơ động', 2, 0),
(40, N'images/products/webcam/sp39-asus-rog-eye-s/image-03.jpg', N'Cụm micro AI Noise-Canceling lọc sạch tạp âm tiếng phím cơ', 3, 0),
(40, N'images/products/webcam/sp39-asus-rog-eye-s/image-04.jpg', N'Thấu kính Blue Glass lọc tia hồng ngoại chống sai màu', 4, 0),
(40, N'images/products/webcam/sp39-asus-rog-eye-s/image-05.png', N'Chân kẹp hợp kim nhôm bám chắc viền màn hình laptop gaming', 5, 0);
GO
INSERT INTO ProductImages (ProductID, ImageURL, Caption, DisplayOrder, IsMain) VALUES
(41, N'images/products/webcam/sp40-a4tech-pk910h/main.jpg', N'Webcam Full HD 1080P A4Tech PK-910H chính diện', 1, 1),
(41, N'images/products/webcam/sp40-a4tech-pk910h/image-02.png', N'Ống kính quang học phủ lớp chống chói lóa Anti-glare', 2, 0),
(41, N'images/products/webcam/sp40-a4tech-pk910h/image-03.jpg', N'Khớp xoay 360 độ điều chỉnh góc nhìn không giới hạn', 3, 0),
(41, N'images/products/webcam/sp40-a4tech-pk910h/image-04.jpg', N'Chân đế gấp chữ Z đặt bàn hoặc kẹp màn hình tiện lợi', 4, 0),
(41, N'images/products/webcam/sp40-a4tech-pk910h/image-05.png', N'Cổng cắm USB mạ tiếp xúc chắc chắn', 5, 0),
(42, N'images/products/hub-cap/sp42-baseus-metal-gleam-8in1/main.jpg', N'Hub USB-C 8in1 Baseus Metal Gleam Series vỏ nhôm sang trọng', 1, 1),
(42, N'images/products/hub-cap/sp42-baseus-metal-gleam-8in1/image-02.jpg', N'Cổng mạng LAN RJ45 Gigabit 1000Mbps truyền dữ liệu siêu tốc', 2, 0),
(42, N'images/products/hub-cap/sp42-baseus-metal-gleam-8in1/image-03.jpg', N'Cổng xuất màn hình HDMI 4K và 3 cổng USB 3.0 5Gbps', 3, 0),
(42, N'images/products/hub-cap/sp42-baseus-metal-gleam-8in1/image-04.jpg', N'Cổng sạc nhanh USB-C Power Delivery công suất khủng 100W', 4, 0),
(42, N'images/products/hub-cap/sp42-baseus-metal-gleam-8in1/image-05.jpg', N'Đèn LED báo trạng thái màu xanh băng sang trọng', 5, 0),
(43, N'images/products/hub-cap/sp43-ugreen-20291-hub4port/main.jpg', N'Bộ chia 4 cổng USB 3.0 Ugreen 20291 thiết kế bo tròn nhỏ gọn', 1, 1),
(43, N'images/products/hub-cap/sp43-ugreen-20291-hub4port/image-02.jpg', N'4 cổng cắm USB 3.0 bố trí khoa học không bị cấn chân cắm', 2, 0),
(43, N'images/products/hub-cap/sp43-ugreen-20291-hub4port/image-03.jpg', N'Cổng nguồn phụ Micro USB 5V hỗ trợ đọc ổ cứng di động nặng dung lượng lớn', 3, 0),
(43, N'images/products/hub-cap/sp43-ugreen-20291-hub4port/image-04.jpg', N'Dây cáp đúc dẻo dai chống đứt gãy lõi đồng nguyên chất', 4, 0),
(43, N'images/products/hub-cap/sp43-ugreen-20291-hub4port/image-05.jpg', N'Đèn LED hiển thị trạng thái kết nối nguồn sáng rõ', 5, 0),
(44, N'images/products/hub-cap/sp44-orico-pw11-6p/main.jpg', N'Hub USB-C 6in1 Orico PW11-6P vỏ nhôm tản nhiệt cao cấp', 1, 1),
(44, N'images/products/hub-cap/sp44-orico-pw11-6p/image-02.jpg', N'Cổng HDMI 4K xuất hình ảnh sắc nét sang TV và máy chiếu', 2, 0),
(44, N'images/products/hub-cap/sp44-orico-pw11-6p/image-03.jpg', N'Cổng USB-C sạc nhanh Power Delivery 100W nạp pin laptop siêu tốc', 3, 0),
(44, N'images/products/hub-cap/sp44-orico-pw11-6p/image-04.png', N'3 cổng USB 3.0 tốc độ cao truyền file dữ liệu nặng nhanh chóng', 4, 0),
(44, N'images/products/hub-cap/sp44-orico-pw11-6p/image-05.jpg', N'Kích thước thanh mảnh bỏ vừa ngăn phụ túi chống sốc laptop', 5, 0),
(45, N'images/products/hub-cap/sp45-anker-322-typec-100w/main.png', N'Cáp sạc siêu bền Anker 322 Type-C sang Type-C công suất 100W', 1, 1),
(45, N'images/products/hub-cap/sp45-anker-322-typec-100w/image-02.jpg', N'Lớp vỏ bện sợi Nylon kép cao cấp chống gập gãy đứt ngầm', 2, 0),
(45, N'images/products/hub-cap/sp45-anker-322-typec-100w/image-03.jpg', N'Đầu cắm Type-C đúc nhôm nguyên khối gia cường mối nối', 3, 0),
(45, N'images/products/hub-cap/sp45-anker-322-typec-100w/image-04.png', N'Chiều dài 1.8m lý tưởng cho mọi không gian làm việc và phòng khách', 4, 0),
(45, N'images/products/hub-cap/sp45-anker-322-typec-100w/image-05.png', N'Chip E-Marker thông minh sạc an toàn chống quá nhiệt cho laptop', 5, 0),
(46, N'images/products/hub-cap/sp46-ugreen-80403-hdmi8k/main.jpg', N'Cáp HDMI 2.1 chuẩn 8K Ugreen 80403 bọc dù siêu bền 2m', 1, 1),
(46, N'images/products/hub-cap/sp46-ugreen-80403-hdmi8k/image-02.jpg', N'Đầu cắm mạ vàng 24K chống gỉ sét và chống nhiễu điện từ', 2, 0),
(46, N'images/products/hub-cap/sp46-ugreen-80403-hdmi8k/image-03.jpg', N'Hỗ trợ tần số quét mượt mà 4K@120Hz và eARC Dolby Atmos', 3, 0),
(46, N'images/products/hub-cap/sp46-ugreen-80403-hdmi8k/image-04.jpg', N'Lõi đồng nguyên chất bọc 3 lớp giáp chống nhiễu tín hiệu', 4, 0),
(46, N'images/products/hub-cap/sp46-ugreen-80403-hdmi8k/image-05.jpg', N'Cáp kết nối hoàn hảo giữa PlayStation 5 và TV OLED màn hình lớn', 5, 0),
(47, N'images/products/hub-cap/sp47-hyperdrive-6in1/main.jpg', N'Hub cao cấp HyperDrive 4K HDMI 6-in-1 chuẩn USA', 1, 1),
(47, N'images/products/hub-cap/sp47-hyperdrive-6in1/image-02.jpg', N'Khả năng xuất hình HDMI 4K@60Hz siêu mượt mà không mỏi mắt', 2, 0),
(47, N'images/products/hub-cap/sp47-hyperdrive-6in1/image-03.jpg', N'Vỏ hợp kim nhôm CNC chuẩn màu sắc Space Gray của MacBook', 3, 0),
(47, N'images/products/hub-cap/sp47-hyperdrive-6in1/image-04.jpg', N'Cổng sạc Power Delivery 100W nạp đầy pin máy tính trong tích tắc', 4, 0),
(47, N'images/products/hub-cap/sp47-hyperdrive-6in1/image-05.jpg', N'Khe cắm thẻ nhớ kép SD và microSD cho nhiếp ảnh gia', 5, 0),
(48, N'images/products/hub-cap/sp48-ugreen-40363-dp-hdmi/main.jpg', N'Cáp chuyển đổi DisplayPort sang HDMI Ugreen 40363 chính diện', 1, 1),
(48, N'images/products/hub-cap/sp48-ugreen-40363-dp-hdmi/image-02.jpg', N'Đầu DisplayPort có chốt bấm khóa an toàn chống tuột giắc cắm', 2, 0),
(48, N'images/products/hub-cap/sp48-ugreen-40363-dp-hdmi/image-03.jpg', N'Chân cắm mạ vàng 24K tăng độ bền và chống oxy hóa bề mặt', 3, 0),
(48, N'images/products/hub-cap/sp48-ugreen-40363-dp-hdmi/image-04.jpg', N'Truyền tải đồng thời cả hình ảnh 4K và âm thanh vòm 7.1', 4, 0),
(48, N'images/products/hub-cap/sp48-ugreen-40363-dp-hdmi/image-05.jpg', N'Dây cáp bọc nhựa PVC dẻo mềm uốn cong gọn gàng sau thùng case', 5, 0),
(49, N'images/products/hub-cap/sp49-baseus-flash-3in1/main.jpg', N'Cáp sạc đa năng 3 trong 1 Baseus Flash Series 2 công suất 100W', 1, 1),
(49, N'images/products/hub-cap/sp49-baseus-flash-3in1/image-02.jpg', N'3 đầu cắm Type-C, Lightning và Micro USB đáp ứng mọi thiết bị', 2, 0),
(49, N'images/products/hub-cap/sp49-baseus-flash-3in1/image-03.jpg', N'Đèn LED thông minh báo trạng thái sạc nhanh tiện lợi', 3, 0),
(49, N'images/products/hub-cap/sp49-baseus-flash-3in1/image-04.jpg', N'Khớp nối đúc cao su đàn hồi chịu gập uốn trên 10000 lần', 4, 0),
(49, N'images/products/hub-cap/sp49-baseus-flash-3in1/image-05.jpg', N'Sạc đồng thời cùng lúc điện thoại, máy tính bảng và tai nghe', 5, 0),
(50, N'images/products/hub-cap/sp50-ugreen-50283-otg/main.jpg', N'Đầu chuyển đổi Type-C sang USB 3.0 OTG Ugreen 50283 siêu nhỏ gọn', 1, 1),
(50, N'images/products/hub-cap/sp50-ugreen-50283-otg/image-02.jpg', N'Vỏ hợp kim nhôm xám nguyên khối chống trầy xước va đập', 2, 0),
(50, N'images/products/hub-cap/sp50-ugreen-50283-otg/image-03.jpg', N'Kết nối USB flash drive trực tiếp vào điện thoại và iPad đọc file tức thì', 3, 0),
(50, N'images/products/hub-cap/sp50-ugreen-50283-otg/image-04.jpg', N'Tốc độ truyền dữ liệu chuẩn USB 3.0 lên tới 5Gbps', 4, 0),
(50, N'images/products/hub-cap/sp50-ugreen-50283-otg/image-05.png', N'Kèm dây móc treo chống rơi mất tiện lợi treo cùng chìa khóa', 5, 0);
GO
INSERT INTO ProductImages (ProductID, ImageURL, Caption, DisplayOrder, IsMain) VALUES
(51, N'images/products/gia-do-laptop/sp51-gia-do-n3/main.jpg', N'Giá đỡ laptop hợp kim nhôm N3 chỉnh 6 cấp độ cao', 1, 1),
(51, N'images/products/gia-do-laptop/sp51-gia-do-n3/image-02.jpg', N'Cơ chế 6 nấc nẹp chỉnh góc nghiêng công thái học', 2, 0),
(51, N'images/products/gia-do-laptop/sp51-gia-do-n3/image-03.jpg', N'Đệm cao su silicon chống trầy viền máy và chống trượt', 3, 0),
(51, N'images/products/gia-do-laptop/sp51-gia-do-n3/image-04.jpg', N'Khả năng gấp gọn thành một thanh dài kèm túi nỉ du lịch', 4, 0),
(51, N'images/products/gia-do-laptop/sp51-gia-do-n3/image-05.jpg', N'Không gian đáy mở thoáng hỗ trợ laptop tản nhiệt tối ưu', 5, 0),
(52, N'images/products/gia-do-laptop/sp52-moft-z/main.jpg', N'Giá đỡ bàn đứng Origami MOFT Z biến mọi mặt bàn thành bàn đứng', 1, 1),
(52, N'images/products/gia-do-laptop/sp52-moft-z/image-02.png', N'Tư thế đứng nâng cao 25cm giúp duỗi thẳng cột sống làm việc', 2, 0),
(52, N'images/products/gia-do-laptop/sp52-moft-z/image-03.jpg', N'Tư thế ngồi 25 độ và 45 độ gõ phím công thái học', 3, 0),
(52, N'images/products/gia-do-laptop/sp52-moft-z/image-04.jpg', N'Khả năng gấp phẳng chỉ 1.2cm dễ dàng nhét vừa ngăn balo', 4, 0),
(52, N'images/products/gia-do-laptop/sp52-moft-z/image-05.jpg', N'Chất liệu da PU sợi thủy tinh cao cấp chịu lực 10kg vững chãi', 5, 0),
(53, N'images/products/gia-do-laptop/sp53-baseus-ultra-stable-360/main.jpg', N'Giá đỡ laptop xoay 360 độ Baseus Ultra Stable Pro cao cấp', 1, 1),
(53, N'images/products/gia-do-laptop/sp53-baseus-ultra-stable-360/image-02.jpg', N'Đế xoay 360 độ cơ học tiện lợi chia sẻ màn hình trong cuộc họp', 2, 0),
(53, N'images/products/gia-do-laptop/sp53-baseus-ultra-stable-360/image-03.jpg', N'Trục tay đòn kép nâng cao màn hình ngang tầm mắt làm việc', 3, 0),
(53, N'images/products/gia-do-laptop/sp53-baseus-ultra-stable-360/image-04.jpg', N'Mặt đỡ khoét rãnh tản nhiệt đối lưu luồng khí mát', 4, 0),
(53, N'images/products/gia-do-laptop/sp53-baseus-ultra-stable-360/image-05.jpg', N'Khung nhôm nguyên khối vững chãi gõ phím không rung lắc', 5, 0),
(54, N'images/products/gia-do-laptop/sp54-gia-do-p11/main.jpg', N'Giá đỡ laptop công thái học P11 nâng cao màn hình ngang mắt', 1, 1),
(54, N'images/products/gia-do-laptop/sp54-gia-do-p11/image-02.jpg', N'Khớp xoay đôi chịu lực điều chỉnh độ cao và góc nghiêng tự do', 2, 0),
(54, N'images/products/gia-do-laptop/sp54-gia-do-p11/image-03.jpg', N'Mặt nhôm dày dặn khoét khe tản nhiệt khí động học lớn', 3, 0),
(54, N'images/products/gia-do-laptop/sp54-gia-do-p11/image-04.png', N'Móc đỡ bo cong có lót cao su mềm chống xước cạnh máy tính', 4, 0),
(54, N'images/products/gia-do-laptop/sp54-gia-do-p11/image-05.png', N'Khả năng gấp gọn phẳng tiện cất vào ngăn kéo bàn làm việc', 5, 0),
(55, N'images/products/gia-do-laptop/sp55-orico-kep-dung/main.jpg', N'Giá đỡ laptop dựng đứng 2 khe cắm Orico nhôm nguyên khối', 1, 1),
(55, N'images/products/gia-do-laptop/sp55-orico-kep-dung/image-02.jpg', N'Tiết kiệm 80% diện tích mặt bàn khi dùng laptop với màn hình ngoài', 2, 0),
(55, N'images/products/gia-do-laptop/sp55-orico-kep-dung/image-03.jpg', N'Ốc vặn cơ học dưới đáy điều chỉnh độ rộng khe kẹp từ 14mm đến 42mm', 3, 0),
(55, N'images/products/gia-do-laptop/sp55-orico-kep-dung/image-04.jpg', N'Lớp đệm silicon phủ kín lòng khe bảo vệ chống trầy xước vỏ máy', 4, 0),
(55, N'images/products/gia-do-laptop/sp55-orico-kep-dung/image-05.jpg', N'Cắm đồng thời 1 laptop và 1 máy tính bảng iPad ngay ngắn trên bàn', 5, 0),
(56, N'images/products/gia-do-laptop/sp56-samdi-go-soi/main.jpg', N'Giá đỡ laptop gỗ sồi tự nhiên SAMDI phong cách mộc mạc Bắc Âu', 1, 1),
(56, N'images/products/gia-do-laptop/sp56-samdi-go-soi/image-02.jpg', N'Đường cong uốn lượn mềm mại gia công ép nhiệt thủ công tinh xảo', 2, 0),
(56, N'images/products/gia-do-laptop/sp56-samdi-go-soi/image-03.jpg', N'Vân gỗ sồi tự nhiên ấm áp tạo điểm nhấn cho góc làm việc', 3, 0),
(56, N'images/products/gia-do-laptop/sp56-samdi-go-soi/image-04.jpg', N'Khoảng trống bên dưới tiện lợi cất gọn bàn phím và phụ kiện', 4, 0),
(56, N'images/products/gia-do-laptop/sp56-samdi-go-soi/image-05.jpg', N'Đệm cao su dưới đáy chống trơn trượt trên mặt bàn gỗ', 5, 0),
(57, N'images/products/gia-do-laptop/sp57-gia-do-n8/main.jpg', N'Giá đỡ laptop hợp kim nhôm 2 tầng N8 nâng cao tối đa', 1, 1),
(57, N'images/products/gia-do-laptop/sp57-gia-do-n8/image-02.jpg', N'Hệ thống thanh giằng đôi kép chịu lực tới 25kg không rung lắc', 2, 0),
(57, N'images/products/gia-do-laptop/sp57-gia-do-n8/image-03.jpg', N'Màn hình laptop được nâng cao tới hơn 20cm ngang tầm mắt', 3, 0),
(57, N'images/products/gia-do-laptop/sp57-gia-do-n8/image-04.jpg', N'Đệm cao su bảo vệ toàn diện các điểm tiếp xúc với laptop', 4, 0),
(57, N'images/products/gia-do-laptop/sp57-gia-do-n8/image-05.jpg', N'Khả năng gấp rút gọn gàng bỏ vừa balo du lịch', 5, 0),
(58, N'images/products/gia-do-laptop/sp58-rain-design-mstand/main.jpg', N'Giá đỡ nhôm nguyên khối cao cấp Rain Design mStand chuẩn Apple', 1, 1),
(58, N'images/products/gia-do-laptop/sp58-rain-design-mstand/image-02.jpg', N'Đường uốn cong liền mạch hình giọt nước không mối hàn', 2, 0),
(58, N'images/products/gia-do-laptop/sp58-rain-design-mstand/image-02.webp', N'Lỗ luồn dây cáp thông minh phía sau giữ bàn làm việc gọn gàng', 3, 0),
(58, N'images/products/gia-do-laptop/sp58-rain-design-mstand/image-03.jpg', N'Mặt nhôm nguyên khối tản nhiệt thụ động hiệu quả cho đáy laptop', 4, 0),
(58, N'images/products/gia-do-laptop/sp58-rain-design-mstand/image-04.jpg', N'Chất liệu nhôm Anodized màu Space Gray đồng điệu cùng MacBook', 5, 0),
(59, N'images/products/gia-do-laptop/sp59-ugreen-40289/main.jpg', N'Giá đỡ laptop hợp kim nhôm chính hãng Ugreen 40289', 1, 1),
(59, N'images/products/gia-do-laptop/sp59-ugreen-40289/image-02.jpg', N'Cấu trúc khung tam giác kép vững chãi chống rung khi gõ phím', 2, 0),
(59, N'images/products/gia-do-laptop/sp59-ugreen-40289/image-03.jpg', N'5 nấc điều chỉnh góc nghiêng công thái học linh hoạt', 3, 0),
(59, N'images/products/gia-do-laptop/sp59-ugreen-40289/image-04.jpg', N'Đệm cao su silicon cao cấp phủ kín các vị trí tiếp xúc', 4, 0),
(59, N'images/products/gia-do-laptop/sp59-ugreen-40289/image-05.jpg', N'Khả năng gấp gọn thanh mảnh kèm túi nỉ chính hãng Ugreen', 5, 0),
(60, N'images/products/gia-do-laptop/sp60-ugreen-lp258-doc/main.jpg', N'Giá đỡ laptop dựng dọc Ugreen LP258 nhôm xám cho MacBook', 1, 1),
(60, N'images/products/gia-do-laptop/sp60-ugreen-lp258-doc/image-02.jpg', N'Núm xoay tay cơ học chỉnh độ rộng khe kẹp từ 12mm đến 26mm', 2, 0),
(60, N'images/products/gia-do-laptop/sp60-ugreen-lp258-doc/image-03.jpg', N'Đệm cao su silicon bảo vệ toàn diện bên trong lòng khe kẹp', 3, 0),
(60, N'images/products/gia-do-laptop/sp60-ugreen-lp258-doc/image-04.jpg', N'Thiết kế chân đế bản rộng vững chãi chống lật ngã', 4, 0),
(60, N'images/products/gia-do-laptop/sp60-ugreen-lp258-doc/image-05.jpg', N'Giải phóng tối đa diện tích bàn làm việc khi kết nối màn hình ngoài', 5, 0);
GO
INSERT INTO ProductImages (ProductID, ImageURL, Caption, DisplayOrder, IsMain) VALUES
(61, N'images/products/de-tan-nhiet/sp61-cm-notepal-xslim/main.jpg', N'Đế tản nhiệt Cooler Master Notepal X-Slim lưới kim loại chữ X', 1, 1),
(61, N'images/products/de-tan-nhiet/sp61-cm-notepal-xslim/image-02.jpg', N'Quạt làm mát siêu lớn 160mm êm ái ở trung tâm', 2, 0),
(61, N'images/products/de-tan-nhiet/sp61-cm-notepal-xslim/image-03.jpg', N'Thiết kế siêu mỏng chỉ 27.5mm dễ dàng mang theo trong balo', 3, 0),
(61, N'images/products/de-tan-nhiet/sp61-cm-notepal-xslim/image-04.jpg', N'Đầu cắm USB Pass-Through không làm hao hụt cổng USB máy tính', 4, 0),
(61, N'images/products/de-tan-nhiet/sp61-cm-notepal-xslim/image-05.png', N'Chân đế nẹp nâng độ cao công thái học gõ phím thoải mái', 5, 0),
(62, N'images/products/de-tan-nhiet/sp62-cm-notepal-l2/main.jpg', N'Đế tản nhiệt Cooler Master Notepal L2 với đèn LED xanh dịu mắt', 1, 1),
(62, N'images/products/de-tan-nhiet/sp62-cm-notepal-l2/image-02.jpg', N'Mặt lưới kim loại tản nhiệt cao cấp phân phối luồng gió mát', 2, 0),
(62, N'images/products/de-tan-nhiet/sp62-cm-notepal-l2/image-03.jpg', N'Quạt lớn 160mm với cánh quạt trong suốt tản sáng LED đẹp mắt', 3, 0),
(62, N'images/products/de-tan-nhiet/sp62-cm-notepal-l2/image-04.jpg', N'Cổng cắm USB đôi và nút bật tắt nguồn tiện lợi phía sau', 4, 0),
(62, N'images/products/de-tan-nhiet/sp62-cm-notepal-l2/image-05.png', N'Góc nâng nghiêng 8 độ công thái học cho tư thế gõ phím lý tưởng', 5, 0),
(63, N'images/products/de-tan-nhiet/sp63-iets-gt500/main.png', N'Đế tản nhiệt laptop gaming quái vật IETS GT500 tốc độ 5000 RPM', 1, 1),
(63, N'images/products/de-tan-nhiet/sp63-iets-gt500/image-02.jpg', N'Vòng đệm mút bọt biển Sealing Foam ép kín áp suất gió đáy máy', 2, 0),
(63, N'images/products/de-tan-nhiet/sp63-iets-gt500/image-03.jpg', N'Núm xoay điều tốc chiết áp vô cấp tùy chỉnh tốc độ quạt', 3, 0),
(63, N'images/products/de-tan-nhiet/sp63-iets-gt500/image-04.jpg', N'Màng lọc bụi tháo rời giặt rửa bảo vệ nội thất laptop khỏi bụi bẩn', 4, 0),
(63, N'images/products/de-tan-nhiet/sp63-iets-gt500/image-05.jpg', N'Bộ nguồn adapter 12V cấp điện độc lập công suất tối đa', 5, 0),
(64, N'images/products/de-tan-nhiet/sp64-kootek-chill-6quat/main.jpg', N'Đế tản nhiệt Kootek 6 quạt kết hợp dải đèn viền RGB gaming', 1, 1),
(64, N'images/products/de-tan-nhiet/sp64-kootek-chill-6quat/image-02.jpg', N'Màn hình LCD mini và cụm phím điều chỉnh tốc độ gió trực quan', 2, 0),
(64, N'images/products/de-tan-nhiet/sp64-kootek-chill-6quat/image-03.jpg', N'Hệ thống 6 quạt tản nhiệt làm mát toàn diện mọi góc bo mạch', 3, 0),
(64, N'images/products/de-tan-nhiet/sp64-kootek-chill-6quat/image-04.jpg', N'7 nấc nâng độ cao công thái học chống mỏi cổ vai gáy', 4, 0),
(64, N'images/products/de-tan-nhiet/sp64-kootek-chill-6quat/image-05.jpg', N'Thanh chặn chống trượt gập mở phía trước giữ máy an toàn', 5, 0),
(65, N'images/products/de-tan-nhiet/sp65-deepcool-upal/main.jpg', N'Đế tản nhiệt Deepcool U-Pal thiết kế chữ U độc đáo', 1, 1),
(65, N'images/products/de-tan-nhiet/sp65-deepcool-upal/image-02.png', N'Cặp quạt kép 140mm tạo lưu lượng gió 92.22 CFM cực mạnh', 2, 0),
(65, N'images/products/de-tan-nhiet/sp65-deepcool-upal/image-03.png', N'Khoảng rỗng khí động học chữ U ngăn chặn hiện tượng tuần hoàn khí nóng', 3, 0),
(65, N'images/products/de-tan-nhiet/sp65-deepcool-upal/image-04.png', N'Đầu cắm USB 3.0 Pass-through bảo toàn cổng USB tốc độ cao cho laptop', 4, 0),
(65, N'images/products/de-tan-nhiet/sp65-deepcool-upal/image-05.png', N'Khung chân đế nẹp 6 nấc độ nghiêng vững chãi', 5, 0),
(66, N'images/products/de-tan-nhiet/sp66-llano-rgb-tuabin/main.jpg', N'Đế tản nhiệt tuabin áp suất cao Llano RGB chính diện', 1, 1),
(66, N'images/products/de-tan-nhiet/sp66-llano-rgb-tuabin/image-02.jpg', N'Màn hình cảm ứng LED hiển thị và điều chỉnh chính xác tốc độ quạt', 2, 0),
(66, N'images/products/de-tan-nhiet/sp66-llano-rgb-tuabin/image-03.jpg', N'Vòng đệm kín khí silicon từ tính áp sát đáy laptop', 3, 0),
(66, N'images/products/de-tan-nhiet/sp66-llano-rgb-tuabin/image-04.jpg', N'Dải đèn LED RGB đổi màu phong cách chiến hạm gaming', 4, 0),
(66, N'images/products/de-tan-nhiet/sp66-llano-rgb-tuabin/image-05.jpg', N'Màng lọc bụi kim loại mặt đáy tháo rời vệ sinh dễ dàng', 5, 0),
(67, N'images/products/de-tan-nhiet/sp67-n191-2quat/main.jpg', N'Đế tản nhiệt 2 quạt N191 bền bỉ giá tốt', 1, 1),
(67, N'images/products/de-tan-nhiet/sp67-n191-2quat/image-02.jpg', N'Mặt lưới kim loại tản nhiệt sơn tĩnh điện chống gỉ', 2, 0),
(67, N'images/products/de-tan-nhiet/sp67-n191-2quat/image-03.jpg', N'Hai quạt 140mm đèn LED xanh êm ái xua tan hơi nóng', 3, 0),
(67, N'images/products/de-tan-nhiet/sp67-n191-2quat/image-04.png', N'Đầu cắm USB Pass-Through cắm nguồn thông minh', 4, 0),
(67, N'images/products/de-tan-nhiet/sp67-n191-2quat/image-05.jpg', N'Chân nẹp gập mở tiện lợi nâng cao góc nhìn màn hình', 5, 0),
(68, N'images/products/de-tan-nhiet/sp68-cm-ergostand-iv/main.jpg', N'Đế tản nhiệt công thái học cao cấp Cooler Master Ergostand IV', 1, 1),
(68, N'images/products/de-tan-nhiet/sp68-cm-ergostand-iv/image-02.jpg', N'Quạt lớn 140mm cánh lưỡi liềm khí động học tản nhiệt cực êm', 2, 0),
(68, N'images/products/de-tan-nhiet/sp68-cm-ergostand-iv/image-03.jpg', N'Cụm Hub mở rộng 4 cổng USB và núm chiết áp chỉnh tốc độ gió', 3, 0),
(68, N'images/products/de-tan-nhiet/sp68-cm-ergostand-iv/image-04.jpg', N'5 nấc điều chỉnh độ cao công thái học đưa màn hình ngang tầm mắt', 4, 0),
(68, N'images/products/de-tan-nhiet/sp68-cm-ergostand-iv/image-05.jpg', N'Móc đỡ laptop bọc đệm cao su dán phía trước chống trượt an toàn', 5, 0),
(69, N'images/products/de-tan-nhiet/sp69-opolar-lc05/main.jpg', N'Bộ tản nhiệt hút gió sườn laptop Opolar LC05 màn hình LED hiển thị nhiệt độ', 1, 1),
(69, N'images/products/de-tan-nhiet/sp69-opolar-lc05/image-02.jpg', N'Cơ chế hút gió chân không cưỡng bức khí nóng từ buồng heatsink ra ngoài', 2, 0),
(69, N'images/products/de-tan-nhiet/sp69-opolar-lc05/image-03.jpg', N'Màn hình số LED theo dõi trực tiếp nhiệt độ xả thải của CPU/GPU', 3, 0),
(69, N'images/products/de-tan-nhiet/sp69-opolar-lc05/image-04.jpg', N'3 đầu đệm silicon kích cỡ khác nhau ôm khít mọi loại khe tản nhiệt', 4, 0),
(69, N'images/products/de-tan-nhiet/sp69-opolar-lc05/image-05.jpg', N'Tay kẹp kim loại giữ chặt thiết bị sát sườn laptop không rơi tuột', 5, 0),
(70, N'images/products/de-tan-nhiet/sp70-havit-hvf2056/main.jpg', N'Đế tản nhiệt laptop siêu mỏng 3 quạt Havit HV-F2056', 1, 1),
(70, N'images/products/de-tan-nhiet/sp70-havit-hvf2056/image-02.jpg', N'3 quạt 110mm phân bổ đều làm mát êm ái dưới 20 dBA', 2, 0),
(70, N'images/products/de-tan-nhiet/sp70-havit-hvf2056/image-03.jpg', N'Mặt lưới kim loại đa hướng tản nhiệt diện rộng', 3, 0),
(70, N'images/products/de-tan-nhiet/sp70-havit-hvf2056/image-04.jpg', N'2 cổng cắm USB tiện lợi và công tắc nguồn phía sau', 4, 0),
(70, N'images/products/de-tan-nhiet/sp70-havit-hvf2056/image-05.jpg', N'Độ dày chỉ 2.8cm cực kỳ gọn gàng khi bỏ vào cặp sách', 5, 0);
GO
INSERT INTO ProductImages (ProductID, ImageURL, Caption, DisplayOrder, IsMain) VALUES
(71, N'images/products/loa/sp71-edifier-r1280db/main.jpg', N'Bộ loa để bàn thùng gỗ cổ điển Edifier R1280DB', 1, 1),
(71, N'images/products/loa/sp71-edifier-r1280db/image-02.jpg', N'Củ loa trầm 4 inch và củ loa cao màng lụa 13mm cao cấp', 2, 0),
(71, N'images/products/loa/sp71-edifier-r1280db/image-03.jpg', N'Cụm núm vặn điều chỉnh âm lượng, bass và treble bên hông loa chính', 3, 0),
(71, N'images/products/loa/sp71-edifier-r1280db/image-04.jpg', N'Mặt sau hỗ trợ đầy đủ cổng kết nối Optical quang học, Coaxial và RCA', 4, 0),
(71, N'images/products/loa/sp71-edifier-r1280db/image-05.jpg', N'Remote điều khiển từ xa nhỏ gọn tiện lợi chuyển bài và chỉnh âm', 5, 0),
(72, N'images/products/loa/sp72-logitech-z120/main.png', N'Bộ loa vi tính 2.0 nhỏ gọn Logitech Z120 tông màu trắng đen', 1, 1),
(72, N'images/products/loa/sp72-logitech-z120/image-02.jpg', N'Mặt trước loa phải với núm xoay chỉnh âm lượng và công tắc nguồn', 2, 0),
(72, N'images/products/loa/sp72-logitech-z120/image-03.jpg', N'Cấp nguồn trực tiếp qua cổng USB tiện lợi không cần củ sạc ngoài', 3, 0),
(72, N'images/products/loa/sp72-logitech-z120/image-04.jpg', N'Hệ thống rãnh cuộn giấu dây cáp thông minh phía sau thùng loa', 4, 0),
(72, N'images/products/loa/sp72-logitech-z120/image-05.png', N'Loa đặt cạnh laptop tạo không gian học tập làm việc gọn gàng', 5, 0),
(73, N'images/products/loa/sp73-logitech-z313/main.jpg', N'Hệ thống loa vi tính 2.1 Logitech Z313 kèm Subwoofer uy lực', 1, 1),
(73, N'images/products/loa/sp73-logitech-z313/image-02.jpg', N'Loa siêu trầm Subwoofer đánh sàn tái tạo âm bass sâu trầm nội lực', 2, 0),
(73, N'images/products/loa/sp73-logitech-z313/image-03.jpg', N'Cụm điều khiển Control Pod để bàn tích hợp cổng cắm tai nghe 3.5mm', 3, 0),
(73, N'images/products/loa/sp73-logitech-z313/image-04.jpg', N'Cặp loa vệ tinh vát góc hướng âm thanh trực tiếp đến người nghe', 4, 0),
(73, N'images/products/loa/sp73-logitech-z313/image-05.png', N'Góc setup máy tính xem phim và giải trí gaming sống động', 5, 0),
(74, N'images/products/loa/sp74-edifier-g1500-bar/main.jpg', N'Loa soundbar gaming Edifier Hecate G1500 Bar dải LED RGB', 1, 1),
(74, N'images/products/loa/sp74-edifier-g1500-bar/image-02.jpg', N'Kích thước thanh mảnh đặt vừa vặn ngay dưới gầm màn hình máy tính', 2, 0),
(74, N'images/products/loa/sp74-edifier-g1500-bar/image-03.png', N'Hệ thống 2 củ loa toàn dải và màng rung kép tái tạo âm thanh vòm 7.1', 3, 0),
(74, N'images/products/loa/sp74-edifier-g1500-bar/image-04.jpg', N'Nút bấm điều khiển chế độ Game, Movie, Music và đổi hiệu ứng LED', 4, 0),
(74, N'images/products/loa/sp74-edifier-g1500-bar/image-05.jpg', N'Tích hợp micro đàm thoại khử ồn trò chuyện trực tiếp cùng đồng đội', 5, 0),
(75, N'images/products/loa/sp75-edifier-r1700bt/main.jpg', N'Bộ loa để bàn Hi-Fi Edifier R1700BT ốp gỗ óc chó sang trọng', 1, 1),
(75, N'images/products/loa/sp75-edifier-r1700bt/image-02.jpg', N'Thiết kế vát nghiêng 10 độ hướng âm thanh trực tiếp vào tai', 2, 0),
(75, N'images/products/loa/sp75-edifier-r1700bt/image-03.jpg', N'Củ loa cao màng lụa Eagle Eye 19mm và củ loa trầm 4 inch', 3, 0),
(75, N'images/products/loa/sp75-edifier-r1700bt/image-04.jpg', N'Cụm núm xoay kim loại chỉnh Bass, Treble và Volume bên hông', 4, 0),
(75, N'images/products/loa/sp75-edifier-r1700bt/image-05.jpg', N'Remote điều khiển từ xa cao cấp chuyển bài và tắt mở tiếng', 5, 0),
(76, N'images/products/loa/sp76-creative-pebble-v3/main.png', N'Bộ loa để bàn Creative Pebble V3 thiết kế viên sỏi góc 45 độ', 1, 1),
(76, N'images/products/loa/sp76-creative-pebble-v3/image-02.png', N'Củ loa lớn 2.25 inch cho công suất cực đại 16W Peak mạnh mẽ', 2, 0),
(76, N'images/products/loa/sp76-creative-pebble-v3/image-03.jpg', N'Màng rung thụ động Passive Radiator tăng độ sâu âm trầm phía sau', 3, 0),
(76, N'images/products/loa/sp76-creative-pebble-v3/image-04.jpg', N'Cổng cắm USB-C truyền cả nguồn và âm thanh số qua 1 sợi cáp duy nhất', 4, 0),
(76, N'images/products/loa/sp76-creative-pebble-v3/image-05.jpg', N'Nút chuyển đổi nhanh kết nối Bluetooth 5.0 không dây cho điện thoại', 5, 0),
(77, N'images/products/loa/sp77-microlab-m108/main.jpg', N'Bộ loa vi tính 2.1 Microlab M-108 bền bỉ giá bình dân', 1, 1),
(77, N'images/products/loa/sp77-microlab-m108/image-02.jpg', N'Thùng loa siêu trầm Subwoofer gỗ MDF với lỗ thông hơi bass reflex', 2, 0),
(77, N'images/products/loa/sp77-microlab-m108/image-03.jpg', N'Núm vặn âm lượng mặt trước và nút chỉnh Bass mặt sau thùng sub', 3, 0),
(77, N'images/products/loa/sp77-microlab-m108/image-04.jpg', N'Cặp loa vệ tinh góc nghiêng thanh thoát trên bàn học', 4, 0),
(77, N'images/products/loa/sp77-microlab-m108/image-05.jpg', N'Kết nối dễ dàng máy tính qua cổng jack 3.5mm analog', 5, 0),
(78, N'images/products/loa/sp78-dell-sb521a/main.jpg', N'Loa soundbar siêu mỏng Dell Slim Soundbar SB521A', 1, 1),
(78, N'images/products/loa/sp78-dell-sb521a/image-02.png', N'Cơ chế hít nam châm từ tính snap-on gắn dưới đáy màn hình Dell', 2, 0),
(78, N'images/products/loa/sp78-dell-sb521a/image-03.jpg', N'Tiết kiệm 100% diện tích mặt bàn làm việc tối giản', 3, 0),
(78, N'images/products/loa/sp78-dell-sb521a/image-04.jpg', N'Cáp USB cắm trực tiếp vào cổng hub sau màn hình Dell', 4, 0),
(78, N'images/products/loa/sp78-dell-sb521a/image-05.png', N'Núm xoay âm lượng cơ học tích hợp đèn LED bên cạnh phải', 5, 0),
(79, N'images/products/loa/sp79-razer-nommo-v2x/main.png', N'Bộ loa gaming cao cấp Razer Nommo V2 X hình trụ tròn độc đáo', 1, 1),
(79, N'images/products/loa/sp79-razer-nommo-v2x/image-02.jpg', N'Củ loa màng nhôm 3.2 inch mang lại âm lượng uy lực tới 96dB', 2, 0),
(79, N'images/products/loa/sp79-razer-nommo-v2x/image-03.jpg', N'Ống thoát âm bass phản xạ phía sau cho âm trầm sâu lắng', 3, 0),
(79, N'images/products/loa/sp79-razer-nommo-v2x/image-04.jpg', N'Công nghệ âm thanh không gian THX Spatial Audio chuẩn điện ảnh', 4, 0),
(79, N'images/products/loa/sp79-razer-nommo-v2x/image-05.jpg', N'Cụm phím điều khiển cao su êm ái trên đỉnh loa phải', 5, 0),
(80, N'images/products/loa/sp80-jbl-go-3/main.jpg', N'Loa Bluetooth di động JBL GO 3 thiết kế thể thao nhỏ gọn', 1, 1),
(80, N'images/products/loa/sp80-jbl-go-3/image-02.jpg', N'Chuẩn kháng nước kháng bụi IP67 an toàn trong mọi môi trường', 2, 0),
(80, N'images/products/loa/sp80-jbl-go-3/image-03.jpg', N'Quai xỏ ngón tay tiện lợi móc vào balo khi dã ngoại', 3, 0),
(80, N'images/products/loa/sp80-jbl-go-3/image-04.jpg', N'Mặt đáy bọc vân cao su chống trượt khi đặt trên mặt bàn', 4, 0),
(80, N'images/products/loa/sp80-jbl-go-3/image-05.jpg', N'Cổng sạc Type-C chống nước không cần nắp đậy bảo vệ', 5, 0);
GO
INSERT INTO ProductImages (ProductID, ImageURL, Caption, DisplayOrder, IsMain) VALUES
(81, N'images/products/thiet-bi-luu-tru/sp81-kingston-xs1000/main.jpg', N'Ổ cứng SSD di động Kingston XS1000 1TB siêu nhỏ gọn', 1, 1),
(81, N'images/products/thiet-bi-luu-tru/sp81-kingston-xs1000/image-02.jpg', N'Kích thước nhỏ hơn nửa chiếc thẻ ATM chỉ nặng 28.7g', 2, 0),
(81, N'images/products/thiet-bi-luu-tru/sp81-kingston-xs1000/image-03.jpg', N'Cổng cắm USB-C tốc độ cao 1050MB/s', 3, 0),
(81, N'images/products/thiet-bi-luu-tru/sp81-kingston-xs1000/image-04.png', N'Vỏ kim loại đen lì sang trọng chống trầy xước', 4, 0),
(81, N'images/products/thiet-bi-luu-tru/sp81-kingston-xs1000/image-05.jpg', N'Đèn LED báo trạng thái đọc ghi dữ liệu nhỏ gọn tinh tế', 5, 0),
(82, N'images/products/thiet-bi-luu-tru/sp82-samsung-t7-shield/main.jpg', N'Ổ cứng SSD di động chống nước va đập Samsung T7 Shield 1TB', 1, 1),
(82, N'images/products/thiet-bi-luu-tru/sp82-samsung-t7-shield/image-02.jpg', N'Lớp vỏ bọc cao su Elastomer chịu rơi từ độ cao 3 mét', 2, 0),
(82, N'images/products/thiet-bi-luu-tru/sp82-samsung-t7-shield/image-03.jpg', N'Chuẩn kháng nước và kháng bụi IP65 an toàn ngoài trời', 3, 0),
(82, N'images/products/thiet-bi-luu-tru/sp82-samsung-t7-shield/image-04.jpg', N'Cổng Type-C tốc độ 1050MB/s kèm 2 sợi cáp chính hãng', 4, 0),
(82, N'images/products/thiet-bi-luu-tru/sp82-samsung-t7-shield/image-05.jpg', N'Công nghệ tản nhiệt Dynamic Thermal Guard giữ tốc độ ổn định', 5, 0),
(83, N'images/products/thiet-bi-luu-tru/sp83-wd-elements-1tb/main.jpg', N'Ổ cứng di động HDD 2.5 inch WD Elements 1TB chính diện', 1, 1),
(83, N'images/products/thiet-bi-luu-tru/sp83-wd-elements-1tb/image-02.png', N'Kích thước nhỏ gọn cầm vừa vặn trong lòng bàn tay', 2, 0),
(83, N'images/products/thiet-bi-luu-tru/sp83-wd-elements-1tb/image-03.jpg', N'Cổng cắm USB 3.0 Micro-B truyền dữ liệu nhanh chóng', 3, 0),
(83, N'images/products/thiet-bi-luu-tru/sp83-wd-elements-1tb/image-04.jpg', N'Vỏ nhựa đen mờ cao cấp chống bám vân tay và mồ hôi', 4, 0),
(83, N'images/products/thiet-bi-luu-tru/sp83-wd-elements-1tb/image-05.jpg', N'Đèn LED trắng báo trạng thái đọc ghi dữ liệu nhấp nháy êm ái', 5, 0),
(84, N'images/products/thiet-bi-luu-tru/sp84-kingston-exodia-m/main.jpg', N'USB 3.2 Kingston DataTraveler Exodia M 64GB nắp trượt', 1, 1),
(84, N'images/products/thiet-bi-luu-tru/sp84-kingston-exodia-m/image-02.jpg', N'Cơ chế trượt ngón tay bảo vệ chân cắm USB không lo mất nắp', 2, 0),
(84, N'images/products/thiet-bi-luu-tru/sp84-kingston-exodia-m/image-03.jpg', N'Vòng khuyên đuôi USB tiện lợi móc vào chùm chìa khóa', 3, 0),
(84, N'images/products/thiet-bi-luu-tru/sp84-kingston-exodia-m/image-04.jpg', N'Chân cắm USB 3.2 kim loại sáng bóng truyền dữ liệu nhanh', 4, 0),
(84, N'images/products/thiet-bi-luu-tru/sp84-kingston-exodia-m/image-05.jpg', N'Phối màu thời trang phong cách trẻ trung năng động', 5, 0),
(85, N'images/products/thiet-bi-luu-tru/sp85-sandisk-cz73-flair/main.png', N'USB kim loại sang trọng SanDisk Ultra Flair CZ73 64GB', 1, 1),
(85, N'images/products/thiet-bi-luu-tru/sp85-sandisk-cz73-flair/image-02.jpg', N'Vỏ hợp kim nhôm phay xước siêu bền chống va đập rơi rớt', 2, 0),
(85, N'images/products/thiet-bi-luu-tru/sp85-sandisk-cz73-flair/image-03.jpg', N'Tốc độ đọc dữ liệu lên tới 150MB/s sao chép phim ảnh trong tích tắc', 3, 0),
(85, N'images/products/thiet-bi-luu-tru/sp85-sandisk-cz73-flair/image-04.jpg', N'Thiết kế siêu mỏng nhẹ thanh mảnh chỉ 4.5g', 4, 0),
(85, N'images/products/thiet-bi-luu-tru/sp85-sandisk-cz73-flair/image-05.jpg', N'Lỗ xỏ dây đeo tích hợp gắn chìa khóa xe máy tiện lợi', 5, 0),
(86, N'images/products/thiet-bi-luu-tru/sp86-sandisk-extreme-pro-128gb/main.jpg', N'Thẻ nhớ cao cấp SanDisk Extreme Pro 128GB tốc độ 200MB/s', 1, 1),
(86, N'images/products/thiet-bi-luu-tru/sp86-sandisk-extreme-pro-128gb/image-02.png', N'Chuẩn V30 và U3 chuyên dụng quay phim 4K UHD không giật lag', 2, 0),
(86, N'images/products/thiet-bi-luu-tru/sp86-sandisk-extreme-pro-128gb/image-03.jpg', N'Chuẩn hiệu năng ứng dụng A2 tải game siêu tốc trên Nintendo Switch', 3, 0),
(86, N'images/products/thiet-bi-luu-tru/sp86-sandisk-extreme-pro-128gb/image-04.jpg', N'Kèm Adapter chuyển sang thẻ SD lớn dùng cho máy ảnh DSLR', 4, 0),
(86, N'images/products/thiet-bi-luu-tru/sp86-sandisk-extreme-pro-128gb/image-05.jpg', N'Độ bền đạt chuẩn chống nước, chống sốc và chống tia X sân bay', 5, 0),
(87, N'images/products/thiet-bi-luu-tru/sp87-kingston-canvas-select-64gb/main.jpg', N'Thẻ nhớ MicroSD Kingston Canvas Select Plus 64GB chính hãng', 1, 1),
(87, N'images/products/thiet-bi-luu-tru/sp87-kingston-canvas-select-64gb/image-02.jpg', N'Chuẩn Class 10 UHS-I tốc độ đọc 100MB/s nhanh chóng', 2, 0),
(87, N'images/products/thiet-bi-luu-tru/sp87-kingston-canvas-select-64gb/image-03.png', N'Lựa chọn số 1 cho camera an ninh giám sát ghi hình 24/7', 3, 0),
(87, N'images/products/thiet-bi-luu-tru/sp87-kingston-canvas-select-64gb/image-04.png', N'Chuẩn A1 tối ưu hóa hiệu năng ứng dụng trên smartphone', 4, 0),
(87, N'images/products/thiet-bi-luu-tru/sp87-kingston-canvas-select-64gb/image-05.png', N'Kèm khay Adapter SD cắm khe đọc thẻ nhớ máy tính', 5, 0),
(88, N'images/products/thiet-bi-luu-tru/sp88-orico-pwm2-nvme/main.jpg', N'Hộp đựng ổ cứng di động Box SSD M.2 Orico PWM2 tốc độ 10Gbps', 1, 1),
(88, N'images/products/thiet-bi-luu-tru/sp88-orico-pwm2-nvme/image-02.jpg', N'Hỗ trợ chuẩn kép M.2 NVMe và M.2 SATA dung lượng tối đa 4TB', 2, 0),
(88, N'images/products/thiet-bi-luu-tru/sp88-orico-pwm2-nvme/image-03.jpg', N'Cơ chế lắp ráp thông minh Tool-free không cần dùng ốc vít', 3, 0),
(88, N'images/products/thiet-bi-luu-tru/sp88-orico-pwm2-nvme/image-04.jpg', N'Vỏ hợp kim nhôm có rãnh tản nhiệt kết hợp đệm tản nhiệt Thermal Pad', 4, 0),
(88, N'images/products/thiet-bi-luu-tru/sp88-orico-pwm2-nvme/image-05.jpg', N'Cáp kết nối Type-C đa năng 10Gbps truyền file 1GB trong 1 giây', 5, 0),
(89, N'images/products/thiet-bi-luu-tru/sp89-sandisk-extreme-e61/main.jpg', N'Ổ cứng SSD di động siêu bền SanDisk Extreme Portable SSD 1TB V2 E61', 1, 1),
(89, N'images/products/thiet-bi-luu-tru/sp89-sandisk-extreme-e61/image-02.jpg', N'Móc khuyên treo màu cam đặc trưng dễ dàng móc vào balo leo núi', 2, 0),
(89, N'images/products/thiet-bi-luu-tru/sp89-sandisk-extreme-e61/image-03.jpg', N'Tốc độ đọc ghi NVMe 1050MB/s chỉnh sửa video 4K trực tiếp mượt mà', 3, 0),
(89, N'images/products/thiet-bi-luu-tru/sp89-sandisk-extreme-e61/image-04.jpg', N'Vỏ bọc cao su silicon chống nước bụi IP65 và chống rơi 3 mét', 4, 0),
(89, N'images/products/thiet-bi-luu-tru/sp89-sandisk-extreme-e61/image-05.jpg', N'Kích thước siêu mỏng nhẹ chỉ nặng 52g bỏ túi quần tiện lợi', 5, 0),
(90, N'images/products/thiet-bi-luu-tru/sp90-sandisk-dual-drive-go/main.jpg', N'USB 2 đầu cắm Type-C và Type-A SanDisk Ultra Dual Drive Go 128GB', 1, 1),
(90, N'images/products/thiet-bi-luu-tru/sp90-sandisk-dual-drive-go/image-02.jpg', N'Thiết kế nắp xoay kim loại 360 độ bảo vệ cả hai đầu cắm', 2, 0),
(90, N'images/products/thiet-bi-luu-tru/sp90-sandisk-dual-drive-go/image-03.jpg', N'Giải phóng bộ nhớ điện thoại iPhone và Android tức thì trong tích tắc', 3, 0),
(90, N'images/products/thiet-bi-luu-tru/sp90-sandisk-dual-drive-go/image-04.jpg', N'Tốc độ đọc dữ liệu cực nhanh lên tới 400MB/s', 4, 0),
(90, N'images/products/thiet-bi-luu-tru/sp90-sandisk-dual-drive-go/image-05.png', N'Kích thước siêu nhỏ gọn chỉ nặng 3.7g gắn vừa chùm chìa khóa', 5, 0);
GO

PRINT N'=========================================================';
PRINT N'HOAN THANH CAP NHAT TOAN BO 90 SAN PHAM VA BANG HINH ANH!';
PRINT N'=========================================================';
GO
