-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-12-15
-- Description:	Inventory Day End SP for Store Locations

-- [dbo].[sp_INV_Store_DayEnd_ValidateSP] 1,1

-- =============================================
CREATE PROCEDURE [dbo].[sp_INV_Store_DayEnd_ValidateSP]
	@PropertyID INT,
	@LocationID INT
	
AS
BEGIN TRY
	BEGIN TRANSACTION
	SET NOCOUNT ON;

	DECLARE @IsLocationWiseDayendEnable BIT,@DayEndValidationMode CHAR(4),@TxnDate DATE
	,@IsProductionLocation BIT
	,@IsAutoProduction BIT
	,@LocationNames NVARCHAR(MAX),@IsEODReportSend BIT,@CompanyName VARCHAR(MAX);


	SELECT @TxnDate = CurrentDate,@IsProductionLocation = ISNULL(IsProductionLocation,0)
	FROM Locations
	WHERE ID = @LocationID 

	SELECT @IsLocationWiseDayendEnable =IsLocationWiseDayendEnable,@IsAutoProduction = ISNULL(IsAutoProduction,0),@CompanyName = Name
	,@IsEODReportSend = ISNULL(IsEODReportSend,0)
	FROM COMPANIES
	WHERE CompanyID =@PropertyID

	

	IF(@IsLocationWiseDayendEnable = 1)
	BEGIN

		SELECT @DayEndValidationMode = DayEndValidationMode
		FROM Locations
		WHERE ID = @LocationID

	
		IF(@DayEndValidationMode = 'OU')
		BEGIN
			---Checking pending Transfer In 

				IF EXISTS (SELECT 1 FROM STOCKTRANSACTIONHEADERS AS S1
							LEFT JOIN RequestHeaders RH ON RH.Id = S1.ReferenceID
				WHERE TRANSACTIONTYPE='TO' AND s1.PropertyID =@PropertyID AND IsTrasferIn=0 
				AND s1.TransferLocationID =  @LocationID 
				AND @TxnDate = CASE WHEN RH.Id IS NULL THEN S1.TransactionDate ELSE CONVERT( DATE,RH.DeliveryDate) END)
				BEGIN
					RAISERROR ( 'Pending Transfer In Found for Selected Location', 16, 1 );  
					ROLLBACK TRANSACTION
				END
			--End
		END

		IF(@DayEndValidationMode = 'ST')
		BEGIN
			---Checking pending Transfer In 
				--IF EXISTS (SELECT 1 FROM STOCKTRANSACTIONHEADERS WHERE TRANSACTIONTYPE='TO'AND PropertyID =@PropertyID AND IsTrasferIn=0 AND TransferLocationID =  @LocationID  AND TRANSACTIONDATE = @TxnDate)
				--BEGIN
				--	RAISERROR ( 'Pending Transfer In Found for Selected Location', 16, 1 );  
				--	ROLLBACK TRANSACTION
				--END
				IF EXISTS (SELECT 1 FROM STOCKTRANSACTIONHEADERS AS S1
							LEFT JOIN RequestHeaders RH ON RH.Id = S1.ReferenceID
				WHERE TRANSACTIONTYPE='TO' AND s1.PropertyID =@PropertyID AND IsTrasferIn=0 
				AND s1.TransferLocationID =  @LocationID 
				AND @TxnDate = CASE WHEN RH.Id IS NULL THEN S1.TransactionDate ELSE CONVERT( DATE,RH.DeliveryDate) END)
				BEGIN
					RAISERROR ( 'Pending Transfer In Found for Selected Location', 16, 1 );  
					ROLLBACK TRANSACTION
				END
			--End

			--Checking Pending Transfer Request
			   IF EXISTS(SELECT 1 FROM RequestHeaders WHERE IsApproved = 1 AND PropertyID = @PropertyID AND LocationID = @LocationID AND DeliveryDate = @TxnDate AND DocumentStatus='P' AND RequestType = 'RT')
			   BEGIN
				
				SELECT @LocationNames =
				STRING_AGG(LocationName, ', ')
				FROM (
				SELECT DISTINCT LO.Name AS LocationName
				FROM RequestHeaders RH
				INNER JOIN Locations LO ON RH.TransferLocation = LO.Id
				WHERE RH.IsApproved = 1
				AND RH.PropertyID = @PropertyID
				AND RH.LocationID = @LocationID
				AND RH.DeliveryDate = @TxnDate
				AND RH.DocumentStatus = 'P'
				AND RH.RequestType = 'RT'
				) X;

			   	RAISERROR ( 'Pending Transfer Request In Found for Selected Location from following Locations: %s', 16, 1,@LocationNames );  
					ROLLBACK TRANSACTION
			   END
			--End

			--Initiating Auto Production If any negative balance exists
			IF(@IsProductionLocation = 1 AND @IsAutoProduction = 1)
			BEGIN
				DECLARE @RecipeItemID INT,@RecipeQuantity DECIMAL(18,6),@RecipeUnitID INT,@RecipeQuantityVariance DECIMAL(18,6)
				DECLARE @ProductionOutHeaderID INT
				DECLARE @ProductionOutHeaderTable TABLE (ID INt)

				SELECT SD.StockItemHeaderID StockItemID,SD.QuantityInHand,MasterUnitID TxnUnitID
				INTO #TempRecipeDetails
				FROM StockItemHeaders SH WITH (NOLOCK)
				INNER JOIN StockItemDetails SD WITH (NOLOCK) ON SH.ID = SD.StockItemHeaderID
				WHERE SD.LocationID = @LocationID 
				AND SH.CompanyId = @PropertyID
				AND SH.IsProductionItem = 1
				AND SD.QuantityInHand < 0

					WHILE EXISTS(SELECT 1 FROM #TempRecipeDetails)
					BEGIN
						SELECT TOP (1) @RecipeItemID= StockItemID, @RecipeQuantity = QuantityInHand,@RecipeUnitID =  TxnUnitID 
						FROM #TempRecipeDetails

						IF EXISTS(SELECT 1
							FROM StockItemHeaders SH WITH (NOLOCK)
							INNER JOIN StockItemDetails SD WITH (NOLOCK) ON SH.Id = SD.StockItemHeaderID
							WHERE SH.Id = @RecipeItemID AND SD.LocationID = @LocationID AND SH.CompanyId = @PropertyID
							AND SH.IsProductionItem =1  
							AND SD.QuantityInHand < 0)
						BEGIN
							
							SELECT @RecipeQuantityVariance = ABS(SD.QuantityInHand)
							FROM StockItemHeaders SH WITH (NOLOCK)
							INNER JOIN StockItemDetails SD WITH (NOLOCK) ON SH.Id = SD.StockItemHeaderID
							WHERE SH.Id = @RecipeItemID AND SD.LocationID = @LocationID 
							AND SH.CompanyId = @PropertyID
							AND SH.IsProductionItem =1  
							AND SD.QuantityInHand < 0;

							IF EXISTS(SELECT 1 FROM Inv_RecipeDetails rd WITH (NOLOCK)
							INNER JOIN Inv_RecipeHeader rh WITH (NOLOCK) ON rd.RecipeHeaderId = rh.Id
							INNER JOIN Inv_ItemWiseRecipes ir WITH (NOLOCK) ON ir.RecipeId = rh.Id
							INNER JOIN StockItemDetails id WITH (NOLOCK) ON id.StockItemHeaderID = rd.StockItemId AND ir.LocationId = id.LocationID
							WHERE ir.StockItemId = @RecipeItemID )
							BEGIN
								select @LocationID LocationID,@RecipeItemID RecipeItemID,@PropertyID PropertyID,@RecipeUnitID  RecipeUnitID, @RecipeQuantityVariance RecipeQuantityVariance
								,@TxnDate TxnDate

								EXEC SaveProductionRecipeDetails  @LocationID,@RecipeItemID,@PropertyID ,@RecipeUnitID , @RecipeQuantityVariance,0,@TxnDate,1,@ProductionOutHeaderID OUTPUT 
								
								IF(@ProductionOutHeaderID IS NOT NULL)
								BEGIN
									INSERT INTO @ProductionOutHeaderTable (Id)
									values(@ProductionOutHeaderID)
								END
								
							END
						END
						DELETE TOP (1) FROM #TempRecipeDetails
					END


			END


			--End

		
		--Added by Isuru 2026-05-20
			DECLARE @EM_Subject VARCHAR(MAX)
			
			IF(@IsEODReportSend = 1)
			BEGIN
				
				SELECT @EM_Subject = 'EOD - '+CONVERT(VARCHAR, CurrentDate, 23) + ' - '+Name + ' '+@CompanyName
				FROM Locations
				WHERE ID = @LocationID

				INSERT INV_EODNotificationDetails(Outlet, EODDate, PropertyId, UserId, EmailSubject, IsMailSend, SysDate)
				VALUES (CONVERT(VARCHAR,@LocationID),@TxnDate,@PropertyID,'SYSTEM',@EM_Subject,0,GETDATE())

				SELECT *
				FROM INV_EODNotificationDetails

			
			END

			--End




			--Updating Location Current date 
			

			UPDATE Locations
			SET CurrentDate = DATEADD(DAY, 1, ISNULL(CurrentDate, CAST(GETDATE() AS DATE)))
			WHERE ID = @LocationID;

			
			--End


			

		END
	END



    
	
	
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

GO

