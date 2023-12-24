USE HQT_CSDL 
GO

CREATE OR ALTER PROCEDURE USP_XoaThuoc
    @MaThuoc char(10)
AS
SET TRAN ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
    -- Kiem tra: thuoc co ton tai de xoa khong
    IF (@MaThuoc NOT IN (SELECT MaThuoc FROM tb_ThuocHienHanh()))
    BEGIN
        PRINT N'Mã thuốc không tồn tại trong kho hiện hành'
        RETURN 0
    END

    -- TEST
    WAITFOR DELAY '0:0:05'

    BEGIN TRY
        -- Xoa
        DECLARE @valid bit
        SELECT @valid = TrangThai FROM THUOC WHERE MaThuoc = @MaThuoc

        IF (@valid = 0)
        BEGIN
            PRINT N'Delete: 0 rows affected'
            ROLLBACK TRAN
            RETURN 0
        END

        UPDATE THUOC SET TrangThai = 0 WHERE MaThuoc = @MaThuoc

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
--------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE USP_SuaThongTinThuoc
    @MaThuoc char(10), @TenThuoc char(30),	@DonGia int, @ChiDinh nvarchar(100), @SoLuongTon int, @NgayHetHan date
AS
SET TRAN ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
    -- Kiem tra: thuoc can sua co ton tai trong kho hien hanh khong
    IF (@MaThuoc NOT IN (SELECT MaThuoc FROM tb_ThuocHienHanh()))
    BEGIN
        PRINT N'Mã thuốc không tồn tại trong kho hiện hành'
        ROLLBACK TRAN
        RETURN 0
    END

    -- Kiem tra: ten thuoc da ton tai trong bang hien hanh chua
    IF (@TenThuoc IN (SELECT MaThuoc FROM tb_ThuocHienHanh()))
    BEGIN
        PRINT N'Tên thuốc đã tồn tại trong kho hiện hành'
        ROLLBACK TRAN
        RETURN 0
    END

    -- Kiem tra: ngay het han co sau ngay sua khong
    IF (@NgayHetHan <= CAST(GETDATE() AS date))
    BEGIN
        PRINT N'Ngày hết hạn phải sau ngày sửa'
        ROLLBACK TRAN
        RETURN 0
    END

    BEGIN TRY
        -- Cap nhat
        UPDATE THUOC SET TenThuoc = @TenThuoc, SoLuongTon = @SoLuongTon, DonGia = @DonGia, NgayHetHan = @NgayHetHan, ChiDinh = @ChiDinh
        WHERE MaThuoc = @MaThuoc

        DECLARE @valid bit
        SELECT @valid = TrangThai FROM THUOC WHERE MaThuoc = @MaThuoc

        IF (@valid = 0)
        BEGIN
            PRINT N'Update: 0 rows affected'
            ROLLBACK TRAN
            RETURN 0
        END
        
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