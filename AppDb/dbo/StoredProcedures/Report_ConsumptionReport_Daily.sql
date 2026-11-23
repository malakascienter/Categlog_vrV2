-- =============================================
-- Author:		Chiraj
-- Create date: 2020-7-01
-- Description:	<Description,,>
-- =============================================
--Report_ConsumptionReport_Daily '01/07/2020','09/07/2020','S01,S02','2'
CREATE PROCEDURE [dbo].[Report_ConsumptionReport_Daily]
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
AS
BEGIN	
	SET NOCOUNT ON;

	SELECT	
	--BT.OrderNo,
	--BT.MainMenuCode,
	--BT.Qty,
	--BT.Rate,
	--IB.RecipeCode,
	--IB.Qty AS ItemBreakDownQty,
	----RD.StockItemCode,
	--RD.Unit,
	--RD.Qty AS RecipeQty,
	SH.StockItemCode,
	SH.Name AS StockItemName,
	OK.Quantity,
	U.Name AS Unit,
	OK.AveragePrice,
	IC.Name AS ItemCategory,
	L.code as outlet,
	L.description AS OutletName,
	OK.TxnDate
	--SD.AveragePrice as stockdetailavgPrice,
	--(RD.Qty*IB.Qty *BT.Qty )AS TotalQty,
	--U.Code,
	--L.description AS Outlet
	FROM  OutletKitchenIssues AS OK 
	--INNER JOIN ItemBreakDown AS IB  ON IB.MainMenuCode=BT.MainMenuCode AND BT.PropertyId=IB.PropertyId
	--INNER JOIN RecipeDetails AS RD ON IB.RecipeCode=RD.RecipeCode AND RD.PropertyId=IB.PropertyId
	INNER JOIN MainMenu AS MM ON MM.ItemCode=OK.MenuCode AND MM.PropertyId=OK.PropertyID
	INNER JOIN ItemCategory AS IC ON MM.ItemCategory=IC.Id AND  MM.PropertyId=IC.PropertyId
	INNER JOIN StockItemHeaders AS SH ON SH.Id=OK.StockItemID AND SH.CompanyId=OK.PropertyID
	--INNER JOIN StockItemDetails AS SD  ON SD.StockItemHeaderID=SH.Id AND SH.CompanyId=SD.CompanyID
	INNER join Units as U ON u.Id=OK.TxnUnitID --AND SD.CompanyID=U.CompanyId
	INNER join Location_Ref AS L ON L.code=OK.OutletCode AND L.PropertyId=OK.PropertyId
	 
	WHERE OK.TxnDate >= CONVERT(DATETIME,@FromDate,103) 
	AND OK.TxnDate <= CONVERT(DATETIME,@ToDate,103) 
	AND OK.OutletCode IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  AND OK.PropertyId=@PropertyId  --order by Bt.orderNo
    
	--SELECT *  FROM [Categlog_vrV2].[dbo].[Units]
	--select * from units
	--select * from StockItemDetails
	-- * from RecipeDetails
	--select * from ItemBreakDown
	--select * from StockItemHeaders
		
	


	
END

GO

