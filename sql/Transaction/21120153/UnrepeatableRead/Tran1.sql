USE HQT_CSDL
GO

SELECT * FROM LICHHEN
---
DECLARE @RT INT
EXEC @RT = USP_DatLichHen '123', N'Nguyễn Văn A', '2003-11-02', N'Bảo Lộc, Lâm Đồng', '2024-04-20', '14:00', '397'
IF @RT = 0
	PRINT N'Đặt lịch hẹn thất bại'
ELSE
	PRINT N'Đặt lịch hẹn thành công'
---
SELECT * FROM LICHHEN
-- DELETE FROM LICHHEN WHERE MaLH = 7