
 --- [dbo].[SP_GetALLPRFillDataBySup2] 1,1,1

CREATE PROCEDURE [dbo].[SP_GetALLPRFillDataBySup2]
	--[dbo].[SP_GetALLPRFillDataBySup2] 1,1,20 Add the parameters for the stored procedure here
    @Locationid INT ,
    @Propertyid INT,
	@Supplierid INT 
    WITH RECOMPILE
AS
    BEGIN
        DECLARE @Locationid1 INT= @Locationid ,
            @Propertyid1 INT = @Propertyid,@TemperatureApplicableAttributeId INT, @IsDefault BIT
         
		SELECT @TemperatureApplicableAttributeId = [TemperatureApplicableAttributeId] FROM CompanySettings WHERE CompanyId = @Propertyid

		SELECT @IsDefault = CheckForDefaultSupplier  FROM CommonSettings

        SELECT DISTINCT
                dbo.StockItemHeaders.Id ,
                dbo.StockItemHeaders.Name,
				dbo.StockItemHeaders.IsExpiryDateApplicable,
				IWA.IsActive AS IsTemperatureApplicable , sd.IsDefaultSupplier,
				StockItemHeaders.CategoryID
				,[dbo].[FN_GetContractedSupplier_ID](dbo.StockItemHeaders.Id,@Propertyid,@Locationid) ContractedSupplierID
				INTO #TempData

        FROM    dbo.StockItemDetails
                INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
				INNER JOIN dbo.SupplierWiseItemDetails SD ON sd.StockItemID=dbo.StockItemHeaders.Id  and sd.locationid=@Locationid1
				LEFT JOIN StockItemWiseAttributes IWA ON StockItemHeaders.Id = IWA.StockItemHeaderID 
				AND IWA.StockItemAttributeID = @TemperatureApplicableAttributeId AND IWA.IsActive = 1 
        WHERE   ( dbo.StockItemDetails.LocationID = @Locationid1 )
                AND ( dbo.StockItemDetails.PropertyID = @Propertyid1 ) AND SD.SupplierID=@Supplierid  AND StockItemDetails.IsActive=1  -- added by isuru 2023-03-22
				AND (SD.ValidTo >= GETDATE() OR SD.ValidTo IS NULL)
				--AND (GETDATE() BETWEEN SD.ValidFrom AND SD.ValidTo)

	IF @IsDefault = 0
		SELECT * FROM #TempData 
		ORDER BY Name
	IF @IsDefault =1 
		SELECT * FROM #TempData WHERE IsDefaultSupplier = 1  ORDER BY Name
    END

GO

