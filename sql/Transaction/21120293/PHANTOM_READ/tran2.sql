USE HQT_CSDL
GO

--Tran tao sua so luong
SELECT * FROM DONTHUOC
---
DECLARE @RT INT
EXEC @RT = USP_SuaSoLuongThuoc_DonThuoc '1', N'Paracetamol', '105'

IF @RT = 1
	PRINT N'Sửa đơn thuốc thành công'
ELSE
	PRINT N'Sửa đơn thuốc thất bại'
---
SELECT * FROM DONTHUOC

