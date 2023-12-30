USE HQT_CSDL
GO

SELECT * FROM tb_ThuocHienHanh()
---
DECLARE @RT INT
-- EXEC @RT = USP_ThemThuoc 'Alaxan', 7000, N'Thuốc giảm đau kháng viêm', 100, '2025-12-30'
EXEC @RT = USP_XoaThuoc 'T001'
IF @RT = 0
	PRINT N'Xoá thất bại'
ELSE
	PRINT N'Xoá thành công'
---
SELECT * FROM tb_ThuocHienHanh()
-- UPDATE THUOC SET TrangThai = 1 WHERE MaThuoc = 'T001'