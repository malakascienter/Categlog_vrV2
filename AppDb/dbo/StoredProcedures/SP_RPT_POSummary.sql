CREATE PROCEDURE [dbo].[SP_RPT_POSummary]( @SupplierID INT=-999, @UserID INT =1,@PropertyID INT = -999, @FromDate DATE, @ToDate DATE)

AS
BEGIN
	CREATE TABLE #UserLocation (LocationID INT )

	INSERT INTO #UserLocation
			( LocationID )
	SELECT [LocationID] FROM UserWise_Location
	WHERE UserID= @UserID

	SELECT C.Name AS CompanyName, SH.Name AS ItemName,LS.Name AS LocationName,U.Name AS UnitName, SUM(D.ApprovedQuantity) AS Quantity,S.Name AS SuppName
	FROM PoDetails D
	INNER JOIN PoHeaders H ON H.Id = D.PoHeaderID
	INNER JOIN #UserLocation L ON L.LocationID = H.LocationID
	INNER JOIN StockItemHeaders SH ON SH.id = D.StockItemID
	INNER JOIN Locations LS ON Ls.id = L.LocationID
	INNER JOIN Units U ON U.Id = D.UnitID
	INNER JOIN Suppliers S ON S.ID = H.SupplierID
	INNER JOIN Companies C ON C.CompanyID = H.PropertyID
	WHERE H.SupplierID = CASE WHEN @SupplierId = -999 THEN H.SupplierID ELSE @SupplierId END
	AND H.PropertyID = CASE WHEN @PropertyID = -999 THEN H.PropertyID ELSE @PropertyID END 
	AND H.CreatedDate BETWEEN @FromDate AND @ToDate
	GROUP BY SH.Name ,LS.Name ,U.Name ,S.Name ,C.Name
 

END

GO

