USE HQT_CSDL
GO
select * from tb_ThuocHienHanh()
DECLARE @RT INT
EXEC @RT = USP_TaoDonThuoc 15, 'Delta' , 10
--EXEC @RT = USP_TaoDonThuoc 6, 'Paracetamol' , 10

IF @RT = 0
	PRINT N'TẠO ĐƠN THUỐC THẤT BẠI'
ELSE
	PRINT N'TẠO ĐƠN THUỐC THÀNH CÔNG'

GO
select * from DONTHUOC
SELECT * FROM tb_ThuocHienHanh()
