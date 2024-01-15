USE HQT_CSDL 
GO

ALTER FUNCTION f_KTLichBanHopLe 
	(@MaNhaSi varchar(20), @NgayGioBD datetime, @NgayGioKT datetime)
RETURNS bit 
AS
BEGIN
    IF (@NgayGioBD > @NgayGioKT)
		RETURN 0

    -- Kiem tra trong LICHHEN cua @MaNhaSi co bi trung khong --
    DECLARE @DS_LICHHEN TABLE(MaLH int, ThoiGianHen datetime)
	INSERT INTO @DS_LICHHEN
		SELECT MaLH, ThoiGianHen
		FROM LICHHEN with (Updlock)
		WHERE MaNhaSi = @MaNhaSi
    
    DECLARE @SL_LICHHEN int
	SELECT @SL_LICHHEN = COUNT(*) FROM @DS_LICHHEN

    IF (@SL_LICHHEN = 0)
        RETURN 1

    DECLARE @i int, @MaLH int, @NgayKhamBD datetime, @NgayKhamKT datetime
    SET @i = 0

    WHILE (@i < @SL_LICHHEN)
	BEGIN
        SELECT TOP 1 @MaLH = MaLH, @NgayKhamBD = ThoiGianHen FROM @DS_LICHHEN
        SET @NgayKhamKT = DATEADD(hour, 1, @NgayKhamBD)
        
        IF (dbo.f_KTLichTrungNhau(@NgayKhamBD, @NgayKhamKT, @NgayGioBD, @NgayGioKT) = 1)
            RETURN 0

        SET @i = @i + 1
		DELETE @DS_LICHHEN WHERE MaLH = @MaLH
	END

    RETURN 1
END
GO

ALTER FUNCTION f_KTLichHenHopLe 
	(@MaNhaSi varchar(20), @NgayGioBD datetime)
RETURNS bit 
AS
BEGIN
    DECLARE @NgayGioKT datetime
	SET @NgayGioKT = DATEADD(hour, 1, @NgayGioBD)

    -- Kiem tra trong LICHHEN cua @MaNhaSi co bi trung khong --
	IF (dbo.f_KTLichBanHopLe (@MaNhaSi, @NgayGioBD, @NgayGioKT) = 0)
		RETURN 0
	
	-- Kiem tra trong LICHBAN cua @MaNhaSi co bi trung khong --
    DECLARE @DS_LICHBAN TABLE(MALB int, NgayGioBatDau datetime, NgayGioKetThuc datetime)
	INSERT INTO @DS_LICHBAN
		SELECT MALB, NgayGioBatDau, NgayGioKetThuc
		FROM LICHBAN
		WHERE MaNhaSi = @MaNhaSi
    
    DECLARE @SL_LICHBAN int
	SELECT @SL_LICHBAN = COUNT(*) FROM @DS_LICHBAN

    IF (@SL_LICHBAN = 0)
        RETURN 1

    DECLARE @i int, @MALB int, @NgayGioBD_Ban datetime, @NgayGioKT_Ban datetime
    SET @i = 0

    WHILE (@i < @SL_LICHBAN)
	BEGIN
        SELECT TOP 1 @MALB = MALB, @NgayGioBD_Ban = NgayGioBatDau, @NgayGioKT_Ban = NgayGioKetThuc FROM @DS_LICHBAN
        
        IF (dbo.f_KTLichTrungNhau(@NgayGioBD, @NgayGioKT, @NgayGioBD_Ban, @NgayGioKT_Ban) = 1)
            RETURN 0

        SET @i = @i + 1
		DELETE @DS_LICHBAN WHERE MALB = @MALB
	END

    RETURN 1
END
GO