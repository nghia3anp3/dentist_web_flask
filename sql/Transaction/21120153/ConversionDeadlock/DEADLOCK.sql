USE HQT_CSDL 
GO

CREATE
-- ALTER
PROCEDURE USP_DatLichHen
    @SDT VARCHAR(20), @HoTen nvarchar(30), @NgaySinh varchar(15), @DiaChi nvarchar(50), 
	@NgayHen varchar(15), @GioHen varchar(15), @MaNhaSi VARCHAR(20)
AS  
SET TRAN ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
    DECLARE @NgayGioBD DATETIME = CONVERT(DATETIME, @NgayHen + ' ' + LEFT(@GioHen,2) + ':00')
    -- Kiem tra: ngay gio hen co bi trung khong (luu y: khong trung voi chinh no)
    IF (dbo.f_KTLichHenHopLe(@MaNhaSi, @NgayGioBD) = 0)
    BEGIN
        PRINT N'Nha sĩ đã có lịch hẹn hoặc lịch cá nhân'
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

    BEGIN TRY
        -- Them lich hen
        DECLARE @MaLH int = (SELECT ISNULL(MAX(MaLH),0) FROM LICHHEN) + 1
        INSERT INTO LICHHEN VALUES (@MaLH, @NgayGioBD, @SDT, @MaNhaSi)

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
		DECLARE @ErrorMsg VARCHAR(2000)
		SELECT @ErrorMsg = N'Lỗi: ' + ERROR_MESSAGE()
		RAISERROR(@ErrorMsg, 16, 1)
		ROLLBACK TRAN
		RETURN 0
	END CATCH
COMMIT TRAN
RETURN 1
GO
--------------------------------------------------------------------------------
CREATE
-- ALTER
PROCEDURE USP_CapNhatLichBan
    @MaNhaSi varchar(20), @MALB int, @NgayBDMoi varchar(20), @GioBDMoi varchar(20), @NgayKTMoi varchar(20), @GioKTMoi varchar(20)
AS
SET TRAN ISOLATION LEVEL SERIALIZABLE
BEGIN TRAN
    DECLARE @NgayGioBD_Moi DATETIME = CONVERT(DATETIME, @NgayBDMoi + ' ' + LEFT(@GioBDMoi,2) + ':00')
    DECLARE @NgayGioKT_Moi DATETIME = CONVERT(DATETIME, @NgayKTMoi + ' ' + LEFT(@GioKTMoi,2) + ':00')

    -- Kiem tra: lich muon cap nhat co hop le khong
    IF (dbo.f_KTLichBanHopLe(@MaNhaSi, @NgayGioBD_Moi, @NgayGioKT_Moi) = 0)
    BEGIN
        PRINT N'Đã có khách hàng đặt lịch hẹn'
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

    -- Kiem tra: ma lich ban phai ton tai
    IF NOT EXISTS (SELECT * FROM LICHBAN WHERE MALB = @MALB)
    BEGIN
        PRINT N'Lịch bận muốn cập nhật không tồn tại'
        ROLLBACK TRAN
        RETURN 0
    END
        
    BEGIN TRY
        -- Cap nhat
        UPDATE LICHBAN SET NgayGioBatDau = @NgayGioBD_Moi, NgayGioKetThuc = @NgayGioKT_Moi WHERE MALB = @MALB
        
    END TRY
	BEGIN CATCH
		DECLARE @ErrorMsg VARCHAR(2000)
		SELECT @ErrorMsg = N'Lỗi: ' + ERROR_MESSAGE()
		RAISERROR(@ErrorMsg, 16,1)
		ROLLBACK TRAN
		RETURN 0
	END CATCH
COMMIT TRAN
RETURN 1
GO