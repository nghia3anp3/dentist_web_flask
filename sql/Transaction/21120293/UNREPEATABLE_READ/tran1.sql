USE HQT_CSDL
GO

--Tran tao don thuoc
SELECT * FROM TAIKHOAN
---
DECLARE @RT INT
EXEC @RT = USP_TimThongTin_BangSDT '564'

IF @RT = 1
	PRINT N'Đọc thành công'
ELSE
	PRINT N'Đọc thất bại'
---

select * from NGUOIDUNG	
SELECT * FROM TAIKHOAN
--DELETE FROM DONTHUOC WHERE MaDonThuoc = '6' AND MaThuoc = 'T004'