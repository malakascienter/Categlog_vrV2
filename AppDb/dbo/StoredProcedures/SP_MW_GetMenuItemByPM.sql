-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MW_GetMenuItemByPM]
	@Outlet VARCHAR(MAX),
	@TableNo VARCHAR(MAX),
	@PropertyId INT,
	@ItemCode VARCHAR(MAX)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @DefaultPriceType INT, @DefaultScanDineShowPriceTypeId INT
	SELECT @DefaultPriceType = DefaultPriceTypeId,@DefaultScanDineShowPriceTypeId = DefaultScanDineShowPriceTypeId  FROM Location_Ref WHERE PropertyId = @PropertyId AND code = @Outlet

	DECLARE @ScanDineResNetVal DECIMAL(18,6)
	SELECT @ScanDineResNetVal = ScanDineResNetVal FROM Companies WHERE CompanyID = @PropertyId


	IF( ISNULL(@ScanDineResNetVal,0) = 0 )
	BEGIN

	 SET @ScanDineResNetVal = 1

	END

	CREATE TABLE #TempScanDineItems
	(
		ItemCode        VARCHAR(MAX),
		Description     VARCHAR(MAX),
		Remark          VARCHAR(MAX),
		Price           DECIMAL(18, 2),
		ShowPrice       DECIMAL(18, 2),
		byteImageStr    VARCHAR(max),
		byteImage       image    
	);

	CREATE TABLE #TempScanDineItemsShowPrice
	(
		ItemCode        VARCHAR(MAX),
		Description     VARCHAR(MAX),
		Remark          VARCHAR(MAX),
		Price           DECIMAL(18, 2),
		ShowPrice       DECIMAL(18, 2),
		byteImageStr    VARCHAR(max),
		byteImage       image    
	);

	INSERT INTO #TempScanDineItems
	(
		ItemCode,
		Description,
		Remark,
		Price,
		ShowPrice,
		byteImageStr,
		byteImage
	)
	SELECT MM.ItemCode AS ItemCode,
	       MM.Description AS Description,
		   MM.FullName AS Remark,
		   (OP.Price * ISNULL(@ScanDineResNetVal,1)) AS Price,	
		   (OP.Price * ISNULL(@ScanDineResNetVal,1) ) AS ShowPrice,
		   --ISNULL((SELECT ''  FROM POS_Image IMG WHERE IMG.Code = MM.ItemCode AND IMG.PropertyId = MM.PropertyId AND IMG.DataType = 'ITM'),'https://cdn-icons-png.freepik.com/256/3859/3859777.png?semt=ais_hybrid') AS byteImageStr
		   'https://cdn-icons-png.freepik.com/256/3859/3859777.png?semt=ais_hybrid' AS byteImageStr,
		   (SELECT ItemImage  FROM POS_Image IMG WHERE IMG.Code = MM.ItemCode AND IMG.PropertyId = MM.PropertyId AND IMG.DataType = 'ITM') as byteImage
	FROM MainMenu MM
	INNER JOIN POS_OutletWiseMenuItems OM ON MM.ItemCode = OM.MenuCode AND MM.PropertyId = OM.PropertyId
	INNER JOIN POS_OutletWiseMenuItemPrice OP ON OP.MenuItemCode = OM.MenuCode AND OP.OutletCode = OM.OutletCode AND OP.PropertyId = OM.PropertyId
	INNER JOIN Category C ON MM.Category = C.Code AND MM.PropertyId = C.PropertyId
	WHERE MM.PreviousMenuCode = @ItemCode
	AND MM.PropertyId = @PropertyId AND OM.OutletCode = @Outlet AND OP.PriceTypeID = @DefaultPriceType
	--AND OP.Price > 0  
	and MM.IsScanDineItem = 1
	--and MM.ItemCode NOT IN (SELECT MMM.PreviousMenuCode FROM MainMenu MMM WHERE MMM.PropertyId = @PropertyId)


	INSERT INTO #TempScanDineItemsShowPrice
	(
		ItemCode,
		Description,
		Remark,
		Price,
		ShowPrice,
		byteImageStr,
		byteImage
	)
	SELECT MM.ItemCode AS ItemCode,
	       MM.Description AS Description,
		   MM.FullName AS Remark,
		   (OP.Price * ISNULL(@ScanDineResNetVal,1)) AS Price,	
		   (OP.Price * ISNULL(@ScanDineResNetVal,1) ) AS ShowPrice,
		   --ISNULL((SELECT ''  FROM POS_Image IMG WHERE IMG.Code = MM.ItemCode AND IMG.PropertyId = MM.PropertyId AND IMG.DataType = 'ITM'),'https://cdn-icons-png.freepik.com/256/3859/3859777.png?semt=ais_hybrid') AS byteImageStr
		   'https://cdn-icons-png.freepik.com/256/3859/3859777.png?semt=ais_hybrid' AS byteImageStr,
		   (SELECT ItemImage  FROM POS_Image IMG WHERE IMG.Code = MM.ItemCode AND IMG.PropertyId = MM.PropertyId AND IMG.DataType = 'ITM') as byteImage
	FROM MainMenu MM
	INNER JOIN POS_OutletWiseMenuItems OM ON MM.ItemCode = OM.MenuCode AND MM.PropertyId = OM.PropertyId
	INNER JOIN POS_OutletWiseMenuItemPrice OP ON OP.MenuItemCode = OM.MenuCode AND OP.OutletCode = OM.OutletCode AND OP.PropertyId = OM.PropertyId
	INNER JOIN Category C ON MM.Category = C.Code AND MM.PropertyId = C.PropertyId
	WHERE MM.PreviousMenuCode = @ItemCode
	AND MM.PropertyId = @PropertyId AND OM.OutletCode = @Outlet AND OP.PriceTypeID = @DefaultScanDineShowPriceTypeId
	--AND OP.Price > 0  
	and MM.IsScanDineItem = 1
	--and MM.ItemCode NOT IN (SELECT MMM.PreviousMenuCode FROM MainMenu MMM WHERE MMM.PropertyId = @PropertyId)


	UPDATE T1
	SET T1.ShowPrice = T2.ShowPrice
	FROM #TempScanDineItems T1 
	INNER JOIN   #TempScanDineItemsShowPrice T2 ON T1.ItemCode = T2.ItemCode


	UPDATE T1
	SET T1.ShowPrice = T1.Price
	FROM #TempScanDineItems T1 
	WHERE T1.Price > 0 AND T1.ShowPrice = 0


	select
	ItemCode,
	Description,
	Remark,
	Price,
	ShowPrice,
	byteImageStr,
	byteImage,
	[dbo].[IsExistsPreviousMenuItems](ItemCode,@PropertyId) AS IsExistsPreviousMenuItems
	from #TempScanDineItems


	drop table #TempScanDineItems
	drop table #TempScanDineItemsShowPrice
    
END

GO

