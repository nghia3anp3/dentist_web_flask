USE HQT_CSDL
GO

DECLARE @RT INT
EXEC @RT = USP_TaoDonThuoc_ThatBai 5, 'Paracetamol' , 10
--EXEC @RT = USP_TaoDonThuoc_ThatBai 5, 'Delta' , 10

IF @RT = 0
	PRINT N'TẠO ĐƠN THUỐC THẤT BẠI'
ELSE
	PRINT N'TẠO ĐƠN THUỐC THÀNH CÔNG'

SELECT * FROM tb_ThuocHienHanh()
