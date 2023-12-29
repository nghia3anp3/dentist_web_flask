USE HQT_CSDL 
GO

CREATE OR ALTER PROCEDURE USP_TimThuocBangMa
    @MaThuoc char(10)
AS
SET TRAN ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
    -- Kiem tra: thuoc can sua co ton tai trong kho thuoc khong
    IF @MaThuoc NOT IN (SELECT MaThuoc FROM tb_ThuocHienHanh())
    BEGIN
        PRINT N'Mã thuốc không tồn tại trong kho hiện hành'
        ROLLBACK TRAN
        RETURN
    END

    -- TEST
    WAITFOR DELAY '0:0:05'

    BEGIN TRY
        -- Lay thong tin thuoc can truy van de sua
        SELECT * FROM tb_ThuocHienHanh() WHERE MaThuoc = @MaThuoc
        
    END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
GO
--------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE USP_XoaThuoc
    @MaThuoc char(10)
AS
BEGIN TRAN
    -- Kiem tra: thuoc co ton tai de xoa khong
    IF @MaThuoc NOT IN (SELECT MaThuoc FROM tb_ThuocHienHanh())
    BEGIN
        PRINT N'Mã thuốc không tồn tại trong kho hiện hành'
        ROLLBACK TRAN
        RETURN 0
    END

    BEGIN TRY
        -- Xoa
        UPDATE THUOC SET TrangThai = 0 WHERE MaThuoc = @MaThuoc

    END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 0
	END CATCH
COMMIT TRAN
RETURN 1
GO