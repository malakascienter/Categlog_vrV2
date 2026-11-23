CREATE PROCEDURE [dbo].[SP_ApproveQuotation]( @Id INT, @Operation INT, @RejectReason VARCHAR(250),@UserId INT)

AS 
BEGIN
	begin try
	begin transaction
	IF(@Operation = 1)
	BEGIN 

	DECLARE  @SupplierId INT  , @SupplierDetailId INT ,@PropertyId INT

		SELECT * INTO #TempQuotProperty
		FROM QuotationWiseProperties
		WHERE QuotationHeaderId = @Id


		SELECT @SupplierId = SupplierId FROM SupplierQuotationHeader WHERE Id = @Id


		WHILE (SELECT COUNT(*) FROM  #TempQuotProperty) > 0
		BEGIN

				SELECT TOP(1) @PropertyId = PropertyId FROM #TempQuotProperty

				SELECT H.Id,H.SupplierId,D.ItemId,D.UnitId,D.UnitPrice,D.TaxGroupId,H.ValidFrom,H.ValidTo,H.IsDefaultSupplier 
				INTO #TempQ 
				FROM dbo.[SupplierQuotationHeader] H
				INNER JOIN [dbo].[SupplierQuotationDetails] D ON H.Id = D.QuotationHeaderId AND D.PropertyId = @PropertyId
				WHERE H.Id = @Id

				SELECT SD.LocationID,T.ItemId INTO #TempLoc
				FROM StockItemDetails SD
				INNER JOIN #TempQ T ON T.ItemId = SD.StockItemHeaderID

				declare @LocId INT
							
			WHILE (SELECT COUNT(*) FROM  #TempQ) > 0
			BEGIN


				SELECT TOP(1) * INTO #TempCheck FROM #TempQ

				SELECT TL.LocationID,TL.ItemId INTO #TempItemWiseLoc FROM #TempCheck TC
				INNER JOIN #TempLoc TL ON TC.ItemId = TL.ItemId

				SELECT * from #TempItemWiseLoc

										
			WHILE (SELECT COUNT(*) FROM  #TempItemWiseLoc) > 0
			BEGIN
			SELECT TOP(1)@LocId =  LocationId FROM #TempItemWiseLoc
---------------------------check default supplier---------------------------
				IF EXISTS(SELECT 1 FROM SupplierWiseItemDetails S
				INNER JOIN #TempCheck T ON S.CompanyId = @PropertyId 
				AND S.StockItemID = T.ItemId
				INNER JOIN dbo.Locations L ON L.Id = S.LocationId
				WHERE L.DefaultLocation = 1 AND S.IsDefaultSupplier = 1 AND T.IsDefaultSupplier = 1)
				BEGIN
					UPDATE S
					SET S.IsDefaultSupplier = 0
					FROM SupplierWiseItemDetails S
					INNER JOIN #TempCheck T ON S.CompanyId = @PropertyId 
					AND S.StockItemID = T.ItemId
					INNER JOIN dbo.Locations L ON L.Id = S.LocationId
					WHERE L.DefaultLocation = 1 AND S.IsDefaultSupplier = 1
				END
---------------------------check default supplier---------------------------

				IF EXISTS(SELECT 1 FROM SupplierWiseItemDetails S
				INNER JOIN #TempCheck T ON S.CompanyId = @PropertyId AND S.SupplierID = @SupplierId 
				AND S.StockItemID = T.ItemId
				INNER JOIN dbo.Locations L ON L.Id = S.LocationId
				WHERE L.DefaultLocation = 1 AND S.LocationId = @LocId)
				BEGIN

					UPDATE S
					SET S.PurchaseUnitID = T.UnitId, S.TaxGroupID = T.TaxGroupId, S.CostPrice = T.UnitPrice, S.ValidTo = T.ValidTo,
					S.ValidFrom = T.ValidFrom , S.CreatedDate = GETDATE(), S.LastModDate = GETDATE(), S.IsDefaultSupplier = T.IsDefaultSupplier
					FROM dbo.SupplierWiseItemDetails S
					INNER JOIN #TempCheck T ON S.CompanyId = @PropertyId AND S.SupplierID = @SupplierId 
					AND S.StockItemID = T.ItemId
					INNER JOIN dbo.Locations L ON L.Id = S.LocationId
					WHERE L.DefaultLocation = 1 AND S.LocationId = @LocId

				END 
				ELSE
				BEGIN			
					INSERT INTO dbo.SupplierWiseItemDetails (CompanyId,LocationId,SupplierID,StockItemID,PurchaseUnitID,CostPrice,IsDefaultSupplier,
					CreatedUserID,LastModUserID,CreatedDate,LastModDate,IPAddress,TBPHeaderID,TaxGroupID,ValidFrom,ValidTo)
					SELECT @PropertyId,L.Id,SupplierId,ItemId,UnitId,UnitPrice,t.IsDefaultSupplier,1,1,GETDATE(),GETDATE(),'','',TaxGroupId,ValidFrom,ValidTo
					FROM #TempQ t
					INNER JOIN dbo.Locations L ON L.CompanyID = @PropertyId 
					INNER JOIN StockItemDetails D ON D.locationId= l.Id and D.StockItemHeaderID = t.ItemId
					WHERE L.DefaultLocation = 1 AND L.Id = @LocId
				END
					DELETE TOP(1) FROM #TempItemWiseLoc
				END
				DROP TABLE #TempItemWiseLoc
				DROP TABLE #TempCheck
				DELETE TOP(1) FROM #TempQ
			END 
			DROP TABLE #TempQ
			DELETE TOP(1) FROM #TempQuotProperty

			DROP TABLE #TempLoc
		END




		UPDATE [dbo].[SupplierQuotationHeader] SET Status = 'C', ApprovedDate=GETDATE(),ApprovedUserId =@UserId WHERE Id = @Id
	END 

	IF(@Operation = 0 )
	BEGIN
		UPDATE [dbo].[SupplierQuotationHeader] SET Status = 'X', ApprovedDate=GETDATE(),ApprovedUserId =@UserId WHERE Id = @Id
	END 


commit transaction
end try
begin catch
	ROLLBACK TRANSACTION
	
	DECLARE @ErrorMessage NVARCHAR(4000);  
	DECLARE @ErrorSeverity INT;  
	DECLARE @ErrorState INT;  

	SELECT   
    @ErrorMessage = ERROR_MESSAGE(),  
    @ErrorSeverity = ERROR_SEVERITY(),  
    @ErrorState = ERROR_STATE(); 
	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
end catch
END

GO

