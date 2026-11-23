-- [dbo].[SP_Search_GetSuppliersWithStockItemHeaders] 3415,1,4168

CREATE PROCEDURE [dbo].[SP_Search_GetSuppliersWithStockItemHeaders] 
@value INT , @PropertyId INT , @UserId INT 
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY

	BEGIN

	-------------------------------------------------------------------------
	IF(@UserId = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('Error Occured : User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END
	-------------------------------------------------------------------------
	IF(@PropertyId = -888)
	BEGIN
		DECLARE @StockItemCode NVARCHAR(250)
		SELECT @StockItemCode = StockItemCode FROM StockItemHeaders WHERE Id = @value

		SELECT * INTO #TempItems FROM StockItemHeaders WHERE StockItemCode = @StockItemCode

		SELECT  U.PropertyId INTO #TempCompanies FROM CentralUserWiseProperties U 
		INNER JOIN #TempItems T ON T.CompanyId = U.PropertyId
		WHERE UserId = @UserId
		
		SELECT DISTINCT SW.SupplierID AS SuppID,g.TaxGroupId SuppTaxGroupID, g.Name TaxGroupName,S.Name AS SuppName,S.Code AS SuppCode,SW.CostPrice
		,U.name AS PurchaseUnitName,U.id AS UnitId,SW.isdefaultsupplier AS IsDefaultsupplier,L.Id AS LocationID,L.Name AS LocationName
		,ISNULL(SW.IsContractedSupplier,0) IsContractedSupplier
		,CONVERT(VARCHAR,SW.Validfrom) Validfrom
		,CONVERT(VARCHAR,SW.ValidTo) ValidTo
		 FROM dbo.SupplierWiseItemDetails AS SW
                                  INNER JOIN dbo.Suppliers AS S ON S.ID = SW.SupplierID INNER JOIN dbo.Units AS U ON U.Id =SW.PurchaseUnitID
								  INNER JOIN dbo.Locations L ON L.Id=SW.LocationId
								  INNER JOIN TaxGroups g on sw.TaxGroupID = g.TaxGroupId
								  INNER JOIN #TempCompanies t ON t.PropertyId = SW.CompanyId
								  INNER JOIN #TempItems ti ON ti.Id = SW.StockItemID
                                  --WHERE SW.StockItemID = @value 
		
	END
	ELSE
	BEGIN
		 SELECT SW.Id,SW.SupplierID AS SuppID,g.TaxGroupId SuppTaxGroupID, g.Name TaxGroupName,S.Name AS SuppName,S.Code AS SuppCode,SW.CostPrice
		 ,U.name AS PurchaseUnitName,U.id AS UnitId,SW.isdefaultsupplier AS IsDefaultsupplier,L.Id AS LocationID,L.Name AS LocationName
		 ,ISNULL(SW.IsContractedSupplier,0) IsContractedSupplier
		,CONVERT(VARCHAR,SW.Validfrom) Validfrom
		,CONVERT(VARCHAR,SW.ValidTo) ValidTo
		,ISNULL(dbo.fn_IsPendingPOExists(SW.SupplierID,SW.LocationId,@value),0) IsPendingPOExists
		 FROM dbo.SupplierWiseItemDetails AS SW
                                  INNER JOIN dbo.Suppliers AS S ON S.ID = SW.SupplierID INNER JOIN dbo.Units AS U ON U.Id =SW.PurchaseUnitID
								  INNER JOIN dbo.Locations L ON L.Id=SW.LocationId
								  INNER JOIN TaxGroups g on sw.TaxGroupID = g.TaxGroupId
                                  WHERE SW.StockItemID = @value AND SW.CompanyId = @PropertyId
	END
		

	END 

        COMMIT TRANSACTION;
    END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

	END CATCH
	
	
END;

GO

