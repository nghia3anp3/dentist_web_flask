--Tao transaction
CREATE OR ALTER PROCEDURE USP_TaoDonThuoc
	@MaHoSo int, @TenThuoc char(30), @SoLuong int
AS
SET TRAN ISOLATION LEVEL Serializable
BEGIN TRAN
	-- Kiem tra ten thuoc ton tai trong kho hien hanh khong
		IF (@TenThuoc NOT IN (SELECT TenThuoc FROM tb_ThuocHienHanh()))
		BEGIN
			PRINT(N'Không tồn tại thuốc')
			ROLLBACK TRAN
			RETURN 0
		END

		-- Kiem tra so luong ton
		IF EXISTS (SELECT SoLuongTon
						FROM tb_ThuocHienHanh() as hh
						WHERE hh.TenThuoc = @TenThuoc AND  (@SoLuong - hh.SoLuongTon > 0))
		BEGIN
			PRINT(N'Vượt quá số lượng tồn')
			ROLLBACK TRAN
			RETURN 0
		END

		--TEST
		WAITFOR DELAY '0:0:05'

		--Them thuoc
	BEGIN TRY
		DECLARE @MaThuoc char(10), @SoLuongTon int, @DonGia int
		SELECT @MaThuoc = MaThuoc, @SoLuongTon = SoLuongTon, @DonGia = DonGia FROM tb_ThuocHienHanh() WHERE TenThuoc = @TenThuoc
		INSERT INTO DONTHUOC(MaDonThuoc, MaThuoc, SoLuong, DonGia) VALUES (@MaHoSo, @MaThuoc, @SoLuong, @DonGia)
		UPDATE THUOC SET SoLuongTon = @SoLuongTon - @SoLuong WHERE MaThuoc = @MaThuoc
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
CREATE OR ALTER PROCEDURE USP_SuaSoLuongThuoc_DonThuoc
	@MaDonThuoc char(5), @TenThuoc nvarchar(50), @SoLuong int
AS
BEGIN
BEGIN TRAN
		DECLARE @MaThuoc char(10)
		DECLARE @DonGia INT;
		declare @SoLuongGoc int

		select @MaThuoc = MaThuoc From tb_ThuocHienHanh() where TenThuoc = @TenThuoc
		select @SoLuongGoc = SoLuong FROM DONTHUOC WHERE MaDonThuoc = @MaDonThuoc AND MaThuoc = @MaThuoc

		--Kiem tra don thuoc co ton tai
		IF NOT EXISTS (SELECT * FROM DONTHUOC WHERE MaDonThuoc = @MaDonThuoc AND MaThuoc = @MaThuoc)
		BEGIN
			PRINT(N'Không tồn tại đơn thuốc')
			ROLLBACK TRAN
			RETURN 0
		END
		
		--Cap nhat don thuoc
	BEGIN TRY
		UPDATE DONTHUOC SET SoLuong = @SoLuong WHERE MaDonThuoc = @MaDonThuoc AND MaThuoc = @MaThuoc

		IF (@SoLuong < @SoLuongGoc)
		BEGIN
			UPDATE THUOC SET SoLuongTon = SoLuongTon + (@SoLuongGoc - @SoLuong) WHERE MaThuoc = @MaThuoc
		END

		ELSE
		BEGIN
			UPDATE THUOC SET SoLuongTon = SoLuongTon - (@SoLuong - @SoLuongGoc) WHERE MaThuoc = @MaThuoc
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
