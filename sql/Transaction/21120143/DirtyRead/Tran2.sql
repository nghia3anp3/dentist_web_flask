USE HQT_CSDL
GO

DECLARE @RT INT
EXEC @RT = USP_TaoDonThuoc_ThanhCong 6, 'Paracetamol' , 20
--EXEC @RT = USP_TaoDonThuoc_ThanhCong 5, 'Delta' , 20

IF @RT = 0
	PRINT N'TẠO ĐƠN THUỐC THẤT BẠI'
ELSE
	PRINT N'TẠO ĐƠN THUỐC THÀNH CÔNG'

SELECT * FROM tb_ThuocHienHanh() 
