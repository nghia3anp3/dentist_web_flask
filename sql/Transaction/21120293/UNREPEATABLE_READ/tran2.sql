USE HQT_CSDL
GO

--Tran tao sua so luong
SELECT * FROM TAIKHOAN
---
DECLARE @RT INT
EXEC @RT = USP_SuaTT_SDT '1111', '564'

IF @RT = 1
	PRINT N'Sửa tài khoản thành công!'
ELSE
	PRINT N'Sửa tài khoản thất bại!'
---
SELECT * FROM TAIKHOAN
select * from NGUOIDUNG

