USE HQT_CSDL
GO

CREATE OR ALTER PROC USP_DangKiTaiKhoan
				@SDT varchar(10),
				@HoTen nvarchar(30),
				@NgaySinh DATE,
				@DiaChi nvarchar (50),
				@MatKhau varchar(20),
				@LoaiND varchar(10)
AS
SET TRAN ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
	--Kiem tra co TK voi loai nguoi dung tuong ung chua
	--Neu co thi tra ve 0
	IF EXISTS (SELECT * FROM TAIKHOAN WHERE SDT = @SDT AND @LoaiND = LoaiND)
	BEGIN
		PRINT @SDT + N' ĐÃ TỒN TẠI TÀI KHOẢN' 
		ROLLBACK TRAN
		RETURN 0
	END

	DECLARE @isSDTExist BIT = CASE 
						WHEN EXISTS(SELECT * FROM NGUOIDUNG WITH (TABLOCK) WHERE SDT = @SDT) THEN 1
						ELSE 0
					END

	WAITFOR DELAY '0:0:05'

	DECLARE @ErrorMsg VARCHAR(2000)

	--Neu chua co thong tin trong NGUOIDUNG thi them thong tin va tai khoan
	IF @isSDTExist = 0
	BEGIN
		DECLARE @NgaySinhDate date = CONVERT(DATE, @NgaySinh)

		BEGIN TRY
			INSERT INTO NGUOIDUNG VALUES (@SDT, @HoTen, @NgaySinhDate, @DiaChi)		
		END TRY

		BEGIN CATCH 
			SELECT @ErrorMsg = N'Lỗi: ' + ERROR_MESSAGE()
			RAISERROR(@ErrorMsg, 16,1)
			ROLLBACK TRAN
			RETURN 0
		END CATCH
	END

	
	BEGIN TRY
		INSERT INTO TAIKHOAN VALUES (@SDT, @LoaiND, @MatKhau, 1)
	END TRY

	BEGIN CATCH 
		SELECT @ErrorMsg = N'Lỗi: ' + ERROR_MESSAGE()
		RAISERROR(@ErrorMsg, 16,1)
		ROLLBACK TRAN
		RETURN 0
	END CATCH
COMMIT TRAN
RETURN 1
GO