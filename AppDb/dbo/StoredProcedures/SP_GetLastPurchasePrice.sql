-- =============================================
-- Author:		[dbo].[SP_GetLastPurchaseDetails]
-- Create date: 2023 september 04
-- Description:	Last Purchase Prices Report
-- [dbo].[SP_GetLastPurchasePrice] 1,30,-999,-999,-999,-999,'2025/11/22'

-- =============================================
CREATE PROCEDURE [dbo].[SP_GetLastPurchasePrice]
	@PropertyID INT,
	@LocationID INT,
	@StockItemID INT,
	@CategoryId INT,
	@SubCategoryId INT,
	@SubCategory2Id INT,
	@Date DATETIME

AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#TempLastPurchaseTable2') IS NOT NULL
	begin
        drop table #TempLastPurchaseTable2
	end
	IF OBJECT_ID('tempdb..#TempLastTransaction') IS NOT NULL
	begin
        drop table #TempLastTransaction
	end

	DECLARE @StockItemCode VARCHAR(50), @LocationID2 INT

	--CREATE TABLE #TempLastPurchaseTable2(
	--StockItemCode NVARCHAR(50),
	--ItemName NVARCHAR(MAX),
	--UnitName NVARCHAR(MAX),
	--UnitPrice DECIMAL(18,6),
	--BalanceQty DECIMAL(18,6),
	--CreatedDate DATETIME,
	--LocationName NVARCHAR(MAX),
	--LocationID INT,
	--CategoryName NVARCHAR(MAX),
	--TransactionDate DATE)  



	SELECT SD.StockItemID,L.Id LocationId,max(SD.Id) DetailsId
	INTO #TempLastTransaction
	FROM StockTransactionHeaders SH
	INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID
	INNER JOIN StockItemHeaders ST ON ST.Id = SD.StockItemID
	INNER JOIN Categories C ON C.Id = ST.CategoryID
	INNER JOIN Units U ON U.Id = SD.MasterUnitID
	INNER JOIN Locations L ON L.Id =SH.LocationID 
	WHERE SH.CreatedDate < @Date AND SH.TransactionType='GR' 
	AND SH.PropertyID = CASE WHEN @PropertyID = -999 THEN SH.PropertyID ELSE @PropertyID END
	AND SH.LocationID = CASE WHEN @LocationID = -999 THEN SH.LocationID ELSE @LocationID END
	AND SD.StockItemID = CASE WHEN @StockItemID = -999 THEN SD.StockItemID ELSE @StockItemID END
	AND ST.CategoryID = CASE WHEN @CategoryId = -999 THEN ST.CategoryID ELSE @CategoryId END
	AND ST.SubCategoryID = CASE WHEN @SubCategoryId = -999 THEN ST.SubCategoryID ELSE @SubCategoryId END
	AND ST.SubCategory2ID = CASE WHEN @SubCategory2Id = -999 THEN ST.SubCategory2ID ELSE @SubCategoryId END
	GROUP BY SD.StockItemID,L.Id 


	SELECT ST.StockItemCode, ST.Name ItemName,U.Name UnitName,
	(SD.UnitPrice/SD.MasterUnitConversion) AS MasterUnitprice,
	sd.UnitPrice
	--,(dbo.FN_GetStockInHand(@PropertyID,@LocationID,@StockItemID)) AS BalanceQty
	,SD.NewQuantity BalanceQty,SH.CreatedDate,L.Name LocationName,SH.LocationID, C.Name CategoryName,SH.TransactionDate
	,[dbo].[FN_GetLastGRNDate](SD.StockItemID,SH.LocationID,@Date),
	U2.Name AS TxnUnit
	--INTO #TempLastPurchaseTable
	FROM StockTransactionHeaders SH
	INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID
	INNER JOIN StockItemHeaders ST ON ST.Id = SD.StockItemID
	INNER JOIN Categories C ON C.Id = ST.CategoryID
	INNER JOIN Units U ON U.Id = SD.MasterUnitID
	INNER JOIN Units U2 ON U2.ID = SD.TxnUnitID
	INNER JOIN Locations L ON L.Id =SH.LocationID 
	INNER JOIN #TempLastTransaction TMT ON TMT.StockItemID = SD.StockItemID AND TMT.LocationId = SH.LocationID AND TMT.DetailsId = SD.Id
	WHERE SH.CreatedDate < @Date AND SH.TransactionType='GR' 
	AND SH.PropertyID = CASE WHEN @PropertyID = -999 THEN SH.PropertyID ELSE @PropertyID END
	AND SH.LocationID = CASE WHEN @LocationID = -999 THEN SH.LocationID ELSE @LocationID END
	AND SD.StockItemID = CASE WHEN @StockItemID = -999 THEN SD.StockItemID ELSE @StockItemID END
	AND ST.CategoryID = CASE WHEN @CategoryId = -999 THEN ST.CategoryID ELSE @CategoryId END
	AND ST.SubCategoryID = CASE WHEN @SubCategoryId = -999 THEN ST.SubCategoryID ELSE @SubCategoryId END
	AND ST.SubCategory2ID = CASE WHEN @SubCategory2Id = -999 THEN ST.SubCategory2ID ELSE @SubCategoryId END
	--and st.StockItemCode='181'
	ORDER BY SH.CreatedDate DESC,ST.Name ASC





	--select *
	--from #TempLastPurchaseTable
	--order by StockItemCode desc, CreatedDate desc


	--WHILE(SELECT COUNT(*) FROM #TempLastPurchaseTable ) > 0
	--BEGIN

	--	SELECT TOP(1) @StockItemCode = StockItemCode, @LocationID2 = LocationID
	--	FROM #TempLastPurchaseTable
	--	order by StockItemCode desc, CreatedDate desc

	--	INSERT INTO #TempLastPurchaseTable2
	--	SELECT Top(1) StockItemCode,ItemName,UnitName,UnitPrice,BalanceQty,CreatedDate,LocationName,LocationID,CategoryName,TransactionDate
	--	FROM #TempLastPurchaseTable
	--	WHERE StockItemCode= @StockItemCode AND LocationID = @LocationID2
	--	order by StockItemCode desc, CreatedDate desc


	--	DELETE FROM #TempLastPurchaseTable WHERE StockItemCode= @StockItemCode AND LocationID = @LocationID2


	--END


	--SELECT StockItemCode,ItemName,UnitName,UnitPrice,BalanceQty,CreatedDate,LocationName,LocationID,CategoryName,TransactionDate
	--FROM #TempLastPurchaseTable2
	--ORDER BY CreatedDate DESC, ItemName DESC


	IF OBJECT_ID('tempdb..#TempLastPurchaseTable2') IS NOT NULL
	begin
        drop table #TempLastPurchaseTable2
	end
	IF OBJECT_ID('tempdb..#TempLastTransaction') IS NOT NULL
	begin
        drop table #TempLastTransaction
	end
   
END

GO

