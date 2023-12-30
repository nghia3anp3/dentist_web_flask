USE HQT_CSDL
GO

-- KIEM TRA MOT SO DIEN THOAI CO TON TAI TRONG NGUOI DUNG HAY CHUA
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

-- DECLARE @TEST BIT
-- EXEC @TEST = sp_KiemTraSdtTonTai '630'
-- PRINT @TEST
-- GO

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

-- DECLARE @TEST BIT
-- EXEC @TEST = sp_KiemTraTKTonTai '123', 'Admin'
-- PRINT @TEST
-- GO

-- LAY BANG THUOC DANG LUU HANH
CREATE FUNCTION tb_ThuocHienHanh ()
RETURNS TABLE 
AS
	RETURN( SELECT MaThuoc, TenThuoc, DonGia, ChiDinh, SoLuongTon, NgayHetHan 
			FROM THUOC 
			WHERE TrangThai = 1 AND SoLuongTon > 0 );
GO

-- SELECT * FROM tb_ThuocHienHanh()
-- GO

-- LAY THONG TIN CUA TOAN BO KHO THUOC
CREATE PROCEDURE sp_LayThongTinKhoThuoc
AS
	SELECT * FROM tb_ThuocHienHanh()
GO

-- EXEC sp_LayThongTinKhoThuoc
-- GO

--LAY THONG TIN NGUOI DUNG TU MOT SO DIEN THOAI
CREATE PROCEDURE sp_LayThongTinTuSDT 
				@SDT VARCHAR(20)
AS
	DECLARE @Exist BIT
	EXEC @Exist = sp_KiemTraSdtTonTai @SDT
	IF @Exist = 1
		SELECT HoTen, NgaySinh, DiaChi FROM NGUOIDUNG WHERE SDT = @SDT
	ELSE
		SELECT 0 AS Result
GO

-- EXEC sp_LayThongTinTuSDT '000'
-- GO

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
GO

-- EXEC sp_LayHoaDonTuSDT '123'
-- GO

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

-- EXEC sp_TimNhaSiRanh '12:30', '2023-12-02'
-- GO

--TIM THUOC (DANG LUU HANH) TU MOT DOAN CUA TEN THUOC
CREATE PROCEDURE sp_TimThuocBangTen
				@TenThuoc VARCHAR(20)
AS 
BEGIN

	DECLARE @SubName VARCHAR(23) = '%' + @TenThuoc + '%'
	SELECT *
	FROM tb_ThuocHienHanh()
	WHERE TenThuoc LIKE @SubName
END;
GO

-- EXEC sp_TimThuocBangTen 'AM'
-- GO

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

-- DECLARE @SUS INT
-- EXEC @SUS = sp_ThemNguoiDung '555', N'Nguyễn Văn S','2003-11-11', N'Gia Lâm, Hà Nội'
-- PRINT @SUS
-- GO

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

-- EXEC sp_DangKiTaiKhoan '910',N'Trần Văn O','2002-11-11',N'Đống Đa, Hà Nội','o','Khach'
-- Go

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

-- EXEC sp_XemLichKham '123'
-- GO

---------------------------------------------------------------------------------

-- (KhachHang) XEM HO SO BENH AN --
CREATE PROCEDURE sp_XemHoSoBenhAn 
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

-- EXEC sp_XemHoSoBenhAn '000'
-- GO
-- EXEC sp_XemHoSoBenhAn '123'
-- GO

-- (KhachHang) CAP NHAT THONG TIN --
CREATE PROCEDURE sp_CapNhatThongTin 
    @SDT varchar(20), @HoTen nvarchar(30), @NgaySinh date, @DiaChi nvarchar(50), @MatKhau varchar(20)
AS
    IF (@HoTen <> '' AND @MatKhau <> '')
    BEGIN
        UPDATE NGUOIDUNG SET HoTen = @HoTen, NgaySinh = @NgaySinh, DiaChi = @DiaChi WHERE SDT = @SDT
        UPDATE TAIKHOAN SET MatKhau = @MatKhau WHERE SDT = @SDT
        RETURN 1
    END ELSE
    BEGIN
        RAISERROR(N'Họ tên và Mật khẩu phải khác rỗng', 16, 1)
		RETURN 0
    END
GO

-- EXEC sp_CapNhatThongTin '630', 'Võ Thu Trang', '2003-06-20', N'Bảo Lộc, Lâm Đồng', 'trang'
-- GO

-- function: KIEM TRA HAI LICH CO TRUNG NHAU KHONG (0: khong trung, 1: trung) --
CREATE FUNCTION f_KTLichTrungNhau 
    (@NgayGioBD1 datetime, @NgayGioKT1 datetime, @NgayGioBD2 datetime, @NgayGioKT2 datetime)
RETURNS bit 
AS
BEGIN
    IF (@NgayGioKT1 <= @NgayGioBD2)
        RETURN 0
    IF (@NgayGioKT2 <= @NgayGioBD1)
        RETURN 0
    RETURN 1
END
GO

-- PRINT dbo.f_KTLichTrungNhau('2023-12-02 12:30:00', '2023-12-02 14:45:00', 
--                             '2023-12-02 14:30:00', '2023-12-02 15:30:00')
-- GO

-- function: KIEM TRA LICH BAN CO HOP LE KHONG (chi xet bang LICHHEN) --
CREATE FUNCTION f_KTLichBanHopLe 
	(@MaNhaSi varchar(20), @NgayGioBD datetime, @NgayGioKT datetime)
RETURNS bit 
AS
BEGIN
    IF (@NgayGioBD > @NgayGioKT)
		RETURN 0

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

-- PRINT dbo.f_KTLichBanHopLe('397', '2024-04-20 12:00', '2024-04-20 15:00')
-- GO

-- (NhaSi) CAP NHAT LICH BAN --
CREATE PROCEDURE sp_CapNhatLichBan
    @MaNhaSi varchar(20), @MALB int, @NgayBDMoi varchar(20), @GioBDMoi varchar(20), @NgayKTMoi varchar(20), @GioKTMoi varchar(20)
AS
    DECLARE @NgayGioBD_Moi DATETIME = CONVERT(DATETIME, @NgayBDMoi + ' ' + LEFT(@GioBDMoi,2) + ':00')
    DECLARE @NgayGioKT_Moi DATETIME = CONVERT(DATETIME, @NgayKTMoi + ' ' + LEFT(@GioKTMoi,2) + ':00')

    IF (dbo.f_KTLichBanHopLe(@MaNhaSi, @NgayGioBD_Moi, @NgayGioKT_Moi) = 0)
    BEGIN
		RAISERROR(N'Lịch không hợp lệ', 16, 1)
		RETURN 0
	END

    UPDATE LICHBAN SET NgayGioBatDau = @NgayGioBD_Moi, NgayGioKetThuc = @NgayGioKT_Moi WHERE MALB = @MALB
    RETURN 1
GO

-- EXEC sp_CapNhatLichBan '237', 5, '2023-12-02', '09:00', '2023-12-02', '10:00'
-- GO

-- (NhaSi) THEM LICH BAN --
CREATE PROCEDURE sp_ThemLichBan
    @MaNhaSi varchar(20), @NgayBD varchar(20), @GioBD varchar(20), @NgayKT varchar(20), @GioKT varchar(20)
AS
    DECLARE @NgayGioBD DATETIME = CONVERT(DATETIME, @NgayBD + ' ' + LEFT(@GioBD,2) + ':00')
    DECLARE @NgayGioKT DATETIME = CONVERT(DATETIME, @NgayKT + ' ' + LEFT(@GioKT,2) + ':00')

    IF (dbo.f_KTLichBanHopLe(@MaNhaSi, @NgayGioBD, @NgayGioKT) = 0)
    BEGIN
		RAISERROR(N'Lịch không hợp lệ', 16, 1)
		RETURN 0
	END

	DECLARE @MALB int = (SELECT ISNULL(MAX(MALB),0) FROM LICHBAN) + 1
	
	INSERT INTO LICHBAN VALUES (@MALB, @MaNhaSi, @NgayGioBD, @NgayGioKT)
	RETURN 1
GO

-- EXEC sp_ThemLichBan '237', '2023-12-03', '06:00', '2023-12-03', '08:00'
-- GO
-- EXEC sp_ThemLichBan '237', '2023-12-03', '09:00', '2023-12-03', '10:00'
-- GO

-- (NhaSi) XEM LICH BAN --
CREATE PROCEDURE sp_XemLichBan
	@MaNhaSi varchar(20)
AS
	SELECT * FROM LICHBAN WHERE MaNhaSi = @MaNhaSi
GO

-- (NhanVien) TINH TIEN --
CREATE PROCEDURE sp_TinhTien
	@SDT varchar(20), @MaHoSo int 
AS
	DECLARE @isSDTExist BIT
	EXEC @isSDTExist = sp_KiemTraSdtTonTai @SDT

	IF (@isSDTExist = 0)
	BEGIN 
		RAISERROR(N'SDT không tồn tại', 16, 1)
		RETURN 0
	END

	IF NOT EXISTS (SELECT * FROM HOSOBENHAN WHERE SDT = @SDT AND MaHoSo = @MaHoSo)
	BEGIN 
		RAISERROR(N'Khách hàng không tồn tại hồ sơ có mã %i', 16, 1, @MaHoSo)
		RETURN 0
	END

	DECLARE @TongTien bigint = (SELECT TongTien FROM HOSOBENHAN WHERE MaHoSo = @MaHoSo)
    IF (@TongTien <> 0)
	BEGIN
		PRINT N'Hồ sơ đã được tính tiền'
        RETURN 0
	END

	DECLARE @TongTienThuoc bigint, @TongTienDV bigint
	SELECT @TongTienThuoc = SUM(DonGia * SoLuong) FROM DONTHUOC WHERE MaDonThuoc = @MaHoSo
	SELECT @TongTienDV = SUM(DonGia) FROM DONDICHVU WHERE MaDonDV = @MaHoSo

	-- Thanh toan --
	UPDATE HOSOBENHAN SET TongTien = @TongTienThuoc + @TongTienDV WHERE MaHoSo = @MaHoSo
	RETURN 1
GO

-- EXEC sp_TinhTien '123', 6
-- GO
-- EXEC sp_TinhTien '123', 1
-- GO
-- EXEC sp_TinhTien '123', 8
-- GO
-- EXEC sp_TinhTien '094', 8
-- GO

-- (NhaSi) TAO HO SO BENH AN --
CREATE PROCEDURE sp_TaoHoSoBenhAn 
	@SDT varchar(20), @MaNhaSi varchar(20)
AS
	DECLARE @isSDTExist BIT
	EXEC @isSDTExist = sp_KiemTraSdtTonTai @SDT

	IF (@isSDTExist = 0)
	BEGIN 
		RAISERROR(N'SDT không tồn tại', 16, 1)
		RETURN 0
	END

	DECLARE @MaHoSo int = (SELECT ISNULL(MAX(MaHoSo),0) FROM HOSOBENHAN) + 1
	INSERT INTO HOSOBENHAN(MaHoSo, SDT, MaNhaSi, NgayKham, TongTien) VALUES (@MaHoSo, @SDT, @MaNhaSi, GETDATE(), 0)
	RETURN 1
GO

-- EXEC sp_TaoHoSoBenhAn '234', '397'
-- GO

-- (NhaSi) TAO DON THUOC --
CREATE PROCEDURE sp_TaoDonThuoc 
	@MaHoSo int, @TenThuoc char(30), @SoLuong int
AS
	-- Kiem tra ten thuoc ton tai trong kho hien hanh khong
	IF (@TenThuoc NOT IN (SELECT TenThuoc FROM tb_ThuocHienHanh()))
	BEGIN
		RAISERROR(N'Không tồn tại thuốc', 16, 1)
        RETURN 0
	END

	-- Kiem tra so luong ton
	DECLARE @SoLuongTon int 
	SELECT @SoLuongTon = SoLuongTon FROM tb_ThuocHienHanh() WHERE TenThuoc = @TenThuoc

	IF (@SoLuong > @SoLuongTon)
	BEGIN
		RAISERROR(N'Vượt quá số lượng tồn', 16, 1)
        RETURN 0
	END

	-- Tao don thuoc
	DECLARE @MaThuoc char(10), @DonGia int
	SELECT @MaThuoc = MaThuoc, @DonGia = DonGia FROM tb_ThuocHienHanh() WHERE TenThuoc = @TenThuoc

	INSERT INTO DONTHUOC(MaDonThuoc, MaThuoc, SoLuong, DonGia) VALUES (@MaHoSo, @MaThuoc, @SoLuong, @DonGia)
	UPDATE THUOC SET SoLuongTon = @SoLuongTon - @SoLuong WHERE MaThuoc = @MaThuoc
	RETURN 1
GO

-- EXEC sp_TaoDonThuoc 7, 'Panadol', 6
-- GO

-- (NhaSi) TAO DON DICH VU --
CREATE PROCEDURE sp_TaoDonDV 
	@MaHoSo int, @TenDV nvarchar(50)
AS
	-- Kiem tra ten dich vu co ton tai khong
	IF (@TenDV NOT IN (SELECT TenDV FROM DICHVU))
	BEGIN
		RAISERROR(N'Không tồn tại dịch vụ', 16, 1)
        RETURN 0
	END

	DECLARE @MaDV char(10), @DonGia int
	SELECT @MaDV = MaDV, @DonGia = DonGia FROM DICHVU WHERE TenDV = @TenDV

	INSERT INTO DONDICHVU(MaDonDV, MaDV, DonGia) VALUES (@MaHoSo, @MaDV, @DonGia)
	RETURN 1
GO

-- EXEC sp_TaoDonDV 7, N'Tẩy trắng răng'
-- GO

-- (QTV) KHOA TAI KHOAN --
CREATE PROCEDURE sp_KhoaTaiKhoan
	@SDT varchar(20), @LoaiND varchar(10)
AS
	-- Kiem tra da co tai khoan chua
	DECLARE @isTKExist BIT
	EXEC @isTKExist = sp_KiemTraTKTonTai @SDT, @LoaiND

	IF (@isTKExist = 0)
	BEGIN
		RAISERROR(N'Tài khoản không tồn tại', 16, 1)
        RETURN 0
	END

	-- Kiem tra tai khoan da bi khoa chua
	DECLARE @lock BIT 
	SELECT @lock = TrangThai FROM TAIKHOAN WHERE SDT = @SDT AND LoaiND = @LoaiND
	IF (@lock = 0)
	BEGIN
		RAISERROR(N'Tài khoản đã bị khoá', 16, 1)
        RETURN 0
	END

	-- Khoa
	UPDATE TAIKHOAN SET TrangThai = 0 WHERE SDT = @SDT AND LoaiND = @LoaiND
	RETURN 1
GO

-- EXEC sp_KhoaTaiKhoan '020', 'NhanVien'
-- GO

-- (QTV) THEM THUOC --
CREATE PROCEDURE sp_ThemThuoc
	@TenThuoc char(30),	@DonGia int, @ChiDinh nvarchar(100), @SoLuongTon int, @NgayHetHan date
AS
	-- Tu tang Ma thuoc
	DECLARE @last char(10)
	SELECT @last = MAX(MaThuoc) FROM THUOC

	DECLARE @num int = SUBSTRING(@last, 2, 3) + 1 

	DECLARE @fill int = LEN(CAST(@last AS char(10))) - LEN(CAST(@num AS char(10))) - 1
	IF @fill < 0
		SET @fill = 0

	DECLARE @MaThuoc char(10) = CONCAT('T', REPLICATE('0', @fill), @num)

	-- Kiem tra ten thuoc da ton tai chua
	IF (@TenThuoc IN (SELECT TenThuoc FROM tb_ThuocHienHanh()))
	BEGIN
		RAISERROR(N'Trùng tên với thuốc khác trong kho hiện hành', 16, 1)
        RETURN 0
	END

	-- Kiem tra ngay het han co sau ngay them khong
	IF (@NgayHetHan <= CAST(GETDATE() AS date))
	BEGIN
		RAISERROR(N'Ngày hết hạn phải sau ngày thêm', 16, 1)
        RETURN 0
	END

	-- Them
	INSERT INTO THUOC(MaThuoc, TenThuoc, SoLuongTon, DonGia, NgayHetHan, ChiDinh) 
	VALUES (@MaThuoc, @TenThuoc, @SoLuongTon, @DonGia, @NgayHetHan, @ChiDinh)
	RETURN 1
GO

-- EXEC sp_ThemThuoc 'Alaxan', 7000, N'Thuốc giảm đau kháng viêm', 100, '2025-12-30'
-- GO
-- EXEC sp_ThemThuoc 'Paracetamol', 10000, N'Thuốc giảm đau hạ sốt', 100, '2025-12-30'
-- GO

-- (QTV) SUA THONG TIN THUOC --
CREATE PROCEDURE sp_SuaThongTinThuoc
	@MaThuoc char(10), @TenThuoc char(30),	@DonGia int, @ChiDinh nvarchar(100), @SoLuongTon int, @NgayHetHan date
AS
	-- Kiem tra thuoc co ton tai de sua khong
	IF (@MaThuoc NOT IN (SELECT MaThuoc FROM tb_ThuocHienHanh()))
	BEGIN
		RAISERROR(N'Mã thuốc không tồn tại trong kho hiện hành', 16, 1)
        RETURN 0
	END

	-- Kiem tra ten thuoc (neu thay doi) da ton tai chua
	DECLARE @TenThuocTruoc char(30) = (SELECT TenThuoc FROM THUOC WHERE MaThuoc = @MaThuoc)
	IF (@TenThuoc IN (SELECT TenThuoc FROM tb_ThuocHienHanh()) AND @TenThuoc <> @TenThuocTruoc)
	BEGIN
		RAISERROR(N'Trùng tên với thuốc khác trong kho hiện hành', 16, 1)
        RETURN 0
	END

	-- Kiem tra ngay het han co sau ngay sua khong
	IF (@NgayHetHan <= CAST(GETDATE() AS date))
	BEGIN
		RAISERROR(N'Ngày hết hạn phải sau ngày sửa', 16, 1)
        RETURN 0
	END

	-- Cap nhat
	UPDATE tb_ThuocHienHanh() 
	SET TenThuoc = @TenThuoc, SoLuongTon = @SoLuongTon, DonGia = @DonGia, NgayHetHan = @NgayHetHan, ChiDinh = @ChiDinh
	WHERE MaThuoc = @MaThuoc
	RETURN 1
GO

-- EXEC sp_SuaThongTinThuoc 'T001', 'Paracetamol', 6000, N'Thuốc giảm đau kháng viêm', 100, '2025-12-30'
-- GO
-- EXEC sp_SuaThongTinThuoc 'T006', 'Cilzec', 8000, N'Thuốc điều trị cao huyết áp', 100, '2025-12-30'
-- GO

-- (QTV) XOA THUOC --
CREATE PROCEDURE sp_XoaThuoc
	@MaThuoc char(10)
AS
	-- Kiem tra thuoc co ton tai de xoa khong
	IF (@MaThuoc NOT IN (SELECT MaThuoc FROM tb_ThuocHienHanh()))
	BEGIN
		RAISERROR(N'Mã thuốc không tồn tại trong kho hiện hành', 16, 1)
        RETURN 0
	END

	-- Xoa
	UPDATE THUOC SET TrangThai = 0 WHERE MaThuoc = @MaThuoc
	RETURN 1
GO

-- EXEC sp_XoaThuoc 'T004'
-- GO

-- function: KIEM TRA LICH HEN CO HOP LE KHONG (xet bang LICHHEN va LICHBAN) --
CREATE FUNCTION f_KTLichHenHopLe 
	(@MaNhaSi varchar(20), @NgayGioBD datetime)
RETURNS bit 
AS
BEGIN
    DECLARE @NgayGioKT datetime
	SET @NgayGioKT = DATEADD(hour, 1, @NgayGioBD)

    -- Kiem tra trong LICHHEN cua @MaNhaSi co bi trung khong --
	IF (dbo.f_KTLichBanHopLe (@MaNhaSi, @NgayGioBD, @NgayGioKT) = 0)
		RETURN 0
	
	-- Kiem tra trong LICHBAN cua @MaNhaSi co bi trung khong --
    DECLARE @DS_LICHBAN TABLE(MALB int, NgayGioBatDau datetime, NgayGioKetThuc datetime)
	INSERT INTO @DS_LICHBAN
		SELECT MALB, NgayGioBatDau, NgayGioKetThuc
		FROM LICHBAN
		WHERE MaNhaSi = @MaNhaSi
    
    DECLARE @SL_LICHBAN int
	SELECT @SL_LICHBAN = COUNT(*) FROM @DS_LICHBAN

    IF (@SL_LICHBAN = 0)
        RETURN 1

    DECLARE @i int, @MALB int, @NgayGioBD_Ban datetime, @NgayGioKT_Ban datetime
    SET @i = 0

    WHILE (@i < @SL_LICHBAN)
	BEGIN
        SELECT TOP 1 @MALB = MALB, @NgayGioBD_Ban = NgayGioBatDau, @NgayGioKT_Ban = NgayGioKetThuc FROM @DS_LICHBAN
        
        IF (dbo.f_KTLichTrungNhau(@NgayGioBD, @NgayGioKT, @NgayGioBD_Ban, @NgayGioKT_Ban) = 1)
            RETURN 0

        SET @i = @i + 1
		DELETE @DS_LICHBAN WHERE MALB = @MALB
	END

    RETURN 1
END
GO

-- print dbo.f_KTLichHenHopLe('397', '2023-12-02 16:00')
-- GO

-- DAT LICH KHAM 
CREATE PROCEDURE sp_DatLichKham
	@SDT VARCHAR(20), @HoTen nvarchar(30), @NgaySinh varchar(15), @DiaChi nvarchar(50), 
	@NgayHen varchar(15), @GioHen varchar(15), @MaNhaSi VARCHAR(20)		
AS  
	-- Kiem tra dieu kien
	DECLARE @NgayGioHen DATETIME = CONVERT(DATETIME, @NgayHen + ' ' + LEFT(@GioHen,2) + ':00')
	IF (dbo.f_KTLichHenHopLe(@MaNhaSi, @NgayGioHen) = 0)
    BEGIN
		RAISERROR(N'Lịch không hợp lệ', 16, 1)
		RETURN 0
	END

	-- Them lich hen
	DECLARE @MaLH int = (SELECT ISNULL(MAX(MaLH),0) FROM LICHHEN) + 1
	INSERT INTO LICHHEN VALUES (@MaLH, @NgayGioHen, @SDT, @MaNhaSi)

	-- Them nguoi dung neu chua co
	DECLARE @isSDTExist BIT
	EXEC @isSDTExist = sp_KiemTraSdtTonTai @SDT

	IF (@IsSdtExist = 0)
	BEGIN
		DECLARE @NgaySinhDateTime DATE = CONVERT(DATE, @NgaySinh)
		INSERT INTO NGUOIDUNG VALUES (@SDT,@HoTen,@NgaySinhDateTime,@DiaChi)
	END
GO

-- EXEC sp_DatLichKham '000', N'Nguyễn Văn M','2003-11-11', N'Gia Lâm, Hà Nội', '2020-01-10', '15:00', '397'
-- GO

-- ============ TRIGGER ============
-- R1: INSERT LICHHEN (MaNhaSi)
CREATE TRIGGER trgThem_LichHen_NhaSi
ON LICHHEN
FOR insert
AS
BEGIN 
	IF NOT EXISTS ( SELECT * 
					FROM inserted i, TAIKHOAN
					WHERE i.MaNhaSi = TAIKHOAN.SDT AND LoaiND = 'BacSi' )
	BEGIN
		RAISERROR (N'Không tồn tại (tài khoản) nha sĩ', 16, 1)
		ROLLBACK
	END
END
GO

-- INSERT INTO LICHHEN VALUES (8, '2023-12-02 15:00:00', '345', '630')
-- INSERT INTO LICHHEN VALUES (8, '2023-12-05 20:00:00', '345', '397')

-- R2: INSERT, UPDATE DONDICHVU (DonGia)
CREATE TRIGGER trgThem_CapNhatDonDV_DonGia
ON DONDICHVU
FOR insert, update
AS
BEGIN 
	IF NOT EXISTS ( SELECT * 
					FROM inserted i, DICHVU DV 
					WHERE DV.MaDV = i.MaDV AND DV.DonGia = i.DonGia )
	BEGIN
		RAISERROR (N'Đơn giá không đúng tại thời điểm thêm/sửa', 16, 1)
		ROLLBACK
	END
END
GO
-- INSERT INTO DONDICHVU VALUES (3, 'D002', 200)
-- UPDATE DONDICHVU SET DonGia = 200 WHERE MaDonDV = 1 AND MaDV = 'D001'

-- R3: INSERT, UPDATE DONTHUOC (DonGia)
CREATE TRIGGER trgThem_CapNhatDonThuoc_DonGia
ON DONTHUOC
FOR insert, update
AS
BEGIN 
	IF NOT EXISTS ( SELECT * 
					FROM inserted i, THUOC T 
					WHERE T.MaThuoc = i.MaThuoc AND T.DonGia = i.DonGia )
	BEGIN
		RAISERROR (N'Đơn giá không đúng tại thời điểm thêm/sửa', 16, 1)
		ROLLBACK
	END
END
GO
-- INSERT INTO DONTHUOC VALUES (1, 'T003', 5, 20)
-- UPDATE DONTHUOC SET DonGia = 20 WHERE MaDonThuoc = 1 AND MaThuoc = 'T001'

-- R4: INSERT, UPDATE DONTHUOC (SoLuong)
CREATE TRIGGER trgThem_CapNhatDonThuoc_SoLuong
ON DONTHUOC
FOR insert, update
AS
BEGIN
	IF EXISTS ( SELECT * 
				FROM inserted i, THUOC T 
				WHERE i.MaThuoc = T.MaThuoc
				AND T.TrangThai = 0)
	BEGIN
		RAISERROR (N'Thuốc đã bị xoá nên không thêm/sửa được', 16, 1)
		ROLLBACK
		RETURN
	END

	DECLARE @SL_deleted int = (SELECT SoLuong FROM deleted)
	IF @SL_deleted IS NULL
		SET @SL_deleted = 0
	IF EXISTS ( SELECT *
				FROM inserted i, THUOC T
				WHERE T.MaThuoc = i.MaThuoc
				AND (T.SoLuongTon - i.SoLuong + @SL_deleted) = 0 )
	BEGIN
		DECLARE @MaThuoc char(10) = (SELECT T.MaThuoc FROM inserted i, THUOC T WHERE i.MaThuoc = T.MaThuoc)
		UPDATE THUOC SET TrangThai = 0 WHERE MaThuoc = @MaThuoc
		
		PRINT N'Thuốc tự động xoá vì hết thuốc'
		RETURN
	END

	IF NOT EXISTS ( SELECT *
					FROM inserted i, THUOC T
					WHERE T.MaThuoc = i.MaThuoc
					AND (T.SoLuongTon - i.SoLuong + @SL_deleted) > 0 )
	BEGIN
		RAISERROR (N'Số lượng tồn của thuốc không đáp ứng được việc thêm/sửa số lượng thuốc trong đơn thuốc', 16, 1)
		ROLLBACK
		RETURN
	END
END
GO

-- INSERT INTO DONTHUOC VALUES (3, 'T002', 10, 2000)
-- UPDATE DONTHUOC SET SoLuong = 106 WHERE MaDonThuoc = 1 AND MaThuoc = 'T001'
-- UPDATE DONTHUOC SET SoLuong = 105 WHERE MaDonThuoc = 1 AND MaThuoc = 'T001'

-- R5 + R6:
----- INSERT LICHHEN (ThoiGianHen)
CREATE TRIGGER trgThemLichHen_TGHen
ON LICHHEN
FOR insert
AS
BEGIN
	DELETE LICHHEN WHERE MaLH = (SELECT MaLH FROM inserted)

	IF EXISTS (SELECT * FROM inserted WHERE dbo.f_KTLichHenHopLe(MaNhaSi, ThoiGianHen) = 0)
	BEGIN
		RAISERROR (N'Nha sĩ đã có lịch hẹn khác hoặc lịch bận cá nhân', 16, 1)
		ROLLBACK
	END
	DECLARE @MaLH int, @ThoiGianHen datetime, @SDT varchar(20), @MaNhaSi varchar(20)
	SELECT @MaLH = MaLH, @ThoiGianHen = ThoiGianHen, @SDT = SDT, @MaNhaSi = MaNhaSi
	FROM inserted
	INSERT INTO LICHHEN VALUES (@MaLH, @ThoiGianHen, @SDT, @MaNhaSi)
END
GO
----- INSERT, UPDATE LICHBAN (NgayGioBatDau, NgayGioKetThuc)
CREATE TRIGGER trgThem_CapNhatLichBan_NgayGio
ON LICHBAN
FOR insert, update
AS
BEGIN 
	IF EXISTS (SELECT * FROM inserted WHERE dbo.f_KTLichBanHopLe(MaNhaSi, NgayGioBatDau, NgayGioKetThuc) = 0)
	BEGIN
		RAISERROR (N'Nha sĩ đã có lịch hẹn với khách hàng', 16, 1)
		ROLLBACK
	END
END
GO