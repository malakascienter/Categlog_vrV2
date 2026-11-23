-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-05-16
-- Description:	Loading Short expiry date items
-- [dbo].[Select_ShortExpireItems] 1,1
-- =============================================
CREATE PROCEDURE [dbo].[Select_ShortExpireItems]
	@PropertyID INT,
	@LocationID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE  @ShortExpDates INT

	SELECT @ShortExpDates = ISNULL(ShortExpDates,30)
	FROM Companies
	WHERE CompanyID = @PropertyID


	SELECT DISTINCT SE.LocationID,SE.stockitemid, C.Name AS CategoryName,U.Name AS UnitName, SIH.StockItemCode,SIH.Name,  SE.BalanceQuantity
	, CONVERT(DATE,SE.EXPDate) EXPDate, L.Name AS LocationName
	  ,CASE  WHEN CONVERT(DATE,SE.EXPDate)>= CAST(GETDATE() AS DATE)  AND CONVERT(DATE,SE.EXPDate) <= DATEADD(DAY, @ShortExpDates, CAST(GETDATE() AS DATE))THEN 1  ELSE 0 END AS IsShortExpiry,
	  CASE   WHEN CONVERT(DATE,SE.EXPDate) < CAST(GETDATE() AS DATE) THEN 1  ELSE 0 END AS IsExpired
	FROM  [dbo].[StockItemWiseEXPDateIns] SE
	INNER JOIN StockTransactionHeaders SH ON SH.Id = SE.TransactionID OR SE.TransactionID = -999 
	INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID
	INNER JOIN StockItemHeaders SIH ON SIH.Id = SE.StockItemID
	INNER JOIN StockItemDetails SID ON SID.StockItemHeaderID = SIH.Id AND SH.LocationID = SID.LocationID
	INNER JOIN Categories C ON C.Id = SIH.CategoryID 
	INNER JOIN Units U ON U.Id = SID.MasterUnitID
	INNER JOIN Locations L On L.Id = SE.LocationID 
	WHERE SE.PropertyID = @PropertyID
	AND SE.LocationID = @LocationID	
	AND SE.BalanceQuantity > 0
	AND CONVERT(DATE,SE.EXPDate) <= DATEADD(DAY, @ShortExpDates, CAST(GETDATE() AS DATE))
	ORDER BY LocationName,StockItemCode,EXPDate ASC

    
END

GO

