USE HQT_CSDL
GO

-------------B1 :
--- SELECT * FROM THUOC with (Updlock) WHERE TenThuoc = 'Paracetamol'
---SELECT * FROM THUOC  WHERE TenThuoc = 'Paracetamol'

DECLARE @RT BIT
exec @RT = sp_TaoDonThuoc1 '7' , 'Paracetamol' , 10
IF @RT = 1
	PRINT N'Tạo đơn thuốc thất bại'
ELSE
	PRINT N'Tạo đơn thuốc thành công'

SELECT * FROM tb_ThuocHienHanh() WHERE TenThuoc = 'Paracetamol'


