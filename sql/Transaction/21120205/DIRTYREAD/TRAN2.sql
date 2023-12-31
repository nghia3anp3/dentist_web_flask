USE HQT_CSDL
GO

DECLARE @RT INT
EXEC @RT = USP_TaoDonThuoc 7 , 'Panadol' , 10 
PRINT N'SỐ Lượng thuốc còn lại ' + CAST(@RT AS VARCHAR(20))


