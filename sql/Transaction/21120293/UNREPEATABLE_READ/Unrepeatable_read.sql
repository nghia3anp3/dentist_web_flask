USE HQT_CSDL 
GO

CREATE OR ALTER PROCEDURE USP_TimThongTin_BangSDT
    @SDT nvarchar(50)
AS
BEGIN
-- SET TRAN ISOLATION LEVEL REPEATABLE READ
	BEGIN TRAN
    -- Kiem tra xem sdt co ton tai trong tai khoan khong
		IF @SDT NOT IN (SELECT SDT FROM NGUOIDUNG)
		BEGIN
			PRINT N'Không tồn tại trong danh sách tài khoản!'
			ROLLBACK TRAN
			RETURN 0
		END

    -- TEST
    WAITFOR DELAY '0:0:05'

		BEGIN TRY
		
			-- Lay thong tin nguoi dung can truy van de khoa tai khoan
			SELECT * FROM NGUOIDUNG WHERE SDT = @SDT
        
		END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 0
	END CATCH
COMMIT TRAN
RETURN 1
END
GO
--------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE USP_SuaTT_SDT
	 @SDT varchar(20), @SDT_old varchar(20)
AS
BEGIN
	BEGIN TRAN
		--Kiem tra SDT Co ton tai chua
		IF @SDT IN (SELECT SDT FROM TAIKHOAN)
		BEGIN
			PRINT N'Số điện thoại này đã được đăng kí!'
			ROLLBACK TRAN
			RETURN
		END
		--Cap nhat don thuoc
	BEGIN TRY
		DECLARE @HoTen nvarchar(50), @NgaySinh date, @DiaChi nvarchar(50), @MatKhau varchar(20), @LoaiND varchar(20)
		SELECT @NgaySinh=NgaySinh, @HoTen=HoTen, @DiaChi=DiaChi FROM NGUOIDUNG WHERE SDT = @SDT_old

		INSERT INTO NGUOIDUNG VALUES (@SDT, @HoTen, @NgaySinh, @DiaChi)

		UPDATE TAIKHOAN SET SDT = @SDT WHERE SDT = @SDT_old
		UPDATE HOSOBENHAN SET SDT = @SDT WHERE SDT = @SDT_old

		DELETE FROM NGUOIDUNG WHERE SDT = @SDT_old

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
END
GO
