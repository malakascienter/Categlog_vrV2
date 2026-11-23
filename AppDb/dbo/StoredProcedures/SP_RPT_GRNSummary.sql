-- =============================================
-- Author:		Nivesh
-- Create date: 2024-11-04
-- Description:	Report GRN summary
-- =============================================
-- SP_RPT_GRNSummary 1,-999,-999,-999,-999,-999,-999,'2024-01-01','2024-11-02'

CREATE PROCEDURE SP_RPT_GRNSummary
	@PropertyID INT,
	@LocationID INT,
	@SupplierID INT,
	@StockItemID INT,
	@CategoryId INT,
	@SubCatId INT,
	@SubCat2Id INT,
	--@UnitID INT,
	@FromDate DATE = NULL,
	@ToDate DATE = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @FromDate IS NULL OR @FromDate = ''
	SET @FromDate = GETDATE()

	IF @ToDate IS NULL OR @ToDate = ''
	SET @ToDate = GETDATE()

	SELECT L.NAME LocationName,
	s.name SupplierName,
	SIH.StockItemCode,SIH.Name ItemName,C.Name CategoryName, SC.Name SubCategoryName, SC2.Description Sub2CategoryName,
	--SH.DocumentNo,(SELECT NAME FROM Units WHERE ID = SD.TxnUnitID) TxnUnit,
	(SELECT NAME FROM Units WHERE ID = SD.MasterUnitID) MasterUnit,
	--SD.Quantity,SD.UnitPrice,
	--,SD.StockMasterQuantity,SD.StockMasterAveragePrice,SD.NewQuantity,SD.NewAveragePrice--,SD.* 
	(sum(sd.Quantity)) Quantity,(sum(sd.quantity* sd.UnitPrice)/(sum(sd.Quantity))) averagePrice
	FROM StockTransactionHeaders SH
	INNER JOIN StockTransactionDetails SD ON SD.StockTransactionHeaderID = SH.Id
	INNER JOIN StockItemHeaders SIH ON SIH.ID = SD.StockItemID
	LEFT JOIN Categories C ON C.ID = SIH.CategoryID
	LEFT JOIN SubCategories SC ON SC.Id = SIH.SubCategoryID
	LEFT JOIN SubCategories02 SC2 ON SC2.Id = SIH.SubCategory2ID
	LEFT JOIN Suppliers S ON S.ID = SH.SupplierID
	LEFT JOIN Locations L ON L.ID = SH.LocationID
	LEFT JOIN Units U ON U.ID = SD.MasterUnitID
	WHERE SH.TransactionType ='GR'
	AND SH.CreatedDate BETWEEN @FromDate AND @ToDate
	AND SH.PropertyID = @PropertyID
	AND SH.LocationID = CASE WHEN @LocationID = -999 THEN SH.LocationID ELSE @LocationID END
	AND SH.SupplierID = CASE WHEN @SupplierID = -999 THEN SH.SupplierID ELSE @SupplierID END 
	AND SIH.CategoryID = CASE WHEN @CategoryId = -999 THEN SIH.CategoryID ELSE @CategoryId END 
	AND SIH.SubCategoryID = CASE WHEN @SubCatId = -999 THEN SIH.SubCategoryID ELSE @SubCatId END 
	AND SIH.SubCategory2ID = CASE WHEN @SubCat2Id = -999 THEN SIH.SubCategory2ID ELSE @SubCat2Id END 
	--AND SD.MasterUnitID = CASE WHEN @UnitID = -999 THEN SD.MasterUnitID ELSE @UnitID END
	AND SD.StockItemID = CASE WHEN @StockItemID = -999 THEN SD.StockItemID ELSE @StockItemID END
	GROUP BY L.NAME ,SIH.StockItemCode,SIH.Name ,C.Name, SC.Name, SC2.Description,SD.MasterUnitID,
	s.name
	ORDER BY SIH.StockItemCode

END

GO

