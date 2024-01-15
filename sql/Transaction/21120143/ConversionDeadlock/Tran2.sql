USE HQT_CSDL
GO

DECLARE @RT INT
EXEC @RT = USP_DangKiTaiKhoan '111', N'Nguyễn Thị B', '2001-02-02', N'Thủ Đức, Hồ Chí Minh', '123', 'Khach'
--EXEC @RT = USP_DangKiTaiKhoan '333', N'Nguyễn Thị C', '2001-02-02', N'Thủ Đức, Hồ Chí Minh', '123', 'Khach'

IF @RT = 1
	PRINT N'TẠO TÀI KHOẢN THÀNH CÔNG'
ELSE
	PRINT N'TẠO TÀI KHOẢN KHÔNG THÀNH CÔNG'

--SELECT * FROM TAIKHOAN
--SELECT * FROM NGUOIDUNG