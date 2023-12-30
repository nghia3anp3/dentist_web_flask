﻿--Tao transaction
CREATE OR ALTER PROCEDURE USP_TaoDonThuoc
	@MaHoSo int, @TenThuoc char(30), @SoLuong int
AS
BEGIN TRAN
	BEGIN TRY
	-- Kiem tra ten thuoc ton tai trong kho hien hanh khong
		IF (@TenThuoc NOT IN (SELECT TenThuoc FROM tb_ThuocHienHanh()))
		BEGIN
			PRINT(N'Không tồn tại thuốc')
			ROLLBACK TRAN
			RETURN 0
		END

		-- Kiem tra so luong ton
		DECLARE @SoLuongTon int 
		SELECT @SoLuongTon = SoLuongTon FROM tb_ThuocHienHanh() WHERE TenThuoc = @TenThuoc

		IF (@SoLuong > @SoLuongTon)
		BEGIN
			PRINT(N'Vượt quá số lượng tồn')
			ROLLBACK TRAN
			RETURN 0
		END

		-- Kiem tra thong tin so luong khi nhap co am hay khong
		IF (@SoLuong < 0)
		BEGIN
			PRINT(N'Số lượng thuốc không hợp lệ')
			ROLLBACK TRAN
			RETURN 0
		END

		--TEST
		WAITFOR DELAY '0:0:05'

		--Them thuoc
		DECLARE @MaThuoc char(10), @DonGia int
		SELECT @MaThuoc = MaThuoc, @DonGia = DonGia FROM tb_ThuocHienHanh() WHERE TenThuoc = @TenThuoc

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
	BEGIN TRY
		DECLARE @MaThuoc char(10)
		DECLARE @SoLuongGoc int
		DECLARE @DonGia INT;
		DECLARE @SoLuongTon int 


		SELECT @SoLuongTon = SoLuongTon FROM THUOC WHERE TenThuoc = @TenThuoc
		SELECT @MaThuoc = MaThuoc FROM tb_ThuocHienHanh() WHERE TenThuoc = @TenThuoc
		--Kiem tra don thuoc co ton tai
		IF NOT EXISTS (SELECT * FROM DONTHUOC WHERE MaDonThuoc = @MaDonThuoc AND MaThuoc = @MaThuoc)
		BEGIN
			PRINT(N'Không tồn tại đơn thuốc')
			ROLLBACK TRAN
			RETURN 0
		END
		ELSE
		BEGIN
			SELECT @SoLuongGoc = SoLuong FROM DONTHUOC WHERE MaDonThuoc = @MaDonThuoc AND MaThuoc = @MaThuoc
		END


		--Kiem tra tinh hop le cua so luong thuoc
		IF (@SoLuong < 0)
		BEGIN
			PRINT(N'Số lượng thuốc không hợp lệ')
			ROLLBACK TRAN
			RETURN 0
		END
		
		-- Kiem tra so luong ton
		IF (@SoLuong - @SoLuongGoc > @SoLuongTon)
		BEGIN
			PRINT(N'Vượt quá số lượng tồn')
			ROLLBACK TRAN
			RETURN 0
		END
		--Cap nhat don thuoc
		UPDATE DONTHUOC SET SoLuong = @SoLuong WHERE MaDonThuoc = @MaDonThuoc AND MaThuoc = @MaThuoc

		IF (@SoLuong < @SoLuongGoc)
		BEGIN
			UPDATE THUOC SET SoLuongTon = SoLuongTon + (@SoLuongGoc - @SoLuong) WHERE MaThuoc = @MaThuoc
		END

		ELSE

		BEGIN
			UPDATE THUOC SET SoLuongTon = SoLuongTon - (@SoLuong - @SoLuongGoc) WHERE MaThuoc = @MaThuoc
		END

		/*SELECT @SoLuongTon = SoLuongTon FROM tb_ThuocHienHanh() WHERE TenThuoc = @TenThuoc
		PRINT(@SoLuong)
		PRINT(@SoLuongTon)
		IF (@SoLuong > @SoLuongTon)
				BEGIN
					PRINT('DAY NE')
					PRINT(N'LỖI HỆ THỐNG')
					PRINT ERROR_MESSAGE();
					ROLLBACK TRAN
					RETURN 0
				END
		*/

		SELECT @DonGia = DonGia FROM tb_ThuocHienHanh() WHERE MaThuoc = @MaThuoc;
		IF (@SoLuong < @SoLuongGoc)
		BEGIN
			UPDATE HOSOBENHAN SET TongTien = TongTien - (@SoLuongGoc - @SoLuong)* @DonGia  WHERE MaHoSo = @MaDonThuoc
		END

		ELSE
		BEGIN
			UPDATE HOSOBENHAN SET TongTien = TongTien + (@SoLuong - @SoLuongGoc)* @DonGia  WHERE MaHoSo = @MaDonThuoc
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