USE HQT_CSDL
GO
---
DECLARE @RT INT
EXEC @RT = USP_SuaThongTinThuoc 'T001', 'Cilzec', 8000, N'Thuốc điều trị cao huyết áp', 100, '2025-12-30'
IF @RT = 0
	PRINT N'Sửa thất bại'
ELSE
	PRINT N'Sửa thành công'
---
SELECT * FROM THUOC
-- EXEC sp_SuaThongTinThuoc 'T001', 'Paracetamol', 10000, N'Thuốc giảm đau hạ sốt', 100, '2025-12-30'