-- =============================================
-- Author:		<Thilini Fernando>
-- Create date: <28/02/2022> 
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_PendingGRNList](@CompanyId INT, @LocationId INT ,
@StockItemID INT,@CategoryId INT,@FromDate DATE,@ToDate DATE)
AS
BEGIN



DECLARE @XMLDetails XML,@iDocID INT,@ItemTotal DECIMAl(18,6),@SupplierID INT, @TaxAmount DECIMAL(18,6),
		@Qty DECIMAL(18,6),@ApprovalDocNo VARCHAR(20)


select distinct ApprovalDocNo,XMLDetails,SupplierId,LocationId
INTO #TempGRNXML
from GRNApprovalLog
where Status = 'p'
AND TransactionType='GR' AND CreatedDate BETWEEN @FromDate AND @ToDate AND 
CompanyId = CASE WHEN @CompanyId = -999 THEN CompanyId ELSE @CompanyId END  
AND LocationId = CASE WHEN @LocationId = -999 THEN LocationId ELSE @LocationId END

CREATE TABLE #tempItemDetails(LocationId INT,SupplierId INT,StockItemID INT,Quantity DECIMAL(18,6),UnitPrice DECIMAL(18,6))


	WHILE EXISTS(SELECT 1 FROM #TempGRNXML)
	BEGIN
		EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
		SELECT TOP (1) @XMLDetails = XMLDetails,@SupplierID = SupplierId,@ApprovalDocNo = ApprovalDocNo,@LocationId = LocationId
		FROM #TempGRNXML

		
		INSERT INTO #tempItemDetails(LocationId,SupplierId,StockItemID,Quantity,UnitPrice)
		SELECT @LocationId,@SupplierID,StockItemID,Quantity,UnitPrice
		FROM 
		OPENXML(@iDocID, '/StockTransactionHeader/StockDetailList/StockTransactionDetail', 2) 
		WITH (StockItemID INT, Quantity DECIMAL(18,6),UnitPrice DECIMAL(18,6))


		


		DELETE TOP(1) FROM #TempGRNXML

	END

	SELECT *
	INTO #FinalTable
	FROM (
	SELECT TD.SupplierId,TD.StockItemID,SUM(TD.Quantity) Quantity,SD.AveragePrice
	FROM #tempItemDetails TD
	INNER JOIN StockItemDetails SD ON TD.LocationId = SD.LocationID AND TD.StockItemID = SD.StockItemHeaderID
	GROUP BY TD.SupplierId,TD.StockItemID,SD.AveragePrice
	UNION ALL
	SELECT SH.SupplierID,SD.StockItemID,SUM(SD.Quantity) Quantity,STD.AveragePrice
	FROM StockTransactionHeaders SH
	INNER JOIN StockTransactionDetails SD ON SH.ID = SD.StockTransactionHeaderID
	INNER JOIN StockItemDetails STD ON STD.StockItemHeaderID = SD.StockItemID AND SH.LocationID = STD.LocationID
	WHERE SH.TransactionType = 'GR'
	AND STD.StockItemId = CASE WHEN @StockItemID = -999 THEN  STD.StockItemId ELSE @StockItemID END 
	GROUP BY SH.SupplierID,SD.StockItemID,STD.AveragePrice
	) AS A


	SELECT SU.Name Supplier,SH.Name ItemName,CA.Name Category,SUM(FT.Quantity) Quantity,FT.AveragePrice Price
	FROM #FinalTable FT
	INNER JOIN StockItemHeaders SH ON FT.StockItemID = SH.Id
	INNER JOIN Categories CA ON CA.ID = SH.CategoryID
	INNER JOIN Suppliers SU ON SU.ID = FT.SupplierId
	WHERE SH.CategoryID = CASE WHEN @CategoryId = -999 THEN SH.CategoryID ELSE @CategoryId END
	GROUP BY SU.Name,SH.Name,CA.Name,FT.AveragePrice


	
	--SELECT distinct SH.Name ItemName,CA.Name Category,SUM(FT.Quantity) Quantity,FT.AveragePrice Price
	--FROM #FinalTable FT
	--INNER JOIN StockItemHeaders SH ON FT.StockItemID = SH.Id
	--INNER JOIN Categories CA ON CA.ID = SH.CategoryID
	--INNER JOIN Suppliers SU ON SU.ID = FT.SupplierId
	--WHERE SH.CategoryID = CASE WHEN @CategoryId = -999 THEN SH.CategoryID ELSE @CategoryId END
	--GROUP BY SH.Name,CA.Name,FT.AveragePrice



DROP TABLE #TempGRNXML
DROP TABLE #tempItemDetails
DROP TABLE #FinalTable





END

GO

