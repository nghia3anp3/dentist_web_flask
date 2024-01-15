USE HQT_CSDL
GO

DECLARE @RT INT
EXEC @RT = USP_TimThuocBangTen 'el'

--SELECT * FROM tb_ThuocHienHanh()