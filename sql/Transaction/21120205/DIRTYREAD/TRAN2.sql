USE HQT_CSDL
GO

DECLARE @RT FLOAT
EXEC usp_nhasitaodonthuoc 7 , 'Paracetamol' , 6 , @RT OUT

PRINT N'SỐ Lượng thuốc còn lại ' + CAST(@RT AS VARCHAR(20))