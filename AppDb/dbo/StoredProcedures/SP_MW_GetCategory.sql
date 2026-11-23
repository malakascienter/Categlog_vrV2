-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MW_GetCategory]
	@Outlet VARCHAR(5),
	@TableNo VARCHAR(10),
	@PropertyId INT,
	@CategoryCode VARCHAR(5)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @DefaultPriceType INT
	SELECT @DefaultPriceType = DefaultPriceTypeId
	FROM Location_Ref WHERE PropertyId = @PropertyId AND code = @Outlet


	CREATE TABLE #TempScanDineItems
	(
		ItemCode        VARCHAR(MAX)
	);
	INSERT INTO #TempScanDineItems
	(
		ItemCode		
	)
	SELECT MM.ItemCode AS ItemCode
	FROM MainMenu MM
	INNER JOIN POS_OutletWiseMenuItems OM ON MM.ItemCode = OM.MenuCode AND MM.PropertyId = OM.PropertyId
	INNER JOIN POS_OutletWiseMenuItemPrice OP ON OP.MenuItemCode = OM.MenuCode AND OP.OutletCode = OM.OutletCode AND OP.PropertyId = OM.PropertyId
	INNER JOIN Category C ON MM.Category = C.Code AND MM.PropertyId = C.PropertyId
	WHERE MM.PropertyId = @PropertyId AND OM.OutletCode = @Outlet AND OP.PriceTypeID = @DefaultPriceType
	AND OP.Price > 0  and MM.IsScanDineItem = 1



	SELECT C.CatgId AS Id,
	       C.Code,
		   C.Description AS Name
	FROM Category C
	WHERE C.Code = CASE WHEN @CategoryCode = '-999' THEN C.Code ELSE @CategoryCode END 
	AND C.PropertyId = @PropertyId 
	AND C.Code IN 
	(
		SELECT MM.Category 
		FROM MainMenu MM INNER JOIN #TempScanDineItems MT ON MM.ItemCode = MT.ItemCode
		WHERE MM.PropertyId = @PropertyId 
	)

	drop table #TempScanDineItems

END

GO

