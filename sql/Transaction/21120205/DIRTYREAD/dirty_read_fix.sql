USE HQT_CSDL
GO

CREATE OR ALTER PROCEDURE USP_qtvupdatethuoc 
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
		SELECT @SoLuongTon = SoLuongTon FROM THUOC WHERE MaThuoc = @MaThuoc
		IF (@SoLuongTon -  @LuongThuocThayDoi < 0 )
		BEGIN
			PRINT N'VUOT QUA SO LUONG THUOC CON LAI CO TRONG KHO'
			ROLLBACK TRAN
			RETURN 1
		END

		UPDATE THUOC SET  SoLuongTon = @SoLuongTon -  @LuongThuocThayDoi  WHERE  MaThuoc = @MaThuoc
		--ĐỂ TEST
		WAITFOR DELAY '0:0:05'
		ROLLBACK TRAN 
		RETURN 1

	 END TRY
	BEGIN CATCH
		DECLARE @ErrorMsg VARCHAR(2000)
		SELECT @ErrorMsg = N'Lỗi: ' + ERROR_MESSAGE()
		RAISERROR(@ErrorMsg, 16,1)
		ROLLBACK TRAN
		RETURN 1
	END CATCH
COMMIT TRAN
RETURN 0

GO

CREATE OR ALTER PROC usp_nhasitaodonthuoc
	@MaHoSo int, @TenThuoc char(30), @SoLuong int , @THUOCCONLAI INT OUT
AS
--SET TRAN ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRAN
	BEGIN TRY
		
	-- Kiem tra ten thuoc ton tai trong kho hien hanh khong
		IF (@TenThuoc NOT IN (SELECT TenThuoc FROM tb_ThuocHienHanh()))
		BEGIN
			PRINT N'Không tồn tại thuốc ' + @TenThuoc
			ROLLBACK TRAN
			RETURN 1
		END

	-- Kiem tra so luong ton
		DECLARE @SoLuongTon int 
		SELECT @SoLuongTon = SoLuongTon FROM tb_ThuocHienHanh() WHERE TenThuoc = @TenThuoc

		IF (@SoLuong > @SoLuongTon)
		BEGIN
			PRINT N'Vượt quá số lượng tồn'
			RETURN 1
		END

	-- Tao don thuoc
		DECLARE @MaThuoc char(10), @DonGia int
		SELECT @MaThuoc = MaThuoc, @DonGia = DonGia FROM tb_ThuocHienHanh() WHERE TenThuoc = @TenThuoc


		SET @THUOCCONLAI = @SoLuongTon - @SoLuong

	END TRY	BEGIN CATCH		PRINT N'LỖI HỆ THỐNG'		ROLLBACK TRAN	END CATCHCOMMIT TRANRETURN 0