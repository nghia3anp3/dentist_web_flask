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


--KIEM TRA TAI KHOAN DA TON TAI HAY CHUA
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

EXEC sp_LayHoaDonTuSDT '397'
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



use HQT_CSDL
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