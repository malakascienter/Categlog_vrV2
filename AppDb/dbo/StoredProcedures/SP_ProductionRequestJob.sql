-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-03-14
-- Description:	Production Request Job SP
-- =============================================
create PROCEDURE [dbo].[SP_ProductionRequestJob]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CurrentDATE DATE,@StockItemID INT,@LocationID INT,@IssueQty MONEY,@QtyInHand MONEY,@ReOrderLevel MONEY,@ReOrderQty MONEY,@OrderQty MONEY,@PropertyId INT

	SELECT CompanyID
	INTO #TempCompanies
	FROM Companies

	WHILE EXISTS(SELECT 1 FROM #TempCompanies)
	BEGIN

	SELECT TOP(1) @PropertyId = CompanyID FROM #TempCompanies

	SELECT @CurrentDATE= [dbo].[FN_GetTransactionDate] (@PropertyId)

	--SET @CurrentDATE ='2022-09-06'

	SELECT	BT.PropertyId,LR.StockLocationID,  RD.StockItemCode,SUM(RD.Qty * IB.Qty * BT.Qty) AS IssueQty
	INTO #TempIssueItems
	FROM	RecipeDetails AS RD INNER JOIN RecipeHeader AS RH ON RD.RecipeCode = RH.RecipeCode AND RD.PropertyId = RH.PropertyId 
			INNER JOIN ItemBreakDown AS IB ON RH.RecipeCode = IB.RecipeCode AND IB.PropertyId = RH.PropertyId 
			INNER JOIN BillTrans AS BT ON IB.MainMenuCode = BT.MainMenuCode AND BT.PropertyId = IB.PropertyId 
			INNER JOIN Location_Ref AS LR ON BT.Outlet = LR.code AND LR.PropertyId = BT.PropertyId 
			INNER JOIN StockItemDetails AS SD ON RD.StockItemCode = SD.StockItemHeaderID AND SD.PropertyID = BT.PropertyId AND SD.LocationID = LR.StockLocationID
	WHERE	BT.PropertyId =  @PropertyId AND CONVERT(DATE, BT.OrderDate) =  CONVERT(DATE,@CurrentDATE) --and SD.IsActive = 1
	GROUP BY BT.PropertyId,LR.StockLocationID,  RD.StockItemCode

	WHILE EXISTS(SELECT 1 FROM #TempIssueItems)
	BEGIN

	SELECT TOP(1) @StockItemID =StockItemCode,@LocationID = StockLocationID ,@IssueQty = IssueQty FROM #TempIssueItems

	SELECT @ReOrderLevel=  ReOrderLevel, @ReOrderQty= ReOrderQuantity FROM StockItemDetails WHERE LocationID= @LocationID AND StockItemHeaderID = @StockItemID

	


	SELECT @QtyInHand =[dbo].[FN_GetStockInHand_Reatils](@PropertyId,@LocationID,@StockItemID)

	SELECT @QtyInHand= @QtyInHand -@IssueQty

	IF(@ReOrderLevel > @QtyInHand)
	BEGIN

	SELECT @OrderQty = (@ReOrderLevel - @QtyInHand )+ @ReOrderQty
	
	--SELECT 'Reorder',@ReOrderLevel ReOrderLevel,@QtyInHand QtyInHand,@OrderQty

	--INSERT INTO ProductionRequest(StockItemID, OrderQty, LocationID,PropertyID, IsCompleted, SysDate)
	--VALUES (@StockItemID,@OrderQty,@LocationID,@PropertyId,0,GETDATE())

	END
	DELETE TOP(1) FROM #TempIssueItems
	END
	DROP TABLE #TempIssueItems

	DELETE TOP(1) FROM #TempCompanies

	END
  DROP TABLE #TempCompanies
END

GO

