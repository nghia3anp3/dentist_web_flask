﻿USE HQT_CSDL
GO
---- T001 Paracetamol
SELECT * FROM tb_ThuocHienHanh() WHERE MaThuoc = 'T001'
--GO

DECLARE @RT INT
EXEC @RT =	USP_qtvupdatethuoc 'T001' , 10
IF @RT = 1