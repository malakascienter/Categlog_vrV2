/**
exec	SP_GetAllProductionItems -999,1

exec	SP_GetAllProductionItems 1,1
**/
CREATE PROCEDURE [dbo].[SP_GetAllProductionItems](@LocationId INT = -999,@propertyID INT)

AS
BEGIN
----------------------------------------------------------------------
BEGIN TRY 

DECLARE @IsProductionWithoutRecipe BIT

SELECT @IsProductionWithoutRecipe = ISNULL(IsProductionWithoutRecipe,0)
FROM COMPANIES
WHERE COMPANYID = @propertyID

DECLARE @DefaultLocationID INT
	IF (@LocationId = -999)
	BEGIN

		select TOP (1) @DefaultLocationID = Id
		from locations
		where CompanyId=@propertyID
		and DefaultLocation=1

		SELECT DISTINCT 
		  H.Id, 
		  H.Name AS text,
		  MU.MasterUnitID AS UnitId,
		  H.IsExpiryDateApplicable,
		  H.StockItemCode AS code,
		CASE WHEN @IsProductionWithoutRecipe = 0  THEN ISNULL(PU.UnitID,0) ELSE D.MasterUnitID END  AS  ProductionUnitID,
		CASE WHEN @IsProductionWithoutRecipe = 0  THEN  ISNULL(PU.UnitName,'N/A') ELSE UN.Name END AS ProductionUnit 
	FROM StockItemHeaders H
	INNER JOIN StockItemDetails D  ON D.StockItemHeaderID = H.Id AND D.LocationID = @DefaultLocationID
	INNER JOIN Units UN ON D.MasterUnitID = UN.Id
	CROSS APPLY dbo.FN_GetMasterUnitID_TVF(@propertyID, @DefaultLocationID, H.Id) MU
	outer APPLY dbo.FN_GetProductionUnit_TVF(H.Id, -999,@propertyID) PU
	WHERE D.LocationID = CASE WHEN @LocationId = -999 THEN D.LocationID ELSE @LocationId END
	  AND H.IsProductionItem = 1
	  AND H.CompanyId = @propertyID;

	END
	ELSE
	BEGIN

	SELECT DISTINCT H.Id, H.Name AS text, D.MasterUnitID AS UnitId,U.Name AS UnitName, H.IsExpiryDateApplicable,H.StockItemCode AS code
	-- ,ISNULL(PU.UnitID,0) AS  ProductionUnitID, ISNULL(PU.UnitName,'N/A') ProductionUnit 

	,CASE WHEN @IsProductionWithoutRecipe = 0  THEN ISNULL(PU.UnitID,0) ELSE D.MasterUnitID END  AS  ProductionUnitID
	,CASE WHEN @IsProductionWithoutRecipe = 0  THEN  ISNULL(PU.UnitName,'N/A') ELSE U.Name END AS ProductionUnit 
	FROM StockItemHeaders H
	--INNER JOIN  [dbo].[StockItemWiseAttributes] A ON H.Id = A.stockitemheaderid
	INNER JOIN StockItemDetails D ON D.StockItemHeaderID = H.Id
	INNER JOIN Units U ON D.MasterUnitID = U.Id
	--INNER JOIN CompanySettings C ON C.ProductionItemAttributeId = A.StockItemAttributeID
	outer APPLY dbo.FN_GetProductionUnit_TVF(H.Id, -999,@propertyID) PU
	WHERE D.LocationID = CASE WHEN @LocationId = -999 THEN D.LocationID  ELSE @LocationId END AND H.IsProductionItem = 1 -- AND A.IsActive = 1
	AND H.CompanyId = @propertyID
	END

END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;
----------------------------------------------------------------------



END

GO

