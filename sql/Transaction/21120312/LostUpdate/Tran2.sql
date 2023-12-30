USE HQT_CSDL
GO

DECLARE @RT INT
EXEC @RT = USP_TaoDonThuoc 5, 'Delta' , 30
--EXEC @RT = USP_TaoDonThuoc 5, 'Paracetamol' , 30

IF @RT = 0
	PRINT N'TẠO ĐƠN THUỐC THẤT BẠI'
ELSE
	PRINT N'TẠO ĐƠN THUỐC THÀNH CÔNG'

GO

SELECT * FROM tb_ThuocHienHanh()
