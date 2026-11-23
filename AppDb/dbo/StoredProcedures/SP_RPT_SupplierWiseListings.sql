
-- [dbo].[SP_RPT_SupplierWiseListings] '2024-06-20','2024-06-24',-999,-999,1,17,9217,1

CREATE PROCEDURE [dbo].[SP_RPT_SupplierWiseListings] ( @DateFrom DATE='2018-03-10', @DateTo DATE='2018-04-30', @StockItemID INT =-999, @CategoryID INT= -999, @LocationID INT=-999,@SupplierID INT=-999, @UserID int =1,@PropertyID INT = 1)
as

  
CREATE TABLE #UserLocation (LocationID INT )

INSERT INTO #UserLocation
        ( LocationID )
SELECT [LocationID] FROM UserWise_Location
WHERE UserID= @UserID
 

SELECT Co.Name AS CompanyName, s.Name AS supplier,l.Name Location, h.DocumentNo,CONVERT(VARCHAR(10),h.TransactionDate,103) AS TransactionDate, tt.Name TransactionType , IH.StockItemCode , IH.Name StockItemName, CAST(CONVERT(varchar, CAST(d2.Quantity AS MONEY), 1) AS varchar) AS Quantity , CAST(CONVERT(varchar, CAST(d2.UnitPrice AS MONEY), 1) AS varchar) AS UnitPrice, tu.Name Unit
--,CAST(CONVERT(varchar, CAST(d2.Quantity * d2.UnitPrice AS MONEY), 1) AS varchar) AS Value
,CAST(d2.Quantity * d2.UnitPrice AS MONEY)-CASE WHEN d.DiscountPercentage>0 and  d.DiscountValue =0 THEN (d.UnitPrice *d.DiscountPercentage /100)* d.Quantity else d.DiscountValue end AS Value
,CASE WHEN d.DiscountPercentage>0 and  d.DiscountValue =0 THEN (d.UnitPrice *d.DiscountPercentage /100)* d.Quantity else d.DiscountValue end DiscountValue 
FROM dbo.StockTransactionDetails AS D
INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
INNER JOIN dbo.StockTransactionDetails AS D2 ON D.Id = D2.Id
INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND H.LocationId = ID.LocationID
INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
INNER JOIN dbo.Units AS TU ON d2.TxnUnitID = TU.Id
INNER JOIN dbo.Categories c ON c.Id= ih.CategoryID
INNER JOIN dbo.Locations l ON l.Id = h.LocationID
INNER JOIN dbo.Suppliers s ON s.ID = h.SupplierID
INNER JOIN #UserLocation ul ON ul.LocationID = l.Id
INNER JOIN dbo.TransactionTypes tt ON tt.Code= h.TransactionType
INNER JOIN Companies Co ON Co.CompanyId = h.PropertyID
WHERE	IH.Id = CASE @StockItemID WHEN -999 THEN IH.ID ELSE @StockItemID END  
		AND H.LocationID = CASE @LocationID WHEN -999 THEN h.LocationID ELSE @LocationID END   
		AND H.TransactionDate BETWEEN   @DateFrom AND @DateTo
		AND IH.CategoryID =CASE @CategoryID WHEN -999 THEN IH.CategoryID ELSE @CategoryID END  
		AND h.SupplierID = CASE @SupplierID WHEN -999 THEN h.SupplierID ELSE @SupplierID END   
		AND H.PropertyID = CASE  @PropertyId WHEN -999 THEN H.PropertyID ELSE @PropertyId END
ORDER BY h.SupplierID

GO

