USE HQT_CSDL
GO
---- T001 Paracetamol
SELECT * FROM tb_ThuocHienHanh() WHERE MaThuoc = 'T001'
--GO

DECLARE @RT INT
EXEC @RT =	USP_qtvupdatethuoc 'T001' , 10
IF @RT = 1	PRINT N'CẬP NHẬT THẤT BẠI'ELSE	PRINT N'CẬP NHẬT THÀNH CÔNG'SELECT * FROM tb_ThuocHienHanh() WHERE MaThuoc = 'T001'
