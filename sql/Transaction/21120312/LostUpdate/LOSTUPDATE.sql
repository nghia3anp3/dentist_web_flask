USE HQT_CSDL
GO

CREATE OR ALTER PROCEDURE USP_TaoDonThuoc
	@MaHoSo int, @TenThuoc char(30), @SoLuong int
AS
SET TRAN ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN
	BEGIN TRY
		-- Kiem tra ten thuoc ton tai trong kho hien hanh khong
		IF (@TenThuoc NOT IN (SELECT TenThuoc FROM tb_ThuocHienHanh()))
		BEGIN	
			PRINT N'Thuốc không tồn tại trong kho hiện hành'
			ROLLBACK TRAN
			RETURN 0
		END

		-- Kiem tra so luong ton
		DECLARE @SoLuongTon int 
		SELECT @SoLuongTon = SoLuongTon FROM tb_ThuocHienHanh() WHERE TenThuoc = @TenThuoc

		IF (@SoLuong > @SoLuongTon)
		BEGIN
			PRINT N'Vượt quá số lượng tồn'
			ROLLBACK TRAN
			RETURN 0
		END

		-- Tao don thuoc
		PRINT N'TẠO ĐƠN'
		DECLARE @MaThuoc char(10), @DonGia int
		SELECT @MaThuoc = MaThuoc, @DonGia = DonGia FROM tb_ThuocHienHanh() WHERE TenThuoc = @TenThuoc

		WAITFOR DELAY '0:0:05'

		INSERT INTO DONTHUOC VALUES (@MaHoSo, @MaThuoc, @SoLuong, @DonGia)
		UPDATE THUOC SET SoLuongTon = @SoLuongTon - @SoLuong WHERE MaThuoc = @MaThuoc
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
