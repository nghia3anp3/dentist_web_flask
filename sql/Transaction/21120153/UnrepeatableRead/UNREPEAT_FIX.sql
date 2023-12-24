USE HQT_CSDL 
GO

CREATE OR ALTER PROCEDURE USP_DatLichHen
    @SDT VARCHAR(20), @HoTen nvarchar(30), @NgaySinh varchar(15), @DiaChi nvarchar(50), 
	@NgayHen varchar(15), @GioHen varchar(15), @MaNhaSi VARCHAR(20)
AS  
SET TRAN ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
    BEGIN TRY
        DECLARE @NgayGioBD DATETIME = CONVERT(DATETIME, @NgayHen + ' ' + LEFT(@GioHen,2) + ':00')
        -- Kiem tra: nha si nam trong danh sach nha si ranh
        IF @MaNhaSi NOT IN (SELECT SDT FROM tb_TimNhaSiRanh(@NgayHen, @GioHen))
        BEGIN 
            PRINT N'Nha sĩ đã có lịch hẹn hoặc lịch bận cá nhân'
            ROLLBACK TRAN
            RETURN 0
        END

        -- Kiem tra: ngay hen phai sau ngay hien tai (ngay dat)
        IF (@NgayGioBD <= CAST(GETDATE() AS date))
        BEGIN
            PRINT N'Ngày hẹn phải sau ngày đặt lịch'
            ROLLBACK TRAN
            RETURN 0
        END

        -- Kiem tra: nha si phai ton tai
        IF NOT EXISTS (SELECT * FROM TAIKHOAN WHERE SDT = @MaNhaSi AND LoaiND = 'BacSi')
        BEGIN
            PRINT N'Nha sĩ không tồn tại'
            ROLLBACK TRAN
            RETURN 0
        END

        -- TEST
		WAITFOR DELAY '0:0:05'

        -- Kiem tra: ngay gio hen co bi trung khong (luu y: khong trung voi chinh no)
        DECLARE @NgayGioHen DATETIME = CONVERT(DATETIME, @NgayHen + ' ' + LEFT(@GioHen,2) + ':00')
        IF (dbo.f_KTLichHenHopLe(@MaNhaSi, @NgayGioHen) = 0)
        BEGIN
            PRINT N'Lịch không hợp lệ'
            ROLLBACK TRAN
            RETURN 0
        END

        -- Them lich hen
        DECLARE @MaLH int = (SELECT ISNULL(MAX(MaLH),0) FROM LICHHEN) + 1
        INSERT INTO LICHHEN VALUES (@MaLH, @NgayGioBD, @SDT, @MaNhaSi, 0)

        -- Them thong tin nguoi dung neu chua co
        DECLARE @isSDTExist BIT
        EXEC @isSDTExist = sp_KiemTraSdtTonTai @SDT

        IF (@IsSdtExist = 0)
        BEGIN
            DECLARE @NgaySinhDateTime DATE = CONVERT(DATE, @NgaySinh)
            INSERT INTO NGUOIDUNG VALUES (@SDT,@HoTen,@NgaySinhDateTime,@DiaChi)
        END

    END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 0
	END CATCH
COMMIT TRAN
RETURN 1
GO
--------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE USP_CapNhatLichBan
    @MaNhaSi varchar(20), @MALB int, @NgayBDMoi varchar(20), @GioBDMoi varchar(20), @NgayKTMoi varchar(20), @GioKTMoi varchar(20)
AS
BEGIN TRAN
    BEGIN TRY
        DECLARE @NgayGioBD_Moi DATETIME = CONVERT(DATETIME, @NgayBDMoi + ' ' + LEFT(@GioBDMoi,2) + ':00')
        DECLARE @NgayGioKT_Moi DATETIME = CONVERT(DATETIME, @NgayKTMoi + ' ' + LEFT(@GioKTMoi,2) + ':00')
        
        -- Kiem tra: nha si phai ton tai
        IF NOT EXISTS (SELECT * FROM TAIKHOAN WHERE SDT = @MaNhaSi AND LoaiND = 'BacSi')
        BEGIN
            PRINT N'Nha sĩ không tồn tại'
            ROLLBACK TRAN
            RETURN 0
        END

        -- Kiem tra: ma lich ban phai ton tai
        IF NOT EXISTS (SELECT * FROM LICHBAN WHERE MALB = @MALB)
        BEGIN
            PRINT N'Lịch bận muốn cập nhật không tồn tại'
            ROLLBACK TRAN
            RETURN 0
        END
        
        -- Cap nhat
        UPDATE LICHBAN SET NgayGioBatDau = @NgayGioBD_Moi, NgayGioKetThuc = @NgayGioKT_Moi WHERE MALB = @MALB

        -- Kiem tra: lich muon cap nhat co hop le khong
        IF (dbo.f_KTLichBanHopLe(@MaNhaSi, @NgayGioBD_Moi, @NgayGioKT_Moi) = 0)
        BEGIN
            PRINT N'Lịch không hợp lệ'
            ROLLBACK TRAN
            RETURN 0
        END
        
    END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 0
	END CATCH
COMMIT TRAN
RETURN 1
GO