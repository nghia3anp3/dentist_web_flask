USE HQT_CSDL 
GO

CREATE OR ALTER PROCEDURE USP_TimThongTin_BangTen
    @HoTen nvarchar(50)
AS
BEGIN
-- SET TRAN ISOLATION LEVEL REPEATABLE READ
	BEGIN TRAN
    -- Kiem tra xem sdt co ton tai trong tai khoan khong
		IF @HoTen NOT IN (SELECT HoTen FROM NGUOIDUNG)
		BEGIN
			PRINT N'Không tồn tại trong danh sách tài khoản!'
			ROLLBACK TRAN
			RETURN 0
		END

    -- TEST
    WAITFOR DELAY '0:0:05'

		BEGIN TRY
		
			-- Lay thong tin nguoi dung can truy van de khoa tai khoan
			SELECT * FROM NGUOIDUNG WHERE HoTen = @HoTen
        
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
	 @SDT varchar(20), @HoTen nvarchar(30), @NgaySinh date, @DiaChi nvarchar(50), @MatKhau varchar(20)
AS
BEGIN
	BEGIN TRAN
		--Kiem tra SDT Co ton tai chua
		IF @SDT NOT IN (SELECT SDT FROM TAIKHOAN)
		BEGIN
			PRINT N'Số điện thoại này chưa được đăng kí!'
			ROLLBACK TRAN
			RETURN
		END
		--Cap nhat don thuoc
	BEGIN TRY
		IF (@HoTen <> '' AND @MatKhau <> '')
		BEGIN
			UPDATE NGUOIDUNG SET HoTen = @HoTen, NgaySinh = @NgaySinh, DiaChi = @DiaChi WHERE SDT = @SDT
			UPDATE TAIKHOAN SET MatKhau = @MatKhau WHERE SDT = @SDT
		END 
		
		ELSE
		BEGIN
			RAISERROR(N'Họ tên và Mật khẩu phải khác rỗng', 16, 1)
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
END
GO
