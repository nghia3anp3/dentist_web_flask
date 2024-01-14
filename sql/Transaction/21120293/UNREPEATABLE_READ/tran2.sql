USE HQT_CSDL
GO

--Tran tao sua so dien thoai
SELECT * FROM TAIKHOAN
---
DECLARE @RT INT
EXEC @RT = USP_SuaTT_SDT '564', '1111'

IF @RT = 1
	PRINT N'Sửa tài khoản thành công!'
ELSE
	PRINT N'Sửa tài khoản thất bại!'
---
SELECT * FROM TAIKHOAN
select * from NGUOIDUNG

