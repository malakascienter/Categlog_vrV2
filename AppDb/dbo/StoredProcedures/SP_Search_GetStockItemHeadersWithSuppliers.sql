
--  [dbo].[SP_Search_GetStockItemHeadersWithSuppliers] 1,1,4168

CREATE PROCEDURE [dbo].[SP_Search_GetStockItemHeadersWithSuppliers] 

	@value INT, @PropertyId INT = 1, @UserId INT = 1
	AS 
	BEGIN
	DECLARE @IScentrallogin bit

	CREATE TABLE #TempItems(
	StockItemCode VARCHAR(50),
	Name VARCHAR(500),
	CompanyId INT,
	Id INT
	)

	SELECT @IScentrallogin =IScentrallogin FROM Companies where CompanyID = @PropertyId
	IF(@IScentrallogin = 1)
	BEGIN
		INSERT INTO #TempItems 
		SELECT SH.StockItemCode, SH.Name,sh.CompanyId,SH.Id 
		FROM StockItemHeaders  SH WITH (NOLOCK)
		INNER JOIN SupplierWiseItemDetails SW  WITH (NOLOCK) ON SH.Id = SW.StockItemID

		WHERE  SW.SupplierID = @value---StockItemCode = @StockItemCode
		--AND SH.CompanyId = @PropertyId

		SELECT DISTINCT SW.Id, ti.StockItemCode,L.Name AS LocationName, ti.Name AS ItemName, sw.CostPrice,g.Name AS TaxName,sw.IsDefaultSupplier,L.Id AS LocationId,SW.StockItemID, SW.CompanyId,SW.SupplierID,U.Id AS UnitId,g.TaxGroupId,@UserId AS UserID, U.Name AS PurchaseUnitName, SW.IsContractedSupplier,FORMAT( SW.Validfrom,'yyyy-MM-dd') AS Validfrom, FORMAT( SW.ValidTo,'yyyy-MM-dd') AS ValidTo
		 FROM dbo.SupplierWiseItemDetails AS SW  WITH (NOLOCK)
                                  INNER JOIN dbo.Suppliers AS S  WITH (NOLOCK) ON S.ID = SW.SupplierID 
								  INNER JOIN dbo.Units AS U  WITH (NOLOCK) ON U.Id =SW.PurchaseUnitID
								  INNER JOIN dbo.Locations L  WITH (NOLOCK) ON L.Id=SW.LocationId 
								  INNER JOIN TaxGroups g  WITH (NOLOCK) on sw.TaxGroupID = g.TaxGroupId
								  --INNER JOIN #TempCompanies t ON t.PropertyId = SW.CompanyId --and l.CompanyID = t.PropertyId 
								  INNER JOIN #TempItems ti ON ti.Id = SW.StockItemID  
								  WHERE SW.SupplierID=@value
	END
	ELSE
	BEGIN
		 SELECT DISTINCT SW.Id, sh.StockItemCode,L.Name AS LocationName, sh.Name AS ItemName, sw.CostPrice,g.Name AS TaxName,sw.IsDefaultSupplier,L.Id AS LocationId,SW.StockItemID, SW.CompanyId,SW.SupplierID,U.Id,g.TaxGroupId,@UserId AS UserID, U.Name AS PurchaseUnitName, SW.IsContractedSupplier,FORMAT( SW.Validfrom,'yyyy-MM-dd') AS Validfrom, FORMAT( SW.ValidTo,'yyyy-MM-dd') AS ValidTo
		 FROM dbo.SupplierWiseItemDetails AS SW  WITH (NOLOCK)
                                  INNER JOIN dbo.Suppliers AS S  WITH (NOLOCK) ON S.ID = SW.SupplierID INNER JOIN dbo.Units AS U ON U.Id =SW.PurchaseUnitID
								  INNER JOIN dbo.Locations L  WITH (NOLOCK) ON L.Id=SW.LocationId
								  INNER JOIN TaxGroups g  WITH (NOLOCK) on sw.TaxGroupID = g.TaxGroupId
								  INNER JOIN StockItemHeaders sh  WITH (NOLOCK) on sw.StockItemID = sh.Id
                                  WHERE SW.SupplierID = @value AND SW.CompanyId = @PropertyId
	END
		

	END

GO

