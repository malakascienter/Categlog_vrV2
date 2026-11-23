
-- [dbo].[SP_RPT_CostCenterWiseItemConsumption_Eden] 1,-999,'2021/01/01','2024/10/10',-999

CREATE PROCEDURE [dbo].[SP_RPT_CostCenterWiseItemConsumption_Eden](@CompanyId INT = 1, @LocationId INT = -999, @FromDate DATE, @ToDate DATE, @DepartmentID INT =-999 )
	 
AS
BEGIN
		SELECT  D.Name AS DeptName,SUM(SD.Quantity) Quantity,SUM(SD.UnitPrice) UnitPrice,  SUM(SD.Quantity * SD.UnitPrice)  AS Value,  L.Name AS Location,
		H.StockItemCode,H.Name AS Item ,U.Name AS Unit,CA.Name CategoryName,SU.Name SubCatName
		FROM STocktransactionheaders  SH 
		INNER JOIN StockTransactionDetails SD ON SD.StockTransactionHeaderID = SH.Id
		INNER JOIN Departments D ON D.Id = SH.DepartmentID
		INNER JOIN StockItemHeaders H ON H.Id = SD.StockItemID 
		INNER JOIN StockItemDetails ID On ID.StockItemHeaderID = H.Id AND ID.LocationID = SH.LocationID
		INNER JOIN Units U ON U.Id = ID.MasterUnitID
		INNER JOIN Locations L ON L.Id = SH.LocationID
		INNER JOIN Categories CA ON H.CategoryID = CA.Id
		INNER JOIN SubCategories SU ON H.SubCategoryID = SU.ID
		WHERE SH.transactiontype IN ('IN','IF')
		AND SH.PropertyID = CASE WHEN @CompanyId = -999 THEN SH.PropertyID ELSE @CompanyId END
		AND SH.LocationId = CASE WHEN @LocationId = -999 THEN SH.LocationId ELSE @LocationId END
		AND SH.DepartmentID = CASE WHEN @DepartmentId = -999 THEN SH.DepartmentID ELSE @DepartmentId END
		AND SH.TransactionDate BETWEEN @FromDate AND @ToDate   
		GROUP BY D.Name,  L.Name,H.StockItemCode,H.Name,U.Name,CA.Name,SU.Name 
END

GO

