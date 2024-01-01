USE HQT_CSDL
GO

--Tran tao sua so luong
SELECT * FROM TAIKHOAN
---
DECLARE @RT INT
EXEC @RT = USP_SuaTT_SDT '564', N'Lê Nguyễn Trọng Nghĩa', '2003-04-18', N'Bảo Lộc, Lâm Đồng', 'Nghia'

IF @RT = 1
	PRINT N'Sửa tài khoản thành công!'
ELSE
	PRINT N'Sửa tài khoản thất bại!'
---
SELECT * FROM TAIKHOAN
select * from NGUOIDUNG

