USE HQT_CSDL
GO

DECLARE @RT INT
--EXEC @RT = USP_TaoDonThuoc 5, 'Celpha' , 20
EXEC @RT = USP_TaoDonThuoc 2, 'Celpha' , 20

--DELETE FROM DONTHUOC WHERE MaDonThuoc = 5

IF @RT = 0
	PRINT N'TẠO ĐƠN THUỐC THẤT BẠI'
ELSE
	PRINT N'TẠO ĐƠN THUỐC THÀNH CÔNG'

SELECT * FROM tb_ThuocHienHanh()
