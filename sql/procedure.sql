USE HQT_CSDL
GO

--KIEM TRA MOT SO DIEN THOAI CO TON TAI TRONG NGUOI DUNG HAY CHUA
CREATE PROCEDURE sp_KiemTraSdtTonTai
				@SDT VARCHAR(20)
AS
BEGIN
	DECLARE @Exist BIT

	SELECT @Exist = CASE 
						WHEN EXISTS(SELECT 1 FROM NGUOIDUNG WHERE SDT = @SDT) THEN 1
						ELSE 0
					END
	RETURN @Exist
END;
GO

DECLARE @TEST BIT
EXEC @TEST = sp_KiemTraSdtTonTai '110'
PRINT @TEST
GO


-- KIEM TRA TAI KHOAN DA TON TAI HAY CHUA
CREATE PROCEDURE sp_KiemTraTKTonTai
				@SDT varchar(20),
				@LoaiND varchar(10)
AS
BEGIN
	DECLARE @isTKExist BIT = CASE 
							WHEN EXISTS (SELECT 1 FROM TAIKHOAN WHERE SDT = @SDT AND @LoaiND = LoaiND) THEN 1
							ELSE 0
							END
	RETURN @isTKExist
END;
GO

DECLARE @TEST BIT
EXEC @TEST = sp_KiemTraTKTonTai '123', 'Admin'
PRINT @TEST
GO




--LAY THONG TIN NGUOI DUNG TU MOT SO DIEN THOAI
CREATE PROCEDURE sp_LayThongTinTuSDT 
				@SDT VARCHAR(20)
AS
BEGIN
	DECLARE @Exist BIT
	EXEC @Exist = sp_KiemTraSdtTonTai @SDT
	IF @Exist = 1
	BEGIN 
		SELECT HoTen,NgaySinh,DiaChi FROM NGUOIDUNG WHERE SDT = @SDT
	END

	ELSE
	BEGIN
		SELECT 0 AS Result
	END
END;
GO

EXEC sp_LayThongTinTuSDT '000';
GO



--LAY THONG TIN HOA DON TU MOT SO DIEN THOAI
CREATE PROCEDURE sp_LayHoaDonTuSDT
				@SDT VARCHAR(20)
AS
BEGIN 
	DECLARE @Exist BIT

	SELECT @Exist = CASE 
						WHEN EXISTS(SELECT 1 FROM HOSOBENHAN WHERE SDT = @SDT) THEN 1
						ELSE 0
					END

	IF @Exist = 1
	BEGIN
		SELECT HSBA.MaHoSo AS MaHoaDon, CONVERT(date,HSBA.NgayKham) as NgayKham, HSBA.MaNhaSi, NS.HoTen as TenNhaSi,
			   DT.MaThuoc, T.TenThuoc, DT.SoLuong as SoLuongThuoc, DT.DonGia, 
			   DDV.MaDV, DV.TenDV, 1 AS SoLuongDV, DDV.DonGia, HSBA.TongTien AS TongTien
		FROM HOSOBENHAN HSBA JOIN DONTHUOC DT on HSBA.MaHoSo = DT.MaDonThuoc 
							 JOIN DONDICHVU DDV ON HSBA.MaHoSo = DDV.MaDonDV
							 JOIN NGUOIDUNG NS ON HSBA.MaNhaSi = NS.SDT
							 JOIN THUOC T ON T.MaThuoc = DT.MaThuoc
							 JOIN DICHVU DV ON DV.MaDV = DDV.MaDV
	    WHERE HSBA.SDT = @SDT
	END
	ELSE
	BEGIN
		SELECT 0 AS Result
	END
END;
Go

EXEC sp_LayHoaDonTuSDT '123'
GO



--TIM BAC SI RANH TRONG THOI GIAN VA NGAY
CREATE PROCEDURE sp_TimNhaSiRanh
				@Time varchar(15),
				@Date varchar(15)
AS
BEGIN
	DECLARE @ThoiGianHen DATETIME = CONVERT(DATETIME, @Date + ' ' + LEFT(@Time,2) + ':00')

	SELECT DISTINCT(NS.SDT), NS.HoTen
	FROM NGUOIDUNG NS JOIN LICHHEN LH ON NS.SDT = LH.MaNhaSi
	WHERE NOT EXISTS(SELECT 1 
					 FROM LICHHEN LH2 
					 WHERE LH2.ThoiGianHen = @ThoiGianHen AND LH2.MaNhaSi = NS.SDT)
		  AND 
		  NOT EXISTS(SELECT 1 
					 FROM LICHBAN LB 
					 WHERE LB.NgayGioBatDau < @ThoiGianHen AND LB.NgayGioKetThuc > @ThoiGianHen AND LB.MaNhaSi = NS.SDT)
END;
go 

EXEC sp_TimNhaSiRanh '12:30', '2023-12-02'
GO



--LAY THONG TIN CUA TOAN BO KHO THUOC
CREATE PROCEDURE sp_LayThongTinKhoThuoc
AS
BEGIN
	SELECT *
	FROM THUOC
END;
GO

EXEC sp_LayThongTinKhoThuoc
GO




--TIM THUOC TU MOT DOAN CUA TEN THUOC
CREATE PROCEDURE sp_TimThuocBangTen
				@TenThuoc VARCHAR(20)
AS 
BEGIN

	DECLARE @SubName VARCHAR(23) = '%' + @TenThuoc + '%'
	SELECT *
	FROM THUOC
	WHERE THUOC.TenThuoc LIKE @SubName
END;
GO

EXEC sp_TimThuocBangTen 'AM'
GO



-- DAT LICH KHAM (CO KIEM TRA NGUOI DUNG TON TAI HAY CHUA)
CREATE PROCEDURE sp_DatLichKham
				@SDT VARCHAR(20),	
				@HoTen nvarchar(30),
				@NgaySinh varchar(15),
				@DiaChi nvarchar(50),
				@NgayHen varchar(15),
				@GioHen varchar(15),
				@MaBacSi VARCHAR(20)
				
AS 
BEGIN 
	DECLARE @NgayGioHen DATETIME = CONVERT(DATETIME, @NgayHen + ' ' + LEFT(@GioHen,2) + ':00')
	DECLARE @MaLH int = (SELECT ISNULL(MAX(MaLH),0) FROM LICHHEN) + 1
	DECLARE @IsSdtExist BIT = CASE 
								  WHEN EXISTS(SELECT 1 FROM NGUOIDUNG WHERE SDT = @SDT) THEN 1
								  ELSE 0
						      END
	DECLARE @NgaySinhDateTime DATE = CONVERT(DATE, @NgaySinh)
	IF @IsSdtExist = 1
	BEGIN
		INSERT INTO LICHHEN VALUES (@MaLH, @NgayGioHen, @SDT, @MaBacSi, 0)
	END

	ELSE
	BEGIN
		INSERT INTO NGUOIDUNG VALUES (@SDT,@HoTen,@NgaySinhDateTime,@DiaChi)
		INSERT INTO LICHHEN VALUES (@MaLH, @NgayGioHen, @SDT, @MaBacSi, 0)
	END
	
END;
GO

EXEC sp_DatLichKham '000', N'Nguyễn Văn M','2003-11-11', N'Gia Lâm, Hà Nội', '2020-01-10', '15:00', '397'
GO

-- THEM NGUOI DUNG (CO KIEM TRA NGUOI DUNG CO TON TAI HAY CHUA)
CREATE PROCEDURE sp_ThemNguoiDung
				@SDT VARCHAR(20),	
				@HoTen nvarchar(30),
				@NgaySinh varchar(15),
				@DiaChi nvarchar(50)
AS 
BEGIN
	DECLARE @NgaySinhDateTime DATE = CONVERT(DATE, @NgaySinh)
	DECLARE @IsSdtExist BIT 
	EXEC @IsSdtExist = sp_KiemTraSdtTonTai @SDT
	IF @IsSdtExist = 0
	BEGIN
		INSERT INTO NGUOIDUNG VALUES (@SDT,@HoTen,@NgaySinhDateTime,@DiaChi)
		RETURN 1
	END
	ELSE
	BEGIN
		RETURN 0
	END
END;
GO

DECLARE @SUS INT
EXEC @SUS = sp_ThemNguoiDung '555', N'Nguyễn Văn S','2003-11-11', N'Gia Lâm, Hà Nội'
PRINT @SUS
GO



--DANG KY TAI KHOAN (CO KIEM TRA SDT VA TAI KHOAN TON TAI HAY CHUA)
CREATE PROCEDURE sp_DangKiTaiKhoan
				@SDT varchar(10),
				@HoTen nvarchar(30),
				@NgaySinh DATE,
				@DiaChi nvarchar (50),
				@MatKhau varchar(20),
				@LoaiND varchar(10)
AS
BEGIN
	DECLARE @isSDTExist BIT
	EXEC @isSDTExist = sp_KiemTraSdtTonTai @SDT

	DECLARE @isTKExist BIT
	EXEC @isTKExist = sp_KiemTraTKTonTai @SDT, @LoaiND

	--Kiem tra da co thong tin chua
	IF @isSDTExist = 1 
	BEGIN
		--Kiem tra co TK voi loai nguoi dung tuong ung chua
		--Neu co thi tra ve 0
		IF @isTKExist = 1
		BEGIN
			return 0
		END

		--Neu chua co thi them tai khoan
		ELSE
		BEGIN
			INSERT INTO TAIKHOAN VALUES (@SDT, @LoaiND, @MatKhau, 1)
		END
	END

	--Neu chua co thong tin trong NGUOIDUNG thi them thong tin va tai khoan
	ELSE
	BEGIN
		DECLARE @NgaySinhDate date = CONVERT(DATE, @NgaySinh)
		INSERT INTO NGUOIDUNG VALUES (@SDT, @HoTen, @NgaySinhDate, @DiaChi)
		INSERT INTO TAIKHOAN VALUES (@SDT, @LoaiND, @MatKhau, 1)
	END
	return 1
END;
GO

EXEC sp_DangKiTaiKhoan '910',N'Trần Văn O','2002-11-11',N'Đống Đa, Hà Nội','o','Khach'
Go



--XEM LICH KHAM CUA KHACH HANG (DUOC SU DUNG O NHANVIEN)
CREATE PROCEDURE sp_XemLichKham
				@SDT VARCHAR(20)
AS
BEGIN
	DECLARE @isSDTExist BIT
	EXEC @isSDTExist = sp_KiemTraSdtTonTai @SDT

	IF @isSDTExist = 0
	BEGIN
		SELECT 0 AS RESULT 
	END

	ELSE 
	BEGIN
		SELECT CONVERT(DATE, LH.ThoiGianHen) AS NgayKham, CONVERT(TIME, LH.ThoiGianHen) AS GioKham, LH.MaNhaSi, NS.HoTen AS TenNhaSi, KH.HoTen, KH.SDT
		FROM LICHHEN LH JOIN NGUOIDUNG NS ON LH.MaNhaSi = NS.SDT
						JOIN NGUOIDUNG KH ON KH.SDT = LH.SDT
		WHERE LH.SDT = @SDT
	END
END;
GO

EXEC sp_XemLichKham '123'
GO

-- =========== Trang =========== --

-- (KhachHang) XEM HO SO BENH AN --
CREATE OR ALTER PROCEDURE sp_XemHoSoBenhAn 
	@SDT VARCHAR(20)
AS
    DECLARE @DS_BENHAN TABLE(MaHoSo int, NgayKham datetime, MaNhaSi VARCHAR(20), TongTien bigint)
	INSERT INTO @DS_BENHAN
		SELECT HS.MaHoSo, HS.NgayKham, HS.MaNhaSi, HS.TongTien
		FROM HOSOBENHAN HS 
		WHERE HS.SDT = @SDT
    
    DECLARE @SL_BENHAN int
	SELECT @SL_BENHAN = COUNT(*) FROM @DS_BENHAN

    IF (@SL_BENHAN = 0)
    BEGIN
        SELECT NULL AS MaHoSo
        RETURN 
    END 

    DECLARE @i int, @MaHoSo int, @NgayKham datetime, @MaNhaSi VARCHAR(20), @TongTien bigint
    SET @i = 0

    WHILE (@i < @SL_BENHAN)
	BEGIN
        SELECT '==================== Ho So ' + CAST(@i+1 as char(3)) + '====================' AS STT
        SELECT TOP 1 @MaHoSo = MaHoSo FROM @DS_BENHAN
        -- In Ho So --
        SELECT TOP 1 * FROM @DS_BENHAN
        -- In Don Thuoc --
        SELECT '--- Don Thuoc ---'
        SELECT MaThuoc, SoLuong, DonGia
        FROM DONTHUOC 
        WHERE MaDonThuoc = @MaHoSo
        
        -- In Don Dich Vu --
        SELECT '--- Don Dich Vu ---'
        SELECT MaDV, DonGia
        FROM DONDICHVU 
        WHERE MaDonDV = @MaHoSo

        SET @i = @i + 1	
		DELETE @DS_BENHAN WHERE MaHoSo = @MaHoSo
	END
GO

-- EXEC sp_XemHoSoBenhAn '001'
-- GO
-- EXEC sp_XemHoSoBenhAn '000'
-- GO
EXEC sp_XemHoSoBenhAn '123'
GO

-- (KhachHang) CAP NHAT THONG TIN --
CREATE OR ALTER PROCEDURE sp_CapNhatThongTin 
    @SDT varchar(20), @HoTen nvarchar(30), @NgaySinh date, @DiaChi nvarchar(50), @MatKhau varchar(20)
AS
    IF (@HoTen <> '' AND @MatKhau <> '')
    BEGIN
        UPDATE NGUOIDUNG SET HoTen = @HoTen, NgaySinh = @NgaySinh, DiaChi = @DiaChi WHERE SDT = @SDT
        UPDATE TAIKHOAN SET MatKhau = @MatKhau WHERE SDT = @SDT
        RETURN 1
    END ELSE
    BEGIN
        RAISERROR('Ho ten va Mat khau phai khac rong', 16, 1)
		RETURN 0
    END
GO

-- EXEC sp_CapNhatThongTin '630', '', '2003-06-20', N'Bảo Lộc, Lâm Đồng', 'trang'
-- GO
EXEC sp_CapNhatThongTin '630', 'Võ Thu Trang', '2003-06-20', N'Bảo Lộc, Lâm Đồng', 'trang'
GO

-- function: KIEM TRA HAI LICH CO TRUNG NHAU KHONG (0: khong trung, 1: trung) --
CREATE FUNCTION f_KTLichTrungNhau 
    (@NgayGioBD1 datetime, @NgayGioKT1 datetime, @NgayGioBD2 datetime, @NgayGioKT2 datetime)
RETURNS bit 
AS
BEGIN
    IF (@NgayGioKT1 < @NgayGioBD2)
        RETURN 0
    IF (@NgayGioKT2 < @NgayGioBD1)
        RETURN 0
    RETURN 1
END
GO

print dbo.f_KTLichTrungNhau('2023-12-02 12:30:00', '2023-12-02 14:30:00', 
                            '2023-12-01 15:30:00', '2023-12-02 13:30:00')
GO

-- function: KIEM TRA LICH BAN CO HOP LE KHONG --
CREATE FUNCTION f_KTLichHopLe 
	(@MaNhaSi varchar(20), @NgayGioBD datetime, @NgayGioKT datetime)
RETURNS bit 
AS
BEGIN
    IF (@NgayGioBD >= @NgayGioKT)
    BEGIN
		RETURN 0
	END

    -- Kiem tra trong LICHHEN cua @MaNhaSi co bi trung khong --
    DECLARE @DS_LICHHEN TABLE(MaLH int, ThoiGianHen datetime)
	INSERT INTO @DS_LICHHEN
		SELECT MaLH, ThoiGianHen
		FROM LICHHEN 
		WHERE MaNhaSi = @MaNhaSi
    
    DECLARE @SL_LICHHEN int
	SELECT @SL_LICHHEN = COUNT(*) FROM @DS_LICHHEN

    IF (@SL_LICHHEN = 0)
        RETURN 1

    DECLARE @i int, @MaLH int, @NgayKhamBD datetime, @NgayKhamKT datetime
    SET @i = 0

    WHILE (@i < @SL_LICHHEN)
	BEGIN
        SELECT TOP 1 @MaLH = MaLH, @NgayKhamBD = ThoiGianHen FROM @DS_LICHHEN
        SET @NgayKhamKT = DATEADD(hour, 1, @NgayKhamBD)
        
        IF (dbo.f_KTLichTrungNhau(@NgayKhamBD, @NgayKhamKT, @NgayGioBD, @NgayGioKT) = 1)
            RETURN 0

        SET @i = @i + 1
		DELETE @DS_LICHHEN WHERE MaLH = @MaLH
	END

    RETURN 1
END
GO

print dbo.f_KTLichHopLe('237', '2023-12-02 10:30', '2023-12-02 13:30')
GO

-- (NhaSi) CAP NHAT LICH BAN --
CREATE OR ALTER PROCEDURE sp_CapNhatLichBan
    @MaNhaSi varchar(20), @MALB int, @NgayBDMoi varchar(20), @GioBDMoi varchar(20), @NgayKTMoi varchar(20), @GioKTMoi varchar(20)
AS
    DECLARE @NgayGioBD_Moi DATETIME = CONVERT(DATETIME, @NgayBDMoi + ' ' + LEFT(@GioBDMoi,2) + ':00')
    DECLARE @NgayGioKT_Moi DATETIME = CONVERT(DATETIME, @NgayKTMoi + ' ' + LEFT(@GioKTMoi,2) + ':00')

    IF (dbo.f_KTLichHopLe(@MaNhaSi, @NgayGioBD_Moi, @NgayGioKT_Moi) = 0)
    BEGIN
		RAISERROR('Cap nhat khong thanh cong', 16, 1)
		RETURN 0
	END

    UPDATE LICHBAN SET NgayGioBatDau = @NgayGioBD_Moi, NgayGioKetThuc = @NgayGioKT_Moi WHERE MALB = @MALB
    RETURN 1
GO

EXEC sp_CapNhatLichBan '237', 5, '2023-12-02', '09:00', '2023-12-02', '10:00'
GO

-- (NhaSi) THEM LICH BAN --
CREATE OR ALTER PROCEDURE sp_ThemLichBan
    @MaNhaSi varchar(20), @NgayBD varchar(20), @GioBD varchar(20), @NgayKT varchar(20), @GioKT varchar(20)
AS
    DECLARE @NgayGioBD DATETIME = CONVERT(DATETIME, @NgayBD + ' ' + LEFT(@GioBD,2) + ':00')
    DECLARE @NgayGioKT DATETIME = CONVERT(DATETIME, @NgayKT + ' ' + LEFT(@GioKT,2) + ':00')

    IF (dbo.f_KTLichHopLe(@MaNhaSi, @NgayGioBD, @NgayGioKT) = 0)
    BEGIN
		RAISERROR('Them khong thanh cong', 16, 1)
		RETURN 0
	END

	DECLARE @MALB int = (SELECT ISNULL(MAX(MALB),0) FROM LICHBAN) + 1
	
	INSERT INTO LICHBAN VALUES (@MALB, @MaNhaSi, @NgayGioBD, @NgayGioKT)
	RETURN 1
GO

EXEC sp_ThemLichBan '237', '2023-12-03', '06:00', '2023-12-03', '08:00'
GO
EXEC sp_ThemLichBan '237', '2023-12-03', '09:00', '2023-12-03', '10:00'
GO

-- (NhanVien) THANH TOAN --
CREATE OR ALTER PROCEDURE sp_ThanhToan 
	@SDT varchar(20)
AS
	DECLARE @isSDTExist BIT
	EXEC @isSDTExist = sp_KiemTraSdtTonTai @SDT

	IF (@isSDTExist = 0)
	BEGIN 
		RAISERROR('SDT khong ton tai', 16, 1)
		RETURN 0
	END

	DECLARE @DS_CANTHANHTOAN TABLE(MaHoSo int)
	INSERT INTO @DS_CANTHANHTOAN
		SELECT MaHoSo
		FROM HOSOBENHAN 
		WHERE SDT = @SDT AND TongTien = 0
    
    DECLARE @SL_TT int
	SELECT @SL_TT = COUNT(*) FROM @DS_CANTHANHTOAN

    IF (@SL_TT = 0)
	BEGIN
		print('Khong co ho so can thanh toan')
        RETURN 1
	END

    DECLARE @i int, @MaHoSo int, @TongTienThuoc bigint, @TongTienDV bigint
    SET @i = 0

    WHILE (@i < @SL_TT)
	BEGIN
        SELECT TOP 1 @MaHoSo = MaHoSo FROM @DS_CANTHANHTOAN
		SELECT @TongTienThuoc = SUM(DonGia * SoLuong) FROM DONTHUOC WHERE MaDonThuoc = @MaHoSo
		SELECT @TongTienDV = SUM(DonGia) FROM DONDICHVU WHERE MaDonDV = @MaHoSo
		-- Thanh toan --
		UPDATE HOSOBENHAN SET TongTien = @TongTienThuoc + @TongTienDV WHERE MaHoSo = @MaHoSo

        SET @i = @i + 1
		DELETE @DS_CANTHANHTOAN WHERE MaHoSo = @MaHoSo
	END
	RETURN 1
GO

EXEC sp_ThanhToan '234'
GO
EXEC sp_ThanhToan '123'
GO

-- (NhaSi) TAO HO SO BENH AN --
CREATE OR ALTER PROCEDURE sp_TaoHoSoBenhAn 
	@SDT varchar(20), @MaNhaSi varchar(20)
AS
	DECLARE @isSDTExist BIT
	EXEC @isSDTExist = sp_KiemTraSdtTonTai @SDT

	IF (@isSDTExist = 0)
	BEGIN 
		RAISERROR('SDT khong ton tai', 16, 1)
		RETURN 0
	END

	DECLARE @MaHoSo int = (SELECT ISNULL(MAX(MaHoSo),0) FROM HOSOBENHAN) + 1
	INSERT INTO HOSOBENHAN(MaHoSo, SDT, MaNhaSi, NgayKham, TongTien) VALUES (@MaHoSo, @SDT, @MaNhaSi, GETDATE(), 0)
	RETURN 1
GO

EXEC sp_TaoHoSoBenhAn '234', '397'
GO

-- (NhaSi) TAO DON THUOC --
CREATE OR ALTER PROCEDURE sp_TaoDonThuoc 
	@MaHoSo int, @TenThuoc char(30), @SoLuong int
AS
	DECLARE @SoLuongTon int 
	SELECT @SoLuongTon = SoLuongTon FROM THUOC WHERE TenThuoc = @TenThuoc

	IF (@SoLuong > @SoLuongTon)
	BEGIN
		RAISERROR('Vuot qua so luong ton', 16, 1)
        RETURN 0
	END

	DECLARE @MaThuoc char(10), @DonGia int
	SELECT @MaThuoc = MaThuoc, @DonGia = DonGia FROM THUOC WHERE TenThuoc = @TenThuoc

	INSERT INTO DONTHUOC(MaDonThuoc, MaThuoc, SoLuong, DonGia) VALUES (@MaHoSo, @MaThuoc, @SoLuong, @DonGia)
	UPDATE THUOC SET SoLuongTon = @SoLuongTon - @SoLuong WHERE MaThuoc = @MaThuoc
	RETURN 1
GO

EXEC sp_TaoDonThuoc 7, 'Panadol', 6
GO

-- (NhaSi) TAO DON DICH VU --
CREATE OR ALTER PROCEDURE sp_TaoDonDV 
	@MaHoSo int, @TenDV nvarchar(50)
AS
	DECLARE @MaDV char(10), @DonGia int
	SELECT @MaDV = MaDV, @DonGia = DonGia FROM DICHVU WHERE TenDV = @TenDV

	INSERT INTO DONDICHVU(MaDonDV, MaDV, DonGia) VALUES (@MaHoSo, @MaDV, @DonGia)
	RETURN 1
GO

EXEC sp_TaoDonDV 7, N'Tẩy trắng răng'
GO

-- (QTV) KHOA TAI KHOAN --
CREATE OR ALTER PROCEDURE sp_KhoaTaiKhoan
	@SDT varchar(20), @LoaiND varchar(10)
AS
	-- Kiem tra da co tai khoan chua
	DECLARE @isTKExist BIT
	EXEC @isTKExist = sp_KiemTraTKTonTai @SDT, @LoaiND

	IF (@isTKExist = 0)
	BEGIN
		RAISERROR('Tai khoan khong ton tai', 16, 1)
        RETURN 0
	END

	-- Khoa
	UPDATE TAIKHOAN SET TrangThai = 0 WHERE SDT = @SDT AND LoaiND = @LoaiND
	RETURN 1
GO

EXEC sp_KhoaTaiKhoan '020', 'NhanVien'
GO

-- (QTV) THEM THUOC --
CREATE OR ALTER PROCEDURE sp_ThemThuoc
	@MaThuoc char(10), @TenThuoc char(30),	@DonGia int, @ChiDinh nvarchar(100), @SoLuongTon int, @NgayHetHan date
AS
	-- Kiem tra thuoc co ton tai khong
	IF (@MaThuoc IN (SELECT MaThuoc FROM THUOC))
	BEGIN
		RAISERROR('Ma thuoc da ton tai', 16, 1)
        RETURN 0
	END

	-- Kiem tra ngay het han co sau ngay them khong
	IF (@NgayHetHan <= CAST(GETDATE() AS date))
	BEGIN
		RAISERROR('Ngay het han phai sau ngay them', 16, 1)
        RETURN 0
	END

	-- Them
	INSERT INTO THUOC(MaThuoc, TenThuoc, SoLuongTon, DonGia, NgayHetHan, ChiDinh) 
	VALUES (@MaThuoc, @TenThuoc, @SoLuongTon, @DonGia, @NgayHetHan, @ChiDinh)
	RETURN 1
GO

EXEC sp_ThemThuoc 'T006', 'Alaxan', 7000, N'Thuốc giảm đau kháng viêm', 100, '2025-12-30'
GO
EXEC sp_ThemThuoc 'T001', 'Paracetamol', 10000, N'Thuốc giảm đau hạ sốt', 100, '2025-12-30'
GO

-- (QTV) SUA THONG TIN THUOC --
CREATE OR ALTER PROCEDURE sp_SuaThongTinThuoc
	@MaThuoc char(10), @TenThuoc char(30),	@DonGia int, @ChiDinh nvarchar(100), @SoLuongTon int, @NgayHetHan date
AS
	-- Kiem tra thuoc can sua co ton tai khong
	IF (@MaThuoc NOT IN (SELECT MaThuoc FROM THUOC))
	BEGIN
		RAISERROR('Ma thuoc khong ton tai', 16, 1)
        RETURN 0
	END

	-- Kiem tra ten thuoc da ton tai chua
	IF (@TenThuoc IN (SELECT TenThuoc FROM THUOC))
	BEGIN
		RAISERROR('Ten thuoc da ton tai', 16, 1)
        RETURN 0
	END

	-- Kiem tra ngay het han co sau ngay sua khong
	IF (@NgayHetHan <= CAST(GETDATE() AS date))
	BEGIN
		RAISERROR('Ngay het han phai sau ngay sua', 16, 1)
        RETURN 0
	END

	-- Them
	UPDATE THUOC SET TenThuoc = @TenThuoc, SoLuongTon = @SoLuongTon, DonGia = @DonGia, NgayHetHan = @NgayHetHan, ChiDinh = @ChiDinh
	WHERE MaThuoc = @MaThuoc
	RETURN 1
GO

EXEC sp_SuaThongTinThuoc 'T001', 'Panadol', 6000, N'Thuốc giảm đau kháng viêm', 100, '2025-12-30'
GO
EXEC sp_SuaThongTinThuoc 'T006', 'Cilzec', 8000, N'Thuốc điều trị cao huyết áp', 100, '2025-12-30'
GO