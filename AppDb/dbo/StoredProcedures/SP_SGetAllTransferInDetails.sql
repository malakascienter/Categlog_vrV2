-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-12-16
-- Description:	Loading All Transfer Note Details

-- [dbo].[SP_SGetAllTransferInDetails] 1,'RT',-999,'s',7

-- =============================================
CREATE PROCEDURE [dbo].[SP_SGetAllTransferInDetails]
@LocationID int,
@RequestType char(2),
@RequestHeaderID int,
@Operation char(1),
@ToLocation INT = -999
AS

DECLARE @propertyID INT 
DECLARE @DecimalPlace int

SELECT @propertyID = CompanyID FROM Locations 
WHERE Id= @LocationID

SELECT @DecimalPlace = DecimalPlaces
FROM Companies
WHERE CompanyID = @propertyId

BEGIN
    BEGIN TRY 
	BEGIN TRANSACTION
	SET NOCOUNT ON;

	DECLARE @TransferLocation INT,@IsBrandItem BIT
	SELECT @TransferLocation =TransferLocation
	FROM RequestHeaders
	WHERE ID=@RequestHeaderID

	--Checking transfering between outlet to outlet
	IF EXISTS ( SELECT COUNT(DISTINCT StockLocationID)   FROM Location_Ref   WHERE StockLocationID IN (@LocationID, @TransferLocation) 
		HAVING COUNT(DISTINCT StockLocationID) >= 2
	)
	BEGIN
		SET @IsBrandItem = 0

	END
	ELSE
	BEGIN
		SET @IsBrandItem = 1
	END

	--end

	SELECT  RequestHeaderId , RequestDetailsId , StockItemCode, ItemName, UnitCode, UnitPrice, DocumentNo, RequestedQuantity,ROUND(QuantityInHand,@DecimalPlace) AS QuantityInHand,
			RequestDate, Remarks, DocumentStatus,StockItemDetailsID, StockItemHeaderId , UnitId , ApprovedQuantity,BrandedItem,GenericCode,IsBranded
			,IsExpiryDateApplicable
			INTO #TempAllData
	FROM (
	SELECT       RequestHeaders.Id AS RequestHeaderId
				, StockItemDetails.Id AS StockItemDetailsID
				, RequestDetails.Id AS RequestDetailsId
				, StockItemHeaders.StockItemCode
				, StockItemHeaders.Name AS ItemName
				, Units.Name AS UnitCode
				, StockItemDetails.AveragePrice UnitPrice
				, RequestHeaders.DocumentNo
				, RequestDetails.RequestedQuantity
				,[dbo].[FN_GetStockInHand_Reatils](StockItemHeaders.CompanyId,StockItemDetails.LocationID,StockItemHeaders.Id) AS QuantityInHand
				, RequestHeaders.RequestDate
				, RequestDetails.Remarks
				, RequestHeaders.DocumentStatus
				, StockItemHeaders.Id AS StockItemHeaderId
				, Units.Id AS UnitId
				, StockItemHeaders.BrandedItem 
				,(select SH.StockItemCode 
				from RequestHeaders RH 
				INNER JOIN RequestDetails RD ON RH.Id = RD.RequestHeaderID
				 INNER JOIN StockItemHeaders SH ON SH.Id = RD.StockItemID
				WHERE SH.StockItemCode in (select GenericItemCode from StockItemHeaders)
				AND RH.Id = @RequestHeaderID AND SH.StockItemCode=StockItemHeaders.StockItemCode) AS GenericCode
				,(RequestDetails.ApprovedQuantity - RequestDetails.IssuedQuantity) AS ApprovedQuantity
				
				,(select 1 
				from RequestHeaders RH
				INNER JOIN RequestDetails RD ON RH.Id = RD.RequestHeaderID
				 INNER JOIN StockItemHeaders SH ON SH.Id = RD.StockItemID
				WHERE SH.StockItemCode in (select GenericItemCode from StockItemHeaders)
				AND RH.Id = @RequestHeaderID AND SH.StockItemCode=StockItemHeaders.StockItemCode) AS IsBranded
				, StockItemHeaders.IsExpiryDateApplicable
				-- END
				FROM		RequestHeaders INNER JOIN RequestDetails    ON RequestHeaders.Id= RequestDetails.RequestHeaderID 
				INNER JOIN Units      ON RequestDetails.UnitID = Units.Id
				INNER JOIN StockItemDetails ON RequestHeaders.LocationID = StockItemDetails.LocationID 
												AND RequestDetails.StockItemID = StockItemDetails.StockItemID 
				INNER JOIN StockItemHeaders  ON StockItemDetails.StockItemID = StockItemHeaders.Id
	WHERE        (RequestHeaders.LocationID = @LocationID)
				AND (RequestHeaders.TransferLocation = @ToLocation) 
				AND (RequestHeaders.RequestType = @RequestType) AND (RequestHeaders.IsApproved = 1) AND 
				 (RequestHeaders.Id = CASE WHEN @RequestHeaderID = -999 THEN RequestHeaders.Id ELSE @RequestHeaderID END) 
				 AND 
				 (RequestDetails.ApprovedQuantity - RequestDetails.IssuedQuantity) <> 0 AND
		       --(INV_RequestHeader.RequestHeaderID = @RequestHeaderID) AND (INV_RequestHeader.RequestDate = @RequestDate) AND 
				 (RequestHeaders.DocumentStatus = 'P')
	) AS d


		DECLARE @StockItemId INT, @Quantity DECIMAL, @Branded BIT, @GenericCode VARCHAR(500), @ItemName VARCHAR(500),@NotInError VARCHAR(500),
		@ToLocationId INT, @StockItemCode VARCHAR(500)
		
		select RD.*, SH.Name AS ItemName, SH.StockItemCode into #tempReqDetails 
		from RequestDetails RD
		inner join StockItemHeaders SH
		on SH.Id = RD.StockItemID
		where RD.RequestHeaderID = @RequestHeaderID

	

		SELECT Tt.* INTO #TempNot
		FROM #tempReqDetails Tt
		WHERE Tt.StockItemID NOT IN (	SELECT SID.StockItemHeaderID 
											FROM StockItemDetails  SID 
											WHERE SID.LocationID = @LocationID 
											and SID.StockItemId = Tt.StockItemID )

		--SELECT * FROM #TempNot

		if((SELECT COUNT(*) FROM #TempAllData) = 0 AND (SELECT COUNT(*) FROM #TempNot) = 0)
		BEGIN
			SET @NotInError =   'Items not exist !'
			RAISERROR ( @NotInError, 16, 1 );  
			ROLLBACK TRANSACTION
								
		end


		IF((SELECT COUNT(*) FROM #TempNot) = 0)
		BEGIN
				SELECT RequestHeaderId , RequestDetailsId , StockItemCode, ItemName, UnitCode, UnitPrice, DocumentNo, RequestedQuantity,ROUND(QuantityInHand,@DecimalPlace) AS QuantityInHand,
			RequestDate, Remarks, DocumentStatus,StockItemDetailsID, StockItemHeaderId , UnitId , ApprovedQuantity,BrandedItem,
			CASE WHEN @IsBrandItem = 0 THEN '' ELSE  GenericCode END AS GenericCode,
			CASE WHEN @IsBrandItem = 0 THEN 0 ELSE  IsBranded END AS IsBranded
			,IsExpiryDateApplicable
			FROM #TempAllData 
			WHERE ApprovedQuantity >0
			ORDER BY ItemName --RequestHeaderId, RequestDetailsId
		END
		ELSE
		BEGIN
			 
			IF EXISTS (SELECT TOP 1 ItemName FROM #TempNot tn
					LEFT OUTER JOIN StockItemHeaders H ON H.GenericItemCode= tn.StockItemCode
					LEFT OUTER JOIN StockItemDetails D ON D.StockItemHeaderID = h.Id
					AND D.LocationId  = @LocationID
					WHERE D.LocationId is null )

			BEGIN
	

					SELECT TOP 1 @ItemName=ItemName FROM #TempNot tn
					LEFT OUTER JOIN StockItemHeaders H ON H.GenericItemCode= tn.StockItemCode
					LEFT OUTER JOIN StockItemDetails D ON D.StockItemHeaderID = h.Id
					AND D.LocationId  = @LocationID
					WHERE D.LocationId is null 


					SET @NotInError =  @ItemName + ' - Not exists in this location !'
					RAISERROR ( @NotInError, 16, 1 );  
					ROLLBACK TRANSACTION
								
			END 

			DECLARE @BrandTable AS TABLE (ItemID INT, Qty MONEY, UnitID INT )
			DECLARE @SelectedBrandTable AS TABLE (ItemID INT, Qty MONEY)

			
			
			DECLARE @CurItemID int, @CurQTY MONEY, @BalQTY MONEY, @BrandItemID INT, @UnitID INT ,@CurQTYFrom INT,@CurQTYTo INT

			WHILE (SELECT COUNT(*) FROM #TempNot) > 0
			BEGIN
				
				SELECT TOP 1 @CurItemID= t.StockItemID , @CurQTY= ApprovedQuantity,@CurQTYFrom = ApprovedQuantity, @UnitID= t.UnitId
				FROM #TempNot T
                
				INSERT INTO @BrandTable (ItemID , Qty, UnitID)
				SELECT H.ID , 
				--D.QuantityInHand, 
				[dbo].[FN_GetStockInHand_Reatils](H.CompanyId,D.LocationID,H.Id) AS QuantityInHand,
				D.MasterUnitID
				FROM #TempNot T
				INNER JOIN StockItemHeaders H ON H.GenericItemCode= t.StockItemCode
				INNER JOIN StockItemDetails D ON D.StockItemHeaderID = h.Id
				WHERE D.LocationId  = @LocationID  and t.StockItemID = @CurItemID

			
                
				SELECT @CurQTYTo = dbo.FN_GetUnitConvertionRate(@propertyID,@UnitID,UnitID) 
				FROM @BrandTable


				SET @CurQTYTo = @CurQTYTo * @CurQTYFrom 
                
				WHILE EXISTS(SELECT  TOP 1 1 FROM @BrandTable) AND @CurQTYTo > 0
				BEGIN


					SELECT	TOP (1) @BrandItemID =  ItemID, 
							@BalQTY =   CASE WHEN Qty >  @CurQTYTo THEN @CurQTYTo ELSE Qty END 
					FROM @BrandTable
					ORDER BY Qty DESC

					SET @CurQTYTo -= @BalQTY

					INSERT INTO @SelectedBrandTable (ItemID , Qty)
					VALUES (@BrandItemID,@BalQTY)
					
					DELETE FROM @BrandTable WHERE  ItemID = @BrandItemID

				END 

				UPDATE TOP (1) @SelectedBrandTable
				SET Qty+= @CurQTYTo

				UPDATE #TempAllData
				SET ApprovedQuantity = 0
				WHERE StockItemHeaderId = @CurItemID


				DELETE FROM #TempNot
				WHERE StockItemID = @CurItemID
				
			END 
		

			INSERT INTO #TempAllData (RequestHeaderId,RequestDetailsId,RequestedQuantity,QuantityInHand,RequestDate,
									  StockItemDetailsID,
									  StockItemCode, ItemName, UnitCode, UnitPrice, Remarks, StockItemHeaderId , UnitId , ApprovedQuantity,BrandedItem,GenericCode,IsBranded,IsExpiryDateApplicable)
			SELECT 0,0,0,
			--D.QuantityInHand,
			[dbo].[FN_GetStockInHand_Reatils](H.CompanyId,D.LocationID,H.Id) AS QuantityInHand,
			GETDATE(),0,  StockItemCode, H.NAME ItemName, U.Code UnitCode, D.AveragePrice UnitPrice, '' Remarks, t.ItemID , U.ID UnitId , t.Qty,H.BrandedItem,H.GenericItemCode,1
			, H.IsExpiryDateApplicable
			FROM @SelectedBrandTable T
			INNER JOIN StockItemHeaders H ON H.ID = T.ItemID 
			INNER JOIN StockItemDetails D ON D.StockItemHeaderID = T.ItemID 
			INNER JOIN Units U ON U.Id = D.MasterUnitID
			LEFT JOIN RequestHeaders rh ON rh.Id = @RequestHeaderID
			WHERE D.LocationID = @LocationID AND rh.DocumentStatus = 'P'


			SELECT RequestHeaderId , RequestDetailsId , StockItemCode, ItemName, UnitCode, UnitPrice, DocumentNo, RequestedQuantity,ROUND(QuantityInHand,@DecimalPlace) AS QuantityInHand,
			RequestDate, Remarks, DocumentStatus,StockItemDetailsID, StockItemHeaderId , UnitId , ApprovedQuantity,BrandedItem,
			CASE WHEN @IsBrandItem = 0 THEN '' ELSE  GenericCode END AS GenericCode,
			CASE WHEN @IsBrandItem = 0 THEN 0 ELSE  IsBranded END AS IsBranded
			,IsExpiryDateApplicable
			FROM #TempAllData
		WHERE ApprovedQuantity >0
		ORDER BY ItemName --RequestHeaderId, RequestDetailsId
		END



    
COMMIT TRAN
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



    END CATCH;
END

GO

