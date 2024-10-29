USE MinhCosmetics;
-- 4 VIEWS
-- Tạo Views hiển thị mã hàng, tên hàng và tên nhà cung cấp trong 2 bảng MATHANG và NHACUNGCAP
USE MinhCosmetics;
CREATE VIEW View_MatHang AS
SELECT PN.MaHang AS N'Mã hàng', MH.TenHang AS N'Tên hàng', NCC.TenNCC AS N'Tên nhà cung cấp'
FROM dbo.MATHANG AS MH, PHIEUNHAP AS PN, dbo.NHACUNGCAP AS NCC
WHERE MH.MaHang = PN.MaHang AND NCC.MaNCC = PN.MaNCC
GO

SELECT * FROM View_MatHang

-- Tạo Views hiển thị mã nhân viên, tên nhân viên, nhân viên đó làm ở cơ sở nào
CREATE VIEW CoSo_NV AS
SELECT NV.MaNV AS N'Mã nhân viên', NV.HoTen AS N'Họ tên nhân viên', CS.DiaChiCS AS N'Địa chỉ cơ sở'
FROM NHANVIEN AS NV, COSO AS CS
WHERE NV.MaCS = CS.MaCS
GO

SELECT * FROM CoSo_NV

-- Hiển thị mã khách hàng, tên khách hàng, chương trình khuyến mãi khách hàng có thể sử dụng.
CREATE VIEW KH_KM AS
SELECT UD.MaKH AS N'Mã khách hàng', KH.HoTen AS N'Họ tên khách hàng', KM.NoiDungCT AS N'Nội dung chương trình khuyến mãi'
FROM KHACHHANG AS KH, KHUYENMAI AS KM, UUDAI AS UD
WHERE KH.MaKH = UD.MaKH AND KM.MaKM = UD.MaKM
GO

SELECT * FROM KH_KM

--  Tạo Views xem khách hàng nào đã sử dụng mặt hàng của nhà cung cấp nào
CREATE VIEW KH_USE AS
SELECT KH.HoTen AS N'Họ tên khách hàng', KH.SDT AS N'SĐT', 
MH.TenHang AS N'Tên mặt hàng đã mua', NCC.TenNCC AS N'Tên nhà cung cấp của mặt hàng'
FROM KHACHHANG AS KH, MATHANG AS MH, NHACUNGCAP AS NCC, HOADON, CTHD, PHIEUNHAP
WHERE KH.MaKH = HOADON.MaKH AND HOADON.SoHD = CTHD.SoHD AND CTHD.MaHang = MH.MaHang 
AND PHIEUNHAP.MaHang = MH.MaHang AND NCC.MaNCC = PHIEUNHAP.MaNCC

SELECT * FROM KH_USE
--xóa bảng ảo view
DROP VIEW IF EXISTS KH_USE;
--5 STORED PROCEDURE
-- In thông tin của khách hàng dựa trên số hóa đơn.
USE MinhCosmetics;
CREATE PROCEDURE DSKH (@SoHD int)
AS
BEGIN
	SELECT *
	FROM KHACHHANG
	JOIN HOADON ON KHACHHANG.MaKH = HOADON.MaKH
	WHERE SoHD = @SoHD
END
GO
-- In thông tin của khách hàng dựa trên số hóa đơn.
EXEC DSKH '6'

-- Thêm 1 khách hàng vào bảng KHACHHANG
CREATE PROCEDURE ADD_KH 
	@MaKH INT,
	@HoTen NVARCHAR(50),
	@GioiTinh NVARCHAR(5),
	@DiaChi NVARCHAR(100),
	@SDT NVARCHAR(12),
	@NgaySinh DATE,
	@NgayDK DATE AS
BEGIN
	INSERT INTO KHACHHANG(MaKH, HoTen, GioiTinh, DiaChi, SDT, NgaySinh, NgayDK)
	VALUES (@MaKH, @HoTen, @GioiTinh, @DiaChi, @SDT, @NgaySinh, @NgayDK)
END
GO
--Thêm khách hàng vào bảng KHACHHANG
EXEC ADD_KH '11', N'Phan Thị Diệu Lan', N'Nữ', N'16/11 Phan Chu Trinh', '0128711829', '1999-11-12', '2023-03-01'
EXEC ADD_KH '12', N'Đinh Thị Lệ Quyên', N'Nữ', N'120 Lâm Hoằng', '0911820911', '2004-05-16', '2023-03-01'

-- Sửa thông tin của 1 khách hàng trong bảng KHACHHANG
CREATE PROCEDURE UPDATE_KH 
	@MaKH INT,
	@HoTen NVARCHAR(50),
	@GioiTinh NVARCHAR(5),
	@DiaChi NVARCHAR(100),
	@SDT NVARCHAR(12),
	@NgaySinh DATE,
	@NgayDK DATE AS
BEGIN
	UPDATE dbo.KHACHHANG
	SET HoTen = @HoTen, 
		GioiTinh = @GioiTinh,
		DiaChi = @DiaChi,
		SDT = @SDT,
		NgaySinh = @NgaySinh,
		NgayDK = @NgayDK
	WHERE MaKH =@MaKH
END
GO
-- Update thông tin của 1 khách hàng trong bảng KHACHANG
EXEC UPDATE_KH '11', N'Phan Thị Diệu Lan', N'Nữ', N'16/11 Phan Chu Trinh', '0128711829', '1999-11-20', '2023-03-01'
select * from khachhang


-- Xóa 1 khách hàng trong bảng KHACHHANG.
CREATE PROCEDURE DELETE_KH 
	@MaKH INT
AS
BEGIN
	BEGIN TRANSACTION
	--Xóa thông tin khách hàng trong bảng KHACHHANG
	DELETE FROM KHACHHANG WHERE MaKH = @MaKH
	--Xóa thông tin khuyến mãi của khách hàng trong bảng KHUYENMAI
	DELETE FROM KHUYENMAI WHERE MaKM IN (SELECT MaKM FROM UUDAI WHERE MaKH = @MaKH)
	COMMIT TRANSACTION
END
GO

-- Xóa thông tin của khách hàng ra khỏi các bảng có mối quan hệ với bảng KH
EXEC DELETE_KH @MaKH ='11'

-- Xem điểm tích lũy của 1 khách hàng từ cao đến thấp
CREATE PROCEDURE ORDER_DiemTichLuy
AS
BEGIN
	SELECT TTV.MaKH, KH.HoTen, TTV.DiemTichLuy
	FROM THETHANHVIEN AS TTV, KHACHHANG AS KH
	WHERE TTV.MaKH = KH.MaKH
ORDER BY DiemTichLuy DESC -- Giảm dần
END

EXEC dbo.ORDER_DiemTichLuy

-- Lấy danh sách với thông tin chi tiết tất cả các nhân viên làm việc theo ca.
CREATE PROCEDURE DSNV(@CaLam nvarchar(20))
AS
BEGIN
SELECT *
FROM NHANVIEN
WHERE CaLam = @CaLam
END;
-- Lấy danh sách với thông tin chi tiết tất cả các nhân viên làm việc theo ca.
EXEC DSNV N'Tối'

-- In Hạng thành viên (Đồng, Bạc, Vàng) của 1 khách hàng quy đổi từ điểm tích lũy ở thẻ thành viên.
--VD: Điểm tích lũy của 1 khách hàng là 3 thì đổi qua Hạng thành viên là Đồng
CREATE PROCEDURE KT_HangTV (@MaKH INT, @HangTV NVARCHAR(50) OUTPUT)
AS
BEGIN
	DECLARE @p float
	SELECT @p = DiemTichLuy 
	FROM dbo.THETHANHVIEN 
	where MaKH = @MaKH
	IF @p > 0 AND @p <= 4
		SET @HangTV =N'Đồng'
	ELSE IF
		@p >= 5 AND @p <= 10 
			SET @HangTV = N'Bạc'
	ELSE IF
		@p >= 11 
			SET @HangTV = N'Vàng'
END
GO

-- Kiểm tra
DECLARE @Hang NVARCHAR(50);
EXEC KT_HangTV '4', @HangTV = @Hang OUTPUT; 
SELECT @Hang AS N'Hạng thành viên';


-- 4 CHECK
-- Nhiệm vụ: Ràng buộc phải nhập đúng số điện thoại, bảng KHACHHANG và NHANVIEN
ALTER TABLE KHACHHANG ADD CONSTRAINT SDTKH
CHECK (SDT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]');
ALTER TABLE NHANVIEN ADD CONSTRAINT SDTNV
CHECK (SDT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]');

-- Chỉnh sửa bảng KHUYENMAI và sử dụng CHECK và CONSTRAINT để tạo điều kiện cho trường ThoiGianKT luôn ≥ ThoiGianBD 
-- hoặc ThoiGianKT nhận giá trị là NULL
ALTER TABLE KHUYENMAI ADD CONSTRAINT CK_ThoiGian
CHECK (ThoiGianKT >= ThoiGianBD OR ThoiGianKT IS NULL)

-- Chỉnh sửa bảng CTHD và sử dụng CHECK và CONSTRAINT để tạo điều kiện cho trường SoLuong luôn ≥ 1
ALTER TABLE CTHD ADD CONSTRAINT CK_SoLuong
CHECK (SoLuong >= 1)

-- Chỉnh sửa bảng NHANVIEN và sử dụng CHECK và CONSTRAINT để tạo điều kiện cho trường Luong luôn ≥ 1000000 và <= 3000000
ALTER TABLE NHANVIEN ADD CONSTRAINT CK_Luong
CHECK (Luong >= 1000000 AND Luong <= 3000000)



-- 5 TRIGGER
-- 3. Tạo Trigger để tính trị giá của 1 hóa đơn, 
-- trigger này sẽ tự động cập nhật trị giá của hóa đơn đến thời điểm hiện tại dựa vào số lượng và đơn giá mặt hàng đã mua (dữ liệu ở bảng CTHD).
CREATE TRIGGER InsertTriGia
ON CTHD
FOR INSERT
AS
BEGIN 
	DECLARE @TriGia NVARCHAR(20)
	DECLARE @SoHD INT
	SELECT @SoHD = SoHD
	FROM inserted
	SELECT @TriGia = SUM(SoLuong * DonGia)
	FROM CTHD
	WHERE SoHD = @SoHD
	UPDATE HOADON
	SET TriGia = @TriGia
	WHERE SoHD = @SoHD
END
GO

-- Tạo bảng mới để lưu trữ thay đổi trong bảng khách hàng (bảng này nên đặt là KH_Audit).
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[KH_Audit]
(
	[MaKH] [int] NOT NULL,
	[HoTen] [nvarchar](50) NOT NULL,
	[GioiTinh] [nvarchar](50) NULL,
	[DiaChi] [nvarchar](100) NULL,
	[SDT] [nvarchar](12)NULL,
	[NgaySinh] [date] NULL,
	[NgayDK] [date] NULL,
	[ThaoTac] [nvarchar](50) NOT NULL,
	[NgayThayDoi] datetime NOT NULL,
	CONSTRAINT[PK_KH_Audit] 
	PRIMARY KEY CLUSTERED
	(
		[MaKH] 
	) 
	WITH 
	(
		PAD_INDEX = OFF,
		STATISTICS_NORECOMPUTE = OFF,
		IGNORE_DUP_KEY = OFF,
		ALLOW_ROW_LOCKS = ON,
		ALLOW_PAGE_LOCKS = ON,
		OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
	)
		ON[PRIMARY]
)
		ON[PRIMARY]
GO

--Tạo Trigger để lưu trữ thông tin KH vào bảng KH_audit sau khi sửa thông tin 1 KH
CREATE TRIGGER UpdateKH 
ON KHACHHANG 
FOR UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO KH_Audit
	(
		MaKH,
		HoTen,
		GioiTinh,
		DiaChi,
		SDT,
		NgaySinh,
		NgayDK,
		ThaoTac,
		NgayThayDoi
	)
	SELECT
		MaKH = d.MaKH,
		HoTen = d.HoTen,
		GioiTinh = d.GioiTinh,
		DiaChi = d.DiaChi,
		SDT = d.SDT,
		NgaySinh = d.NgaySinh,
		NgayDK = d.NgayDK,
		ThaoTac ='Update',
		NgayThayDoi = GETDATE()
	FROM deleted AS d
END
GO
-- Update
UPDATE KHACHHANG 
SET DiaChi = N'85 An D??ng V??ng', SDT = '0365172279' WHERE MaKH ='5';
GO

--Tạo Trigger để lưu trữ thông tin khách hàng vào bảng KH_audit sau khi xóa thông tin 1 khách hàng.
CREATE TRIGGER DeleteKH 
ON KHACHHANG 
FOR DELETE
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO KH_Audit
	(
		MaKH,
		HoTen,
		GioiTinh,
		DiaChi,
		SDT,
		NgaySinh,
		NgayDK,
		ThaoTac,
		NgayThayDoi
	)
	SELECT
		MaKH = d.MaKH,
		HoTen = d.HoTen,
		GioiTinh = d.GioiTinh,
		DiaChi = d.DiaChi,
		SDT = d.SDT,
		NgaySinh = d.NgaySinh,
		NgayDK = d.NgayDK,
		ThaoTac ='Delete',
		NgayThayDoi = GETDATE()
	FROM deleted AS d
END
GO
-- DELETE
DELETE FROM KHACHHANG 
WHERE MaKH = '13'
GO

-- Tạo Trigger để tính  điểm tích lũy của khách hàng, trigger này sẽ 
-- tự động cập nhật điểm tích lũy của khách hàng đến thời điểm hiện tại dựa vào trị giá của hóa đơn đã mua (dữ liệu ở bảng HOADON).
CREATE TRIGGER update_DTL
ON HOADON
AFTER INSERT
AS
BEGIN
  DECLARE @Diem INT;
  -- Tính điểm tích lũy dựa vào trị giá của hóa đơn
  IF (SELECT TriGia FROM inserted) > 100000 AND (SELECT TriGia FROM inserted) <= 200000
    SET @Diem = 1;
  ELSE IF (SELECT TriGia FROM inserted) > 200000 AND (SELECT TriGia FROM inserted) <= 300000
    SET @Diem = 2;
  -- Điều kiện cho các trường hợp khác
  ELSE IF (SELECT TriGia FROM inserted) > 300000 AND (SELECT TriGia FROM inserted) <= 400000
    SET @Diem = 3;
		ELSE IF (SELECT TriGia FROM inserted) > 400000 AND (SELECT TriGia FROM inserted) <= 500000
    SET @Diem = 4;
	 ELSE IF (SELECT TriGia FROM inserted) > 500000 AND (SELECT TriGia FROM inserted) <= 600000
    SET @Diem = 5;
	 ELSE IF (SELECT TriGia FROM inserted) > 600000 AND (SELECT TriGia FROM inserted) <= 700000
    SET @Diem = 6;
	 ELSE IF (SELECT TriGia FROM inserted) > 700000 AND (SELECT TriGia FROM inserted) <= 800000
    SET @Diem = 7;
  ELSE
    SET @Diem = 0;

  -- Cập nhật điểm tích lũy cho khách hàng
  UPDATE THETHANHVIEN
  SET DiemTichLuy = DiemTichLuy + @Diem
  WHERE MaKH IN (SELECT MaKH FROM inserted);
END;

-- Tạo Trigger không cho phép xóa thông tin của khách hàng nhỏ hơn 1 tuổi.
CREATE TRIGGER KHTuoi
ON dbo.KHACHHANG
FOR DELETE
AS
BEGIN
	DECLARE @Count INT = 0
	SELECT @Count = Count(*) FROM deleted
	WHERE YEAR(GETDATE()) - YEAR(deleted.NgaySinh) < 1
	IF (@Count > 0)
	BEGIN
	PRINT N'Không được xóa khách hàng dưới 1 tuổi'
		ROLLBACK TRAN
	END
END

DELETE FROM dbo.KHACHHANG WHERE MaKH = '13'

--3 FUNCTION
 -- Tạo Function để in ra thông tin mặt hàng có giá cao nhất của 1 nhà cung cấp (đầu vào là Mã nhà cung cấp).
USE MinhCosmetics;
CREATE FUNCTION Max_SP(@MaNCC nvarchar(6))
RETURNS TABLE AS 
	RETURN
		SELECT TOP 1 PN.MaHang, MH.TenHang, MH.NuocSX, NCC.TenNCC
		FROM MATHANG AS MH, PHIEUNHAP AS PN, NHACUNGCAP AS NCC
		WHERE PN.MaNCC = @MaNCC AND MH.MaHang = PN.MaHang AND PN.MaNCC = NCC.MaNCC
		ORDER BY Gia DESC
GO
		
--Truy vấn
Select * From Max_SP(N'NCC01')
DROP FUNCTION Max_SP

--Tạo Function để in ra danh sách các nhân viên là quản lí của 1 ca làm (đầu vào sẽ là ca làm)
CREATE FUNCTION QL_NV (@CaLam NVARCHAR(20))
RETURNS TABLE AS 
RETURN 
	SELECT NV.MaNV, NV.HoTen, NV.GioiTinh, NV.NgayVaoLam, NV.NgayBatDauQL, NV.SDT
	FROM NHANVIEN AS NV
	WHERE NV.CaLam = @CaLam AND NV.ChucVu = N'Quản lý' 
-- Truy vấn
SELECT * FROM QL_NV (N'Sáng')

-- Tạo Function để in ra thông tin của nhân viên đạt mức lương cao nhất của 1 ca làm (đầu vào sẽ là ca làm).
CREATE FUNCTION Max_Luong (@CaLam nvarchar(20))
RETURNS TABLE AS
RETURN
SELECT NV.MaNV, NV.HoTen, NV.SDT, NV.ChucVu, NV.Luong
FROM NHANVIEN AS NV
WHERE NV.CaLam = @CaLam AND NV.Luong = (SELECT MAX(Luong) FROM NHANVIEN WHERE CaLam = @CaLam)

--Truy vấn
SELECT * FROM Max_Luong(N'Tối')