﻿USE HQT_CSDL
GO

--Trans tim thong tin bang so dien thoai
SELECT * FROM TAIKHOAN
---
DECLARE @RT INT
EXEC @RT = USP_TimThongTin_BangSDT '1111'

IF @RT = 1
	PRINT N'Đọc thành công'
ELSE
	PRINT N'Đọc thất bại'
---

select * from TAIKHOAN	
