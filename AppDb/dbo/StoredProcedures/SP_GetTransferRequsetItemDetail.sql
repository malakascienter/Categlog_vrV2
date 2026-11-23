-- =============================================
-- Author:		Nivesh
-- Create date: 2024-12-18
-- Description:	Get Transfer requset Item detail for Excel Upload
-- =============================================
-- SP_GetTransferRequsetItemDetail 8,1,1,-999,0

CREATE PROCEDURE [dbo].[SP_GetTransferRequsetItemDetail] 
	@CurrentLocationID INT ,
    @Propertyid INT ,
	@FromLocationID INT ,
	@CategoryID INT,
	@IsWithoutExpiryDate BIT =0
AS
BEGIN

	SET NOCOUNT ON;

BEGIN TRY 

    DECLARE @Locationid1 INT= @FromLocationID ,
        @Propertyid1 INT = @Propertyid ,
        @ISGross BIT, @DecimalPlace INT
        
	IF NOT EXISTS (SELECT 1 FROM Locations  WHERE Id = @CurrentLocationID)
	BEGIN
		RAISERROR('Invalid Current Location',16,1)
		RETURN
	END

	IF NOT EXISTS (SELECT 1 FROM Locations  WHERE Id = @FromLocationID)
	BEGIN
		RAISERROR('Invalid To Location',16,1)
		RETURN
	END

	IF NOT EXISTS (SELECT 1 FROM Companies  WHERE CompanyID = @Propertyid)
	BEGIN
		RAISERROR('Invalid Property',16,1)
		RETURN
	END

	IF NOT EXISTS (SELECT 1 FROM Categories  WHERE Id = @CategoryID) AND (@CategoryID <> -999)
	BEGIN
		RAISERROR('Invalid Category',16,1)
		RETURN
	END

	IF (@FromLocationID = @CurrentLocationID)
	BEGIN
		RAISERROR('Not same loations',16,1)
		RETURN
	END	
 
    SELECT  @ISGross = IsTaxOrSellPrice,@DecimalPlace = DecimalPlaces
    FROM    dbo.Companies
    WHERE   CompanyID = @Propertyid


        SELECT 
                SIH.Id ,
                SIH.Name ,
				SIH.CategoryID,
				CA.Name CategoryName,
                SID.AveragePrice AS CostPrice,
                SID.MasterUnitID ,
				U.Name MasterUnit,
                ( CASE WHEN @ISGross = 0
                       THEN dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
                                                            SIH.TaxGroupID)
                       ELSE SID.SellingPrice
                  END ) SellingPrice ,
                SIH.IsPriceEditable ,
                SIH.StockItemCode ,
                SIH.Barcode ,
                0 Quantity ,
                dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
                                                SIH.TaxGroupID) Value ,
                SID.SellingPrice AS TaxInclusivePrice ,
                MaintainPriceHistory AS MaintainPriceHistory,
				ISNULL(IsProductionItem,0) IsProductionItem,
				ROUND(dbo.[FN_GetStockInHand_Reatils](@propertyId,@FromLocationID,SIH.Id),@DecimalPlace) AS QuantityInHand,
				ISNULL(dbo.FN_GetAveragePrice(@PropertyID, @FromLocationID, SIH.Id, 'RT', 0,  ISNULL( dbo.FN_GetMasterUnitID(@propertyId,@FromLocationID ,SIH.Id),0), 0),0) UnitPrice  
        FROM    dbo.StockItemDetails SID
                INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
				INNER JOIN 
				(SELECT SID2.StockItemHeaderID FROM StockItemDetails SID2 WHERE SID2.LocationID = @CurrentLocationID AND SID2.CompanyID = @Propertyid AND SID2.IsActive =1) TempTable ON TempTable.StockItemHeaderID = SIH.Id
				LEFT JOIN Categories CA ON CA.Id = SIH.CategoryID
				LEFT JOIN Units U ON U.Id = SID.MasterUnitID
        WHERE    SID.LocationID = @Locationid1 
                AND SID.PropertyID = @Propertyid1 
				AND SID.IsActive = 1
				AND ISNULL(SIH.IsProductionItem,0) = 0
				--AND SIH.Id IN (SELECT SID2.StockItemHeaderID FROM StockItemDetails SID2 WHERE SID2.LocationID = @CurrentLocationID AND SID2.CompanyID = @Propertyid)
				AND SIH.CategoryID = CASE WHEN @CategoryID = -999 THEN SIH.CategoryID ELSE @CategoryID END
				AND SIH.IsExpiryDateApplicable = CASE WHEN @IsWithoutExpiryDate =1 THEN 0 ELSE SIH.IsExpiryDateApplicable END

END TRY
BEGIN CATCH

	DECLARE @ErrorMessage NVARCHAR(4000);  
	DECLARE @ErrorSeverity INT;  
	DECLARE @ErrorState INT;  

	SELECT   
	@ErrorMessage = ERROR_MESSAGE(),  
	@ErrorSeverity = ERROR_SEVERITY(),  
	@ErrorState = ERROR_STATE(); 
	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

END CATCH;

END

GO

