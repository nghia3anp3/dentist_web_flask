USE HQT_CSDL
GO

---- 1 la loi , 0 la thanh cong
CREATE OR ALTER PROCEDURE USP_updatethuoc1 
@MaThuoc char(10), @LuongThuocThayDoi int
AS
BEGIN TRAN
	BEGIN TRY
	-- Kiem tra thuoc co ton tai de sua khong
		IF (@MaThuoc NOT IN (SELECT MaThuoc FROM tb_ThuocHienHanh()))
		BEGIN
			PRINT N'Mã thuốc không tồn tại trong kho hiện hành'
			ROLLBACK TRAN
			RETURN 1
		END
	-- Cap nhat

		DECLARE @SoLuongTon int
		SELECT @SoLuongTon = SoLuongTon FROM THUOC with (Updlock) WHERE MaThuoc = @MaThuoc

		IF (@SoLuongTon -  @LuongThuocThayDoi < 0 )
		BEGIN
			PRINT N'VUOT QUA SO LUONG THUOC CON LAI CO TRONG KHO'
			ROLLBACK TRAN
			RETURN 1
		END

		--ĐỂ TEST
		--- DOC SO LUONG TON TRUOC DE DI KIEM TRA XEM SO LUONG toN CO ON KHONG
		WAITFOR DELAY '0:0:05'
		UPDATE THUOC SET  SoLuongTon = @SoLuongTon -  @LuongThuocThayDoi  WHERE  MaThuoc = @MaThuoc
		
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



CREATE OR ALTER PROCEDURE sp_TaoDonThuoc1 
	@MaHoSo int, @TenThuoc char(30), @SoLuong int
AS
BEGIN TRAN
	BEGIN TRY
	-- Kiem tra ten thuoc ton tai trong kho hien hanh khong
		IF (@TenThuoc NOT IN (SELECT TenThuoc FROM tb_ThuocHienHanh()))
		BEGIN
			PRINT N'Không tồn tại thuốc'
			ROLLBACK TRAN
			RETURN 1
		END

		-- Kiem tra so luong ton
		DECLARE @SoLuongTon int 
		SELECT @SoLuongTon = SoLuongTon FROM THUOC with (Updlock) WHERE TenThuoc = @TenThuoc

		IF (@SoLuong > @SoLuongTon)
		BEGIN
			PRINT 'Vượt quá số lượng tồn'
			ROLLBACK TRAN
			RETURN 1
		END

		-- Tao don thuoc
		DECLARE @MaThuoc char(10), @DonGia int
		SELECT @MaThuoc = MaThuoc, @DonGia = DonGia FROM tb_ThuocHienHanh() WHERE TenThuoc = @TenThuoc

		UPDATE THUOC SET SoLuongTon = @SoLuongTon - @SoLuong WHERE MaThuoc = @MaThuoc
	END TRY
	BEGIN CATCH
		PRINT N'LỖI HỆ THỐNG'
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0