USE HQT_CSDL
GO

CREATE OR ALTER PROCEDURE USP_TimThuocBangTen
				@TenThuoc VARCHAR(20)
AS 
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN
	DECLARE @SubName VARCHAR(23) = '%' + @TenThuoc + '%'

	IF NOT EXISTS (SELECT * FROM tb_ThuocHienHanh() WHERE TenThuoc LIKE @SubName)
	BEGIN
		PRINT N'Không tồn tại thuốc trong kho hiện hành'
        ROLLBACK TRAN
		RETURN 0
	END
	
	DECLARE @SoThuocTrungTen INT
	SELECT @SoThuocTrungTen = COUNT(*) FROM tb_ThuocHienHanh() WHERE TenThuoc LIKE @SubName
	SELECT @SoThuocTrungTen AS SoLuongThuocTimThay
	--PRINT N'Số lượng thuốc có một phần tên là "' + @TenThuoc + '": ' + CAST(@SoThuocTrungTen AS VARCHAR)

	--ĐỂ TEST
	WAITFOR DELAY '0:0:05'

	SELECT *
	FROM tb_ThuocHienHanh()
	WHERE TenThuoc LIKE @SubName
COMMIT TRAN
RETURN
GO

-------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE USP_ThemThuoc
	@TenThuoc char(30),	@DonGia int, @ChiDinh nvarchar(100), @SoLuongTon int, @NgayHetHan date
AS
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN
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
		PRINT N'Trùng tên với thuốc khác trong kho hiện hành'
        ROLLBACK TRAN
		RETURN 0
	END

	-- Kiem tra ngay het han co sau ngay them khong
	IF (@NgayHetHan <= CAST(GETDATE() AS date))
	BEGIN
		PRINT N'Ngày hết hạn phải sau ngày thêm'
        ROLLBACK TRAN
		RETURN 0
	END

	-- Them
	BEGIN TRY
		INSERT INTO THUOC(MaThuoc, TenThuoc, SoLuongTon, DonGia, NgayHetHan, ChiDinh) 
		VALUES (@MaThuoc, @TenThuoc, @SoLuongTon, @DonGia, @NgayHetHan, @ChiDinh)
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