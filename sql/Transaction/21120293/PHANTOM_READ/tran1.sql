USE HQT_CSDL
GO

--Tran tao don thuoc
SELECT * FROM tb_ThuocHienHanh()
SELECT * FROM DONTHUOC
---
DECLARE @RT INT
EXEC @RT = USP_TaoDonThuoc '6', N'Paracetamol', '100'

IF @RT = 1
	PRINT N'Tạo đơn thuốc thành công'
ELSE
	PRINT N'Tạo đơn thuốc thất bại'
---

select * from thuoc
SELECT * FROM tb_ThuocHienHanh()
--DELETE FROM DONTHUOC WHERE MaDonThuoc = '6' AND MaThuoc = 'T004'