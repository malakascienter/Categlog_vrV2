CREATE PROCEDURE [dbo].[SP_Update_StockItemDetails] 
	
	@PropertyID					INT,
	@LocationID					INT,
	@StockItemID				bigINT,
	--@MasterUnitID				INT = 0,
	--@PurchasingUnitID			INT = 0,
	@MinimumQuantity			FLOAT,
	@MaximumQuantity			FLOAT,
	@ReOrderLevel				FLOAT,
	@ReOrderQuantity			FLOAT,
	--@PurchaseAccountID			VARCHAR(50),
	--@CostOfSalesAccountID		VARCHAR(50),
	@SellingPrice               MONEY,
	@CostPrice					MONEY,
	@MasterUnitID INT,
	@IsActive					BIT,
	@UserID						INT,
	--02.04.2024 - 
	@ItemAge int
	--@CreatedUserID				INT,
	--@LastModUserID				INT,
	
	
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
	    DECLARE @OldMasterUnitId INT,
		@QtyInHand DECIMAL(18,6), @OldSellingPrice MONEY,@BusinessDate DATE,@OldIsActive BIT


		SELECT @BusinessDate =CurrentDate
		FROM Companies 
		WHERE CompanyID = @PropertyID

		SELECT @OldMasterUnitId =  MasterUnitID ,@QtyInHand = QuantityInHand,@OldSellingPrice = SellingPrice,@OldIsActive = IsActive
		FROM StockItemDetails 
		WHERE StockItemHeaderID = @StockItemID 
		AND LocationID =@LocationID AND CompanyID = @PropertyID

		IF(@OldMasterUnitId <> @MasterUnitID)
		BEGIN
			IF EXISTS(SELECT 1 FROM StockTransactionDetails SD 
					 INNER JOIN StockTransactionHeaders SH  ON SH.Id =SD.StockTransactionHeaderID
					 WHERE SD.StockItemID = @StockItemID AND SH.LocationID = @LocationID AND SH.PropertyID = @PropertyID
					 UNION
					 SELECT 1 FROM RequestDetails RD 
					 INNER JOIN RequestHeaders RH  ON RH.Id = RD.RequestHeaderID
					 WHERE RD.StockItemID = @StockItemID AND RH.LocationID = @LocationID AND RH.PropertyID = @PropertyID
					  UNION
					 SELECT 1 FROM PoDetails PD 
					 INNER JOIN PoHeaders PH  ON PH.Id =PD.PoHeaderID
					 WHERE PD.StockItemID= @StockItemID AND PH.LocationID = @LocationID AND PH.PropertyID = @PropertyID)
					 BEGIN
						RAISERROR ( 'Cannot update unit, transaction already exists for this item !', 16, 1 );  
						ROLLBACK TRANSACTION
	
	
	END
	------- NEWLY ADDED 19.02.2024------------------------------------------------------------------------------------
	--else

	--	BEGIN
	--	    SELECT 1 FROM StockTransactionDetails	WHERE StockItemID = @StockItemID
	--	UNION ALL
	--		SELECT DISTINCT 1 FROM RequestDetails 	WHERE StockItemID= @StockItemID
	--	UNION ALL
	--	SELECT DISTINCT 1 	FROM StockTransactionDetails WHERE StockItemID = @StockItemID
		
	--	BEGIN
	--					RAISERROR ( 'Cannot update unit, transaction already exists for this item !', 16, 1 );  
	--					ROLLBACK TRANSACTION
	--	END

	--	END
--------------------------------------------------------------------------------------------------------------------------	

		END






		IF(@QtyInHand >0 AND @OldIsActive = 1) -- change by Tharuka 2026-08-07 
		BEGIN
			RAISERROR ( 'Cannot update unit, Stock In Hand Found for Location!', 16, 1 );  
			ROLLBACK TRANSACTION
		END



		IF(@OldSellingPrice <> @SellingPrice)
		BEGIN
		INSERT INTO SellingPrice_ChangeLog
                  (PropertyID,LocationID,SellingPrice,StockItemID,UserID,BusinessDate,CreatedDate)
		SELECT @PropertyID,@LocationID,@SellingPrice,@StockItemID,@UserID,@BusinessDate,GETDATE()
		END


		--Remove from InactiveStockItemTable if item exists
		IF EXISTS(SELECT 1 FROM InactiveStockItemTable WHERE StockItemID = @StockItemID AND PropertyID = @PropertyID AND LocationID =	@LocationID)
		BEGIN
			IF(@IsActive = 1)
			BEGIN
				DELETE FROM InactiveStockItemTable
				WHERE StockItemID = @StockItemID AND PropertyID = @PropertyID AND LocationID =	@LocationID
			END
		END

		--End

	
		UPDATE dbo.StockItemDetails
		SET

			--MasterUnitID			=	@MasterUnitID,
			--PurchasingUnitID		=	@PurchasingUnitID,
			MinimumQuantity			=	@MinimumQuantity,
			MaximumQuantity			=	@MaximumQuantity,
			ReOrderLevel			=	@ReOrderLevel,
			ReOrderQuantity			=	@ReOrderQuantity,
			--PurchaseAccountID		=	@PurchaseAccountID,
			--CostOfSalesAccountID	=	@CostOfSalesAccountID,			
			--CostPrice				=	@CostPrice,
			SellingPrice            =   @SellingPrice,
			IsActive				=	@IsActive,
			LastModDate				=	GETDATE(),
			--LastModUserID			=	@LastModUserID
			MasterUnitID            =   @MasterUnitID,
			-- 02.04.2024------------------------------
			ItemAge  = @ItemAge
			-------------------------------------------
		WHERE LocationID =	@LocationID AND StockItemHeaderID = @StockItemID and PropertyID = @PropertyID

		-----------------Log StockItemDetails Update Added By Nivesh 2024-03-14-------------------
		IF EXISTS (SELECT 1 FROM dbo.StockItemDetails WHERE LocationID =	@LocationID AND StockItemHeaderID = @StockItemID and PropertyID = @PropertyID)
		BEGIN
			DECLARE @TempID INT
			SELECT @TempID = ID FROM dbo.StockItemDetails WHERE LocationID =	@LocationID AND StockItemHeaderID = @StockItemID and PropertyID = @PropertyID

			EXEC Inventry_AuditTail_WriteToLog 'StockItemDetails', @TempID, 'INV', 'SIDU', 'U', @UserId,@PropertyId, '', ''
		END
		------------------------------------------------------------------------------------------
	COMMIT TRANSACTION
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
END

GO

