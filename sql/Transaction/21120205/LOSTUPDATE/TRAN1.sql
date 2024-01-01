USE HQT_CSDL
GO
--- B1 :
SELECT * FROM tb_ThuocHienHanh() WHERE MaThuoc = 'T003'

------------------------------------
----- B2 :
DECLARE @RT BIT
exec @RT = USP_updatethuoc1 'T003' , 10
IF @RT = 1
	PRINT N'Cập nhật số lượng thuốc thất bại'
ELSE
	PRINT N'Cập nhật số lượng thuốc thành công'
---
SELECT * FROM tb_ThuocHienHanh() WHERE MaThuoc = 'T003'
