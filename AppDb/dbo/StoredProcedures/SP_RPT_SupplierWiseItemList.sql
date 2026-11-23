-- =============================================
-- Author:		<Thilini Fernando>
-- Create date: <14/03/2022> 
-- =============================================
  --[SP_RPT_SupplierWiseItemList] -999
  --go
CREATE PROCEDURE  [dbo].[SP_RPT_SupplierWiseItemList](@SuppId INT )
AS
BEGIN
	SELECT S.Name AS Supplier,SH.StockItemCode, SH.Name AS Item,U.Name AS PurchasingUnit, T.Name AS Tax,L.Name AS Location, SD.CostPrice as Price
	FROM SupplierWiseItemDetails SD 
	INNER JOIN Suppliers s ON S.Id = SD.SupplierID
	INNER JOIN StockItemHeaders SH ON SH.Id = SD.StockItemID
	INNER JOIN Units U ON U.Id = SD.PurchaseUnitID
	INNER JOIN TaxGroups T ON T.TaxGroupId = SD.TaxGroupID
	INNER JOIN Locations L ON L.id = SD.LocationId
	WHERE S.Id = CASE WHEN @SuppId = -999 THEN S.Id ELSE @SuppId END

END

GO

