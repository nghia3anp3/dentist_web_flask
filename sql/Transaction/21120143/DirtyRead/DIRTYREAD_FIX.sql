USE HQT_CSDL
GO

CREATE OR ALTER PROCEDURE USP_TaoDonThuoc
	@MaHoSo int, @TenThuoc char(30), @SoLuong int
AS
--SET TRAN ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN
	BEGIN TRY
		-- Kiem tra ten thuoc ton tai trong kho hien hanh khong
		IF (@TenThuoc NOT IN (SELECT TenThuoc FROM THUOC WHERE TrangThai = 1 AND SoLuongTon > 0))
		BEGIN
			PRINT N'Thuốc không tồn tại trong kho hiện hành'
			ROLLBACK TRAN
			RETURN 0
		END

		-- Kiem tra so luong ton
		DECLARE @SoLuongTon int 
		SELECT @SoLuongTon = SoLuongTon FROM THUOC WHERE TrangThai = 1 AND SoLuongTon > 0 AND TenThuoc = @TenThuoc

		IF (@SoLuong > @SoLuongTon)
		BEGIN
			PRINT N'Vượt quá số lượng tồn'
			ROLLBACK TRAN
			RETURN 0
		END

		-- Tao don thuoc
		DECLARE @MaThuoc char(10), @DonGia int
		SELECT @MaThuoc = MaThuoc, @DonGia = DonGia FROM THUOC WHERE TrangThai = 1 AND SoLuongTon > 0 AND TenThuoc = @TenThuoc

		UPDATE THUOC SET SoLuongTon = @SoLuongTon - @SoLuong WHERE MaThuoc = @MaThuoc

		WAITFOR DELAY '0:0:05'
		
		--insert một đơn thuốc làm rollback là oke
		INSERT INTO DONTHUOC VALUES (@MaHoSo, @MaThuoc, @SoLuong, @DonGia)
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