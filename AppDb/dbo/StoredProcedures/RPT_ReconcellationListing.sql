
CREATE PROCEDURE [dbo].[RPT_ReconcellationListing] ( @DateFrom DATE='2020-01-01', @DateTo DATE='2020-08-30', @StockItemID INT =-999, @CategoryID INT= -999, @LocationID INT=-999,@TransactionType varchar(10)='-999', @UserID int =1, @DepartmentID int =-999)
as

CREATE TABLE #UserLocation (LocationID INT )

INSERT INTO #UserLocation
        ( LocationID )
SELECT [LocationID] FROM UserWise_Location
WHERE UserID= @UserID

SELECT L.Name Location, H.DocumentNo, convert(DATE, H.TransactionDate) TransactionDate ,SH.StockItemCode  , SH.Name StockItem,U.Name Unit, d.StockMasterQuantity SystemQuantity, d.StockMasterQuantity * d.StockMasterAveragePrice SystemValue , d.Quantity PhysicalQuantity, d.Quantity * d.StockMasterAveragePrice PhysicalValue,  d.Quantity-d.StockMasterQuantity  Variance, (d.Quantity-d.StockMasterQuantity) * d.StockMasterAveragePrice VarianceValues,CASE WHEN d.TxnType='P' THEN 'EXCESS' ELSE 'SHORTAGE' END  TransactionType
FROM StockTransactionHeaders H 
INNER JOIN StockTransactionDetails D ON H.ID= D.StockTransactionHeaderID
INNER JOIN StockItemHeaders SH ON SH.Id = D.StockItemID
INNER JOIN Units U ON U.Id= D.MasterUnitID
INNER JOIN Locations L ON L.ID= H.LocationID
INNER JOIN #UserLocation t ON t.LocationID= H.LocationID
WHERE	SH.Id = CASE @StockItemID WHEN -999 THEN SH.ID ELSE @StockItemID END  
		AND H.LocationID = CASE @LocationID WHEN -999 THEN h.LocationID ELSE @LocationID END   
		AND H.TransactionDate BETWEEN   @DateFrom AND @DateTo
		AND SH.CategoryID =CASE @CategoryID WHEN -999 THEN SH.CategoryID ELSE @CategoryID END  
		AND H.TransactionType = 'AA'
		AND h.DepartmentID = CASE WHEN @DepartmentID =-999 THEN  h.DepartmentID ELSE @DepartmentID END 
ORDER BY h.TransactionDate

GO

