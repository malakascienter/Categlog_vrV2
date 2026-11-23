-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 04 September 2023
-- Description: Non Moiving Item Report
-- [dbo].[SP_NonMovingItems] 1,-999,'2024/03/01','2024/03/04',-999
-- =============================================
CREATE PROCEDURE [dbo].[SP_NonMovingItems]
	@PropertyID INT,
	@LocationID INT,
	@FromDate DATETIME,
	@ToDate DATETIME,
	@CategoryId INT
AS
BEGIN
	SET NOCOUNT ON;


	SELECT SH.StockItemCode,SH.ID StockItemID,SH.Name ItemName, SD.QuantityInHand,U.Name UnitName,SD.AveragePrice,CA.Name CategoryName
	,[dbo].[GetBalance_Retail](@FromDate,SH.Id,SD.LocationID,1,0,@PropertyID) Balance
	,[dbo].[FN_GetLastGRNDate](SH.ID,SD.LocationID,@ToDate) LastGRNDate
	INTO #TempNonMovingItems
	FROM StockItemHeaders SH
	INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID
	INNER JOIN Units U ON U.Id = SD.MasterUnitID
	INNER JOIN Categories CA ON CA.Id = SH.CategoryID
	WHERE --SD.QuantityInHand >0 AND Commented by Isuru for getting stockbalance on @fromDate
	SH.CompanyId =@PropertyID 
	AND SD.LocationID = CASE WHEN @LocationID = -999 THEN SD.LocationID ELSE @LocationID END
	AND SH.CategoryID = CASE WHEN @CategoryId = -999 THEN SH.CategoryID ELSE @CategoryId END



	SELECT *
	FROM #TempNonMovingItems
	WHERE StockItemID NOT IN (SELECT StockItemID FROM StockTransactionDetails WHERE CreatedDate BETWEEN @FromDate AND @ToDate)
	AND Balance>0




END

GO

