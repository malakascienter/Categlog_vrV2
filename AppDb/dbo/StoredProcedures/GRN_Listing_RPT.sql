-- Last Modified by		: Nivesh
-- Last Modified date	: 2026-02-23
--   [dbo].[GRN_Listing_RPT] -999,-999,-999,-999,-999,-999,'2023/01/01','2024/11/12'
CREATE PROCEDURE [dbo].[GRN_Listing_RPT](
	@PropertyId		INT,
	@LocationId		INT,
	@CatId			INT,
	@SubCatId		INT,
	@SubCat2Id		INT,
	@StockItemID	INT,
	@FromDate		DATE,
	@ToDate			DATE
)
AS
BEGIN
SET NOCOUNT ON;
	
	CREATE TABLE #AverageUnitPrice(
		Id				INT,
		ItemID			INT,
		TransactionDate DATE,
		NewAveragePrice DECIMAL(18,4),
		UnitPrice		DECIMAL(18,4)
	)

	INSERT INTO #AverageUnitPrice(
		Id,
		ItemID,
		TransactionDate,
		NewAveragePrice,
		UnitPrice
	)
	 SELECT 
		LocationID,
		StockItemID,
		TransactionDate,
		NewAveragePrice ,
		UnitPrice
	 FROM(
		  SELECT 
				NewAveragePrice ,
				UnitPrice,
				SH.TransactionDate,
				SH.LocationID, 
				SD.StockItemID,
				ROW_NUMBER() OVER (
					PARTITION BY StockItemID,
								LocationID
					ORDER BY TransactionDate DESC,
						SD.CreatedDate DESC,
						SD.Id DESC
				) AS rn
		 FROM StockTransactionDetails SD
		 INNER JOIN StockTransactionHeaders SH 
		 ON SD.StockTransactionHeaderID =SH.Id
		 WHERE SH.TransactionType = 'GR' 
			 AND SH.TransactionDate <= @ToDate 
			 AND UnitPrice <> 0
	 ) AS t
	 WHERE t.rn =1
	
	
	SELECT 
		co.Name AS CompanyName,
		SD.StockItemID,
		SIH.Name, 
		SIH.StockItemCode,
		AU.NewAveragePrice AS AvgUnitPrice,
		--[dbo].FN_GetLastGRNAvgPriceAtDate(L.Id,SIH.Id,@ToDate) AS AvgUnitPrice,
		SUM(SD.Quantity) Quantity,
		L.Name	AS LocationName,
		C.Name	AS CategoryName,
		SC.Name AS SubCatName,
		SC2.Description		AS SubCat2Name,
		AU.UnitPrice		AS LastGRNPrice,
		--[dbo].[FN_GetLastGRNPriceAtDate](L.Id,SIH.Id,@ToDate) LastGRNPrice,
		AU.TransactionDate	AS LastGRNDate
		--[dbo].[FN_GetLastGRNDate](SIH.Id,L.Id,@ToDate) LastGRNDate
	FROM StockTransactionHeaders SH
	INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID
	INNER JOIN #AverageUnitPrice AU ON AU.Id = SH.LocationID AND AU.ItemID = SD.StockItemID
	INNER JOIN StockItemHeaders SIH ON SIH.Id = SD.StockItemID
	INNER JOIN Categories C ON C.Id = SIH.CategoryID
	INNER JOIN SubCategories SC ON SC.Id = SIH.SubCategoryID
	INNER JOIN SubCategories02 SC2 ON SC2.Id = SIH.SubCategory2ID
	INNER JOIN Locations L ON L.Id = SH.LocationID
	INNER JOIN Companies Co ON Co.CompanyID = SH.PropertyID
	WHERE SH.TransactionType = 'GR' 
	AND SH.PropertyID		= CASE 
									WHEN @PropertyId = -999 
									THEN SH.PropertyID 
									ELSE @PropertyId 
								END 
	AND SH.LocationID		= CASE 
									WHEN @LocationId = -999 
									THEN SH.LocationID 
									ELSE @LocationId 
								END
	AND SIH.CategoryID		= CASE 
									WHEN @CatId = -999 
									THEN SIH.CategoryID 
									ELSE @CatId 
								END 
	AND SIH.SubCategoryID	= CASE 
									WHEN @SubCatId = -999 
									THEN SIH.SubCategoryID 
									ELSE @SubCatId 
								END
	AND SIH.SubCategory2ID	= CASE 
									WHEN @SubCat2Id = -999 
									THEN SIH.SubCategory2ID 
									ELSE @SubCat2Id 
								END
	AND SIH.Id				= CASE 
								WHEN @StockItemID = -999 
								THEN SIH.Id  
								ELSE @StockItemID 
							END
	AND SH.TransactionDate BETWEEN @FromDate AND @ToDate
	GROUP BY 
		SD.StockItemID,
		SIH.Name,
		SIH.StockItemCode,
		L.Name, 
		C.Name ,
		SC.Name ,
		SC2.Description,
		co.Name,
		L.Id,
		SIH.Id,
		AU.NewAveragePrice,
		AU.UnitPrice,
		AU.TransactionDate
	ORDER BY Co.name DESC
END

GO

