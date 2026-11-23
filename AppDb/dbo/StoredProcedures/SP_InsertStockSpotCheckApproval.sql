
CREATE PROCEDURE [dbo].[SP_InsertStockSpotCheckApproval] 
	@HeaderID INT,
	@LocationID INT,
	@PropertyID INT,
	@LevelNo INT,
	@UserID INT,
	@DetailsJson NVARCHAR(MAX)
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY 
		BEGIN TRANSACTION
			IF(@PropertyID IS NULL)
			BEGIN
				RAISERROR('Property Invalid',16,1)
				ROLLBACK TRANSACTION
			END
			IF(@HeaderID IS NULL)
			BEGIN
				RAISERROR('Not exists',16,1)
				ROLLBACK TRANSACTION
			END
			IF(@LocationID IS NULL)
			BEGIN
				RAISERROR('Location Invalid',16,1)
				ROLLBACK TRANSACTION
			END
			IF(@LevelNo IS NULL)
			BEGIN
				RAISERROR('Level Invalid',16,1)
				ROLLBACK TRANSACTION
			END
			IF(@UserID IS NULL)
			BEGIN
				RAISERROR('User Invalid',16,1)
				ROLLBACK TRANSACTION
			END

			IF NOT EXISTS(SELECT 1 FROM StockSpotApprovalLog S WHERE StockSpotHeaderID = @HeaderID AND LocationID = @LocationID AND PropertyID = @PropertyID AND levelNo =@LevelNo)
			BEGIN
				RAISERROR('Not exists',16,1)
				ROLLBACK TRANSACTION
			END

			IF EXISTS(SELECT 1 FROM StockSpotApprovalLog S WHERE StockSpotHeaderID = @HeaderID AND LocationID = @LocationID AND PropertyID = @PropertyID AND levelNo =@LevelNo AND Status = 'C' AND IsApproved =1)
			BEGIN
				RAISERROR('Already approved',16,1)
				ROLLBACK TRANSACTION				
			END


			CREATE TABLE #TempDetails (  ID INT, StockSpotHeaderID INT, StockItemID INT,QuantityInHand DECIMAL(18,2)
			,PhysicalQty DECIMAL(18,2), StockItemCode NVARCHAR(MAX)
			,ItemName NVARCHAR(MAX),Variance DECIMAL(18,2), IsRemarkMandatory BIT, VarianceReason NVARCHAR(MAX))

			DECLARE @TransactionDate DATETIME
			DECLARE @XMLDataPU XML, @XMLHeaderPU XML,@TransactionHeaderID BIGINT


			CREATE TABLE #DataDetails_Temp (
			StockItemID INT,
			Quantity DECIMAL(20,10),
			MasterUnitID INT,
			LocationID INT,
			CreatedUserID INT DEFAULT 0,
			LastModUserID INT DEFAULT 0,
			UserProfileId INT DEFAULT 0,
			TxnType NVARCHAR(50),
			UnitPrice DECIMAL(20,10) DEFAULT 0,
			TxnUnitID INT DEFAULT 0,
			DiscountValue DECIMAL DEFAULT 0,
			DiscountPercentage DECIMAL DEFAULT 0,
			BalanceQuantity DECIMAL DEFAULT 0,
			ReturnQuantity DECIMAL DEFAULT 0,
			QuantityInHand DECIMAL DEFAULT 0,
			isExpiryDateApplicable BIT DEFAULT 0,
			EXPDate DATETIME
		)

		CREATE TABLE #DataHeader_Temp (
			TransactionType NVARCHAR(5) NOT NULL DEFAULT '',
			PropertyID INT NOT NULL DEFAULT 0,
			LocationID INT NOT NULL DEFAULT 0,
			Remarks NVARCHAR(250) NOT NULL DEFAULT '',
			UserProfileID INT NOT NULL DEFAULT 0,
			CreatedUserID INT NOT NULL DEFAULT 0,
			LastModUserID INT NOT NULL DEFAULT 0,
			Mode CHAR(1) NOT NULL DEFAULT '',
			SupplierID INT NOT NULL DEFAULT 0,
			ReferenceID INT NOT NULL DEFAULT 0,
			DepartmentID INT NOT NULL DEFAULT 0,
			TransferLocationID INT NOT NULL DEFAULT 0,
			SuppCurrencyID INT NOT NULL DEFAULT 0,
			isExpiryDateApplicable BIT NOT NULL DEFAULT 0,
			EXPDate DATETIME NOT NULL DEFAULT '1900-01-01',
			TransactionDate DATETIME NOT NULL  DEFAULT GETDATE(),
			IsProdGenerate BIT,
		);

			INSERT INTO #TempDetails (ID ,StockSpotHeaderID,StockItemID ,QuantityInHand,PhysicalQty  ,StockItemCode,ItemName ,Variance,IsRemarkMandatory ,VarianceReason)
			SELECT ID ,StockSpotHeaderID,StockItemID ,QuantityInHand,PhysicalQty  ,StockItemCode,ItemName ,Variance,IsRemarkMandatory ,VarianceReason
			FROM OPENJSON(@DetailsJson)
			WITH (
			ID INT,
			StockSpotHeaderID INT,
			StockItemID INT,
			QuantityInHand DECIMAL(18,2),
			PhysicalQty DECIMAL(18,2),
			StockItemCode NVARCHAR(100),
			ItemName NVARCHAR(200),
			Variance DECIMAL(18,2),
			IsRemarkMandatory BIT,
			VarianceReason NVARCHAR(500)
			);


			IF (@LevelNo =1)
			BEGIN
		-- Insert statements for procedure here
				UPDATE S
				SET Status = 'C',IsApproved =1,
				ApprovedUserID = @UserID, ApprovedDate = GETDATE()
				--SELECT *
				FROM StockSpotApprovalLog S
				WHERE StockSpotHeaderID = @HeaderID AND LocationID = @LocationID AND PropertyID = @PropertyID AND
				levelNo =@LevelNo;
				
				UPDATE StockSpotCheckHeader
				SET firstlevel =1
				WHERE ID = @HeaderID AND LocationID = @LocationID AND PropertyID = @PropertyID 


				UPDATE STD
				SET STD.FirstLevelRemark = TD.VarianceReason
				FROM #TempDetails TD
				INNER JOIN StockSpotCheckDetail STD ON TD.StockSpotHeaderID = STD.StockSpotHeaderID 
				AND TD.StockItemID = STD.StockItemID
				WHERE STD.StockSpotHeaderID = @HeaderID


				---Added by Isuru 2026-05-06 insert AA in first level approval
				SELECT @TransactionDate = CONVERT(DATE,SpotCheckDate)
				FROM StockSpotCheckHeader
				WHERE ID = @HeaderID AND LocationID = @LocationID AND PropertyID = @PropertyID


				INSERT INTO #DataHeader_Temp (TransactionType, PropertyID, LocationID, CreatedUserID,TransactionDate,Remarks,IsProdGenerate)
				VALUES ('AA', @PropertyID, @LocationID, @UserID,@TransactionDate,'SPOT Check',0 );

				INSERT INTO #DataDetails_Temp (StockItemID,Quantity,TxnUnitID,MasterUnitID,LocationID,UserProfileId,TxnType,QuantityInHand,UnitPrice)
				SELECT STD.StockItemID,STD.PhysicalQty
				,dbo.FN_GetMasterUnitID(@PropertyId,@LocationID,STD.StockItemID),dbo.FN_GetMasterUnitID(@PropertyId,@LocationID,STD.StockItemID)
				,STP.LocationID,@UserID
				,CASE WHEN STD.PhysicalQty > STD.QuantityInHand THEN 'P'
				WHEN STD.PhysicalQty < STD.QuantityInHand THEN 'M' END AS TxnType,STD.QuantityInHand
				,[dbo].[FN_GetLastAveragePrice](@LocationID,STD.StockItemId)
				FROM StockSpotCheckHeader STP
				INNER JOIN StockSpotCheckDetail STD ON STP.ID = STD.StockSpotHeaderID
				WHERE STP.ID = @HeaderID AND LocationID = @LocationID AND PropertyID = @PropertyID

				SET @XMLHeaderPU = ( SELECT * FROM #DataHeader_Temp WHERE Transactiontype = 'AA' for xml path('StockTransactionHeader'))

				SET @XMLDataPU = (SELECT * FROM #DataDetails_Temp for xml path ('StockTransactionDetail'),root('StockDetailList'))

				SET @XMLHeaderPU.modify('insert sql:variable("@XMLDataPU") as first into (/StockTransactionHeader)[1]')


				EXEC SP_InsertStockTransactions @XMLHeaderPU,'',0,'',@TransactionHeaderID OUTPUT,0

				UPDATE StockSpotCheckHeader
				SET TransactionHeaderID = @TransactionHeaderID
				WHERE ID = @HeaderID AND LocationID = @LocationID AND PropertyID = @PropertyID

				--End

				--SELECT 'S2',@HeaderID,@LocationID,@PropertyID,'P'
				EXEC [dbo].[SendTransactionWiseEmailS] 'S2',@HeaderID,@LocationID,@PropertyID,'P'
			END
			ELSE IF (@LevelNo =2)
			BEGIN
				IF NOT EXISTS(SELECT 1 FROM StockSpotApprovalLog S WHERE StockSpotHeaderID = @HeaderID AND LocationID = @LocationID AND PropertyID = @PropertyID AND levelNo =1 AND Status = 'C' AND IsApproved =1)
				BEGIN
					RAISERROR('Please approve first level',16,1)
					ROLLBACK TRANSACTION				
				END
				ELSE
				BEGIN
		-- Insert statements for procedure here
				UPDATE S
				SET Status = 'C',IsApproved =1,
				ApprovedUserID = @UserID, ApprovedDate = GETDATE()
				--SELECT *
				FROM StockSpotApprovalLog S
				WHERE StockSpotHeaderID = @HeaderID AND LocationID = @LocationID AND PropertyID = @PropertyID AND
				levelNo =@LevelNo					
				END

				

				--SELECT @TransactionDate = CONVERT(DATE,SpotCheckDate)
				--FROM StockSpotCheckHeader
				--WHERE ID = @HeaderID AND LocationID = @LocationID AND PropertyID = @PropertyID


				UPDATE STD
				SET STD.SecondLevelRemark = TD.VarianceReason
				FROM #TempDetails TD
				INNER JOIN StockSpotCheckDetail STD ON TD.StockSpotHeaderID = STD.StockSpotHeaderID 
				AND TD.StockItemID = STD.StockItemID
				WHERE STD.StockSpotHeaderID = @HeaderID


				--INSERT INTO #DataHeader_Temp (TransactionType, PropertyID, LocationID, CreatedUserID,TransactionDate,Remarks,IsProdGenerate)
				--VALUES ('AA', @PropertyID, @LocationID, @UserID,@TransactionDate,'SPOT Check',0 );

				--INSERT INTO #DataDetails_Temp (StockItemID,Quantity,TxnUnitID,MasterUnitID,LocationID,UserProfileId,TxnType,QuantityInHand,UnitPrice)
				--SELECT STD.StockItemID,STD.PhysicalQty
				--,dbo.FN_GetMasterUnitID(@PropertyId,@LocationID,STD.StockItemID),dbo.FN_GetMasterUnitID(@PropertyId,@LocationID,STD.StockItemID)
				--,STP.LocationID,@UserID
				--,CASE WHEN STD.PhysicalQty > STD.QuantityInHand THEN 'P'
				--WHEN STD.PhysicalQty < STD.QuantityInHand THEN 'M' END AS TxnType,STD.QuantityInHand
				--,[dbo].[FN_GetLastAveragePrice](@LocationID,STD.StockItemId)
				--FROM StockSpotCheckHeader STP
				--INNER JOIN StockSpotCheckDetail STD ON STP.ID = STD.StockSpotHeaderID
				--WHERE STP.ID = @HeaderID AND LocationID = @LocationID AND PropertyID = @PropertyID


				--SET @XMLHeaderPU = ( SELECT * FROM #DataHeader_Temp WHERE Transactiontype = 'AA' for xml path('StockTransactionHeader'))

				--SET @XMLDataPU = (SELECT * FROM #DataDetails_Temp for xml path ('StockTransactionDetail'),root('StockDetailList'))

				--SET @XMLHeaderPU.modify('insert sql:variable("@XMLDataPU") as first into (/StockTransactionHeader)[1]')


				IF EXISTS(SELECT 1
				FROM StockSpotApprovalLog
				WHERE Status = 'C' and IsApproved =1 and StockSpotHeaderID =@HeaderID
				GROUP BY StockSpotHeaderID
				HAVING COUNT(DISTINCT LevelNo) = 2)
				BEGIN
					UPDATE StockSpotCheckHeader
					SET isapprove =1, secondlevel =1
					WHERE ID = @HeaderID AND LocationID = @LocationID AND PropertyID = @PropertyID

					--EXEC SP_InsertStockTransactions @XMLHeaderPU,'',0,'',@TransactionHeaderID OUTPUT,0

					--UPDATE StockSpotCheckHeader
					--SET TransactionHeaderID = @TransactionHeaderID
					--WHERE ID = @HeaderID AND LocationID = @LocationID AND PropertyID = @PropertyID
					
					EXEC [dbo].[SendTransactionWiseEmailS] 'SS',@HeaderID,@LocationID,@PropertyID,'C'
				END
			END

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0
		ROLLBACK TRANSACTION
			DECLARE @ErrorMessage NVARCHAR(4000);  
			DECLARE @ErrorSeverity INT;  
			DECLARE @ErrorState INT;  

			SELECT
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

			-- 2026-08-05: replaced by the THROW below.
			-- RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
			THROW;
	END CATCH;
END

GO

