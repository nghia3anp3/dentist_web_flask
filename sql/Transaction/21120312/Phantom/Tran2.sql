USE HQT_CSDL
GO

DECLARE @RT INT
EXEC @RT = USP_ThemThuoc 'Pelt' , 10000, N'Không có', 100, '2025-01-01'
--EXEC @RT = USP_ThemThuoc 'Telt' , 10000, N'Không có', 100, '2025-01-01'

IF @RT = 0
	PRINT N'THÊM THUỐC MỚI THẤT BẠI'
ELSE
	PRINT N'THÊM THUỐC MỚI THÀNH CÔNG'

GO

--SELECT * FROM tb_ThuocHienHanh()
