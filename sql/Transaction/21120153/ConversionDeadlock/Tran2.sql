USE HQT_CSDL
GO

SELECT * FROM LICHBAN
---
DECLARE @RT INT
-- EXEC @RT = USP_CapNhatLichBan '397', 1, '2023-12-02', '12:00', '2023-12-02', '14:00'
EXEC @RT = USP_CapNhatLichBan '397', 1, '2024-01-20', '13:00', '2024-01-20', '15:00'
IF @RT = 0
	PRINT N'Cập nhật thất bại'
ELSE
	PRINT N'Cập nhật thành công'
---
SELECT * FROM LICHBAN
-- UPDATE LICHBAN SET NgayGioBatDau = '2023-12-02 05:00:00', NgayGioKetThuc = '2023-12-02 07:00:00' WHERE MALB = 1