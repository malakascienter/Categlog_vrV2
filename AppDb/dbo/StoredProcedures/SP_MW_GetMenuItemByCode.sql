-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MW_GetMenuItemByCode]
	@Outlet VARCHAR(MAX),
	@TableNo VARCHAR(MAX),
	@PropertyId INT,
	@ItemCode VARCHAR(MAX)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @DefaultProceType INT, @DefaultScanDineShowPriceTypeId INT
	SELECT @DefaultProceType = DefaultPriceTypeId,@DefaultScanDineShowPriceTypeId = DefaultScanDineShowPriceTypeId  FROM Location_Ref WHERE PropertyId = @PropertyId AND code = @Outlet

	DECLARE @ScanDineResNetVal DECIMAL(18,6)
	SELECT @ScanDineResNetVal = ScanDineResNetVal FROM Companies WHERE CompanyID = @PropertyId

	IF( ISNULL(@ScanDineResNetVal,0) = 0 )
	BEGIN

	 SET @ScanDineResNetVal = 1

	END

	CREATE TABLE #TempTableDefaultPriceType
	(
		ItemCode     VARCHAR(MAX),
		Description  VARCHAR(MAX),
		Remark       VARCHAR(MAX),
		Price        DECIMAL(18, 2),
		ShowPrice    DECIMAL(18, 2)
	);

	CREATE TABLE #TempTableDefaultScanDineShowPriceType
	(
		ItemCode     VARCHAR(MAX),
		Description  VARCHAR(MAX),
		Remark       VARCHAR(MAX),
		Price        DECIMAL(18, 2),
		ShowPrice    DECIMAL(18, 2)
	);


	INSERT INTO #TempTableDefaultPriceType
	(
		ItemCode,
		Description,
		Remark,
		Price,
		ShowPrice
	)
	SELECT MM.ItemCode AS ItemCode,
	       MM.Description AS Description,
		   MM.FullName AS Remark,
		   (OP.Price * ISNULL(@ScanDineResNetVal,1)) AS Price,
		   (OP.Price * ISNULL(@ScanDineResNetVal,1) ) AS ShowPrice
	FROM MainMenu MM
	INNER JOIN POS_OutletWiseMenuItems OM ON MM.ItemCode = OM.MenuCode AND MM.PropertyId = OM.PropertyId
	INNER JOIN POS_OutletWiseMenuItemPrice OP ON OP.MenuItemCode = OM.MenuCode AND OP.OutletCode = OM.OutletCode AND OP.PropertyId = OM.PropertyId
	INNER JOIN Category C ON MM.Category = C.Code AND MM.PropertyId = C.PropertyId
	WHERE MM.ItemCode = @ItemCode
	AND MM.PropertyId = @PropertyId AND OM.OutletCode = @Outlet AND OP.PriceTypeID = @DefaultProceType


	INSERT INTO #TempTableDefaultScanDineShowPriceType
	(
		ItemCode,
		Description,
		Remark,
		Price,
		ShowPrice
	)
	SELECT MM.ItemCode AS ItemCode,
	       MM.Description AS Description,
		   MM.FullName AS Remark,
		   (OP.Price * ISNULL(@ScanDineResNetVal,1)) AS Price,
		   (OP.Price * ISNULL(@ScanDineResNetVal,1) ) AS ShowPrice
	FROM MainMenu MM
	INNER JOIN POS_OutletWiseMenuItems OM ON MM.ItemCode = OM.MenuCode AND MM.PropertyId = OM.PropertyId
	INNER JOIN POS_OutletWiseMenuItemPrice OP ON OP.MenuItemCode = OM.MenuCode AND OP.OutletCode = OM.OutletCode AND OP.PropertyId = OM.PropertyId
	INNER JOIN Category C ON MM.Category = C.Code AND MM.PropertyId = C.PropertyId
	WHERE MM.ItemCode = @ItemCode
	AND MM.PropertyId = @PropertyId AND OM.OutletCode = @Outlet AND OP.PriceTypeID = @DefaultScanDineShowPriceTypeId

	UPDATE T1
	SET T1.ShowPrice = T2.ShowPrice
	FROM #TempTableDefaultPriceType T1 
	INNER JOIN   #TempTableDefaultScanDineShowPriceType T2 ON T1.ItemCode = T2.ItemCode


	UPDATE T1
	SET T1.ShowPrice = T1.Price
	FROM #TempTableDefaultPriceType T1 
	WHERE T1.Price > 0 AND T1.ShowPrice = 0


	select
	ItemCode,
	Description,
	Remark,
	Price,
	ShowPrice,
	[dbo].[IsExistsPreviousMenuItems](ItemCode,@PropertyId) AS IsExistsPreviousMenuItems
	from #TempTableDefaultPriceType


	drop table #TempTableDefaultPriceType
	drop table #TempTableDefaultScanDineShowPriceType
    
END

GO

