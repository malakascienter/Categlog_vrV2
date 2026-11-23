-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>

--  [dbo].[SP_RPT_TransactionListing_SubGrid] '2025/02/01','2026/12/01',-999,-999,-999,4168,1

-- =============================================
create   PROCEDURE [dbo].[SP_RPT_TransactionListing_SubGrid]
( 
@DateFrom DATE='2020/08/01', 
@DateTo DATE='2020/10/10', 
@StockItemID INT =-999, 
@CategoryID INT= -999, 
@LocationID INT=5,
@UserID int =1, 
@PropertyID INT
)
AS
BEGIN
	SET NOCOUNT ON;

   CREATE TABLE #UserLocation (LocationID INT )

INSERT INTO #UserLocation
        ( LocationID )
SELECT [LocationID] FROM UserWise_Location
	WHERE UserID= @UserID


	SELECT CO.Name CompanyName,LO.Name LocationName,PCH.DocumentNo,PCH.RequestedDate TransactionDate,
	'Producation Process Plan' TransactionType,SH.StockItemCode,SH.Name StockItemName,PCD.RequestedQTY Quantity,
	0 UnitPrice,UN.Name Unit,CA.Name AS CatName,SC.Name SubCatName,
	SC2.Description AS SubCat2Name
	FROM ProductionConsolidateHeader PCH
	INNER JOIN ProductionConsolidateDetails PCD ON PCH.ID = PCD.HeaderID
	INNER JOIN StockItemHeaders SH ON PCD.StockItemID = SH.Id
	INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID AND SD.LocationID = PCH.LocationID
	INNER JOIN Units UN ON UN.Id = SD.MasterUnitID
	INNER JOIN #UserLocation UL ON UL.LocationID = PCH.LocationID
	INNER JOIN Companies CO ON CO.CompanyID = PCH.PropertyID
	INNER JOIN Locations LO ON LO.ID = UL.LocationID
	INNER JOIN Categories CA ON CA.ID = SH.CategoryID
	INNER JOIN SubCategories SC ON SC.Id = SH.SubCategoryID
	INNER JOIN SubCategories02 SC2 ON SC2.ID = SH.SubCategory2ID
	WHERE PCH.RequestedDate BETWEEN @DateFrom AND @DateTo
	AND PCH.LocationID = CASE WHEN @LocationID = -999 THEN PCH.LocationID ELSE @LocationID END
	AND PCH.PropertyID = @PropertyID

END

GO

