-- =============================================
-- Author:		Nivesh
-- Create date: 2025-03-30
-- Description:	Update rejected transaction
-- =============================================
-- SP_Update_CommonTransaction 1, 4168,5,3087,2,'[]',0,''

CREATE PROCEDURE [dbo].[SP_Update_CommonTransaction] 
	@CompanyId INT ,
	@UserProfileId INT ,
	@TransactionID INT ,
	@TransactionHeaderID INT ,
	@TransactionStatusID INT,
	@JsonMultiTransactionIDs VARCHAR(MAX),
	@RowsAffected INT OUTPUT, 
	@RejectReason VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SET @RowsAffected = 0;
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

	CREATE TABLE #TempMulIDS(
		ID INT
	)
    BEGIN TRY
        -- Start transaction
        BEGIN TRANSACTION;
	
	IF(@TransactionStatusID = 2)
	BEGIN
		IF(@TransactionID =5) -- Transfer OUT
		BEGIN
			
			DECLARE @ApprovalDocNo VARCHAR(500)

			SELECT @ApprovalDocNo = ApprovalDocNo
			FROM GRNApprovalLog
			WHERE ID = @TransactionHeaderID


			UPDATE  GRNApprovalLog
			SET Status = 'X',ApprovedUserId = @UserProfileId
			,ApprovedDateTime = GETDATE()
			WHERE ApprovalDocNo = @ApprovalDocNo
			AND CompanyId = @CompanyId
			AND Status = 'P'

			
			SET @RowsAffected = @@ROWCOUNT;

			SELECT @RowsAffected 

			INSERT INTO [dbo].[CommonTransactionStatusLog]([CompanyID],[TransactionID] ,[TransactionHeaderID],[TransactionStatusID],[Status],[CreatedDate] ,[UserProfileID] ,[RejectedReason])
			VALUES(@CompanyId ,@TransactionID,@TransactionHeaderID ,@TransactionStatusID,'X',GETDATE() ,@UserProfileId, @RejectReason)

		END

	END

	IF(@TransactionStatusID = 3) -- Rejection
	BEGIN
		IF (@TransactionHeaderID <> 0)
		BEGIN
			IF(@TransactionID =2) -- Purchase Order
			BEGIN
				UPDATE PoHeaders
				SET DocumentStatus ='X', -- Reject
				--IsApproved =0,
				LastModUserID = @UserProfileId
				WHERE PropertyID =@CompanyId AND Id = @TransactionHeaderID

				SET @RowsAffected = @@ROWCOUNT;

				IF EXISTS(SELECT 1 FROM PoHeaders WHERE PropertyID =@CompanyId AND Id = @TransactionHeaderID)
				BEGIN
					INSERT INTO [dbo].[CommonTransactionStatusLog]([CompanyID],[TransactionID] ,[TransactionHeaderID],[TransactionStatusID],[Status],[CreatedDate] ,[UserProfileID] ,[RejectedReason])
					VALUES(@CompanyId ,@TransactionID,@TransactionHeaderID ,@TransactionStatusID,'X',GETDATE() ,@UserProfileId, @RejectReason)
				END
				

			END
			ELSE IF (@TransactionID = 78) -- ADDED Tharuka 2026-08-10 - Production Process Plan (PL), single record
			BEGIN
				UPDATE ProductionConsolidateHeader
				SET Status = 'X' 
				WHERE ID = @TransactionHeaderID
				AND PropertyID = CASE WHEN @CompanyId = -999 THEN PropertyID ELSE @CompanyId END
				AND ISNULL(IsTransferComplete,0) = 0	-- a repeated click becomes a no-op instead of a silent double close

				SET @RowsAffected = @@ROWCOUNT;

				IF EXISTS(SELECT 1 FROM ProductionConsolidateHeader
						  WHERE ID = @TransactionHeaderID
						  AND PropertyID = CASE WHEN @CompanyId = -999 THEN PropertyID ELSE @CompanyId END)
				BEGIN
					INSERT INTO [dbo].[CommonTransactionStatusLog]([CompanyID],[TransactionID] ,[TransactionHeaderID],[TransactionStatusID],[Status],[CreatedDate] ,[UserProfileID])
					VALUES(@CompanyId ,@TransactionID,@TransactionHeaderID ,@TransactionStatusID,'C',GETDATE() ,@UserProfileId)
				END
			END
			ELSE IF (@TransactionID= 1 OR @TransactionID= 11 OR @TransactionID= 8 OR @TransactionID= 14) -- Purchase Request, Issue Request, Transfer Request ,Damage Request Note
			BEGIN
				 UPDATE RequestHeaders 
				 SET DocumentStatus = 'X',
				-- IsApproved =0,
				 LastModUserID = @UserProfileId
				 WHERE Id = @TransactionHeaderID 
				 AND PropertyID = @CompanyId

				 SET @RowsAffected = @@ROWCOUNT;

				IF EXISTS(SELECT 1 FROM RequestHeaders  WHERE Id = @TransactionHeaderID 
				 AND PropertyID = @CompanyId)
				BEGIN
						INSERT INTO [dbo].[CommonTransactionStatusLog]([CompanyID],[TransactionID] ,[TransactionHeaderID],[TransactionStatusID],[Status],[CreatedDate] ,[UserProfileID] ,[RejectedReason])
						VALUES(@CompanyId ,@TransactionID,@TransactionHeaderID ,@TransactionStatusID,'X',GETDATE() ,@UserProfileId, @RejectReason)
					
				END
			END

			--SET @RowsAffected = @@ROWCOUNT;
		END
		ELSE IF (@TransactionHeaderID =0)
		BEGIN
			INSERT INTO #TempMulIDS
			SELECT value AS Id
			FROM OPENJSON(@JsonMultiTransactionIDs);

			

			IF(@TransactionID =2)
			BEGIN
				UPDATE PoHeaders
				SET DocumentStatus ='X',
				--IsApproved =0,
				LastModUserID = @UserProfileId
				WHERE PropertyID =@CompanyId AND Id IN (SELECT Id FROM #TempMulIDS)

				SET @RowsAffected = @@ROWCOUNT;

				IF EXISTS(SELECT 1 FROM PoHeaders WHERE PropertyID =@CompanyId AND Id IN (SELECT Id FROM #TempMulIDS))
				BEGIN

					WHILE EXISTS( SELECT 1 FROM #TempMulIDS)
					BEGIN
						SELECT TOP (1) @TransactionHeaderID = Id  FROM #TempMulIDS
						
						INSERT INTO [dbo].[CommonTransactionStatusLog]([CompanyID],[TransactionID] ,[TransactionHeaderID],[TransactionStatusID],[Status],[CreatedDate] ,[UserProfileID] ,[RejectedReason])
						VALUES(@CompanyId ,@TransactionID,@TransactionHeaderID ,@TransactionStatusID,'X',GETDATE() ,@UserProfileId, @RejectReason)

						DELETE TOP (1) FROM #TempMulIDS
					END
				
				END
			END
			ELSE IF (@TransactionID = 78) -- ADDED 2026-08-10 - Production Process Plan (PL), multi select
			BEGIN
				
				UPDATE ProductionConsolidateHeader
				SET Status = 'C'
				WHERE ID IN (SELECT Id FROM #TempMulIDS)
				AND PropertyID = CASE WHEN @CompanyId = -999 THEN PropertyID ELSE @CompanyId END
				AND ISNULL(IsTransferComplete,0) = 0	-- a repeated click becomes a no-op instead of a silent double close

				SET @RowsAffected = @@ROWCOUNT;

				IF EXISTS(SELECT 1 FROM ProductionConsolidateHeader
						  WHERE ID IN (SELECT Id FROM #TempMulIDS)
						  AND PropertyID = CASE WHEN @CompanyId = -999 THEN PropertyID ELSE @CompanyId END)
				BEGIN
					WHILE EXISTS( SELECT 1 FROM #TempMulIDS)
					BEGIN
						SELECT TOP (1) @TransactionHeaderID = Id FROM #TempMulIDS

						INSERT INTO [dbo].[CommonTransactionStatusLog]([CompanyID],[TransactionID] ,[TransactionHeaderID],[TransactionStatusID],[Status],[CreatedDate] ,[UserProfileID])
						VALUES(@CompanyId ,@TransactionID,@TransactionHeaderID ,@TransactionStatusID,'C',GETDATE() ,@UserProfileId)

						DELETE TOP (1) FROM #TempMulIDS
					END
				END
			END
			
			ELSE IF (@TransactionID= 1 OR @TransactionID= 11 OR @TransactionID= 8 OR @TransactionID= 14)
			BEGIN
				 UPDATE RequestHeaders 
				 SET DocumentStatus = 'X',
				 --IsApproved =0,
				 LastModUserID = @UserProfileId
				 WHERE  Id IN (SELECT Id FROM #TempMulIDS) 
				 AND PropertyID = @CompanyId

				 SET @RowsAffected = @@ROWCOUNT;

				IF EXISTS(SELECT 1 FROM RequestHeaders WHERE  Id IN (SELECT Id FROM #TempMulIDS) 
				 AND PropertyID = @CompanyId)
				BEGIN

					WHILE EXISTS( SELECT 1 FROM #TempMulIDS)
					BEGIN
						SELECT TOP (1) @TransactionHeaderID = Id  FROM #TempMulIDS
						
						INSERT INTO [dbo].[CommonTransactionStatusLog]([CompanyID],[TransactionID] ,[TransactionHeaderID],[TransactionStatusID],[Status],[CreatedDate] ,[UserProfileID], [RejectedReason])
						VALUES(@CompanyId ,@TransactionID,@TransactionHeaderID ,@TransactionStatusID,'X',GETDATE() ,@UserProfileId, @RejectReason)

						DELETE TOP (1) FROM #TempMulIDS
					END
				
				END
			END

			--SET @RowsAffected = @@ROWCOUNT;
		END
	END
	ELSE IF (@TransactionStatusID = 1) -- Completion
	BEGIN
		IF (@TransactionHeaderID <> 0)
		BEGIN
			IF(@TransactionID =2)
			BEGIN
				UPDATE PoHeaders
				SET DocumentStatus ='C', --Complete
				--IsApproved =0,
				LastModUserID = @UserProfileId
				WHERE PropertyID =@CompanyId AND Id = @TransactionHeaderID

				SET @RowsAffected = @@ROWCOUNT;

				IF EXISTS(SELECT 1 FROM PoHeaders WHERE PropertyID =@CompanyId AND Id = @TransactionHeaderID)
				BEGIN
					INSERT INTO [dbo].[CommonTransactionStatusLog]([CompanyID],[TransactionID] ,[TransactionHeaderID],[TransactionStatusID],[Status],[CreatedDate] ,[UserProfileID])
					VALUES(@CompanyId ,@TransactionID,@TransactionHeaderID ,@TransactionStatusID,'C',GETDATE() ,@UserProfileId)
				END

			END
			ELSE IF (@TransactionID= 1 OR @TransactionID= 11 OR @TransactionID= 8 OR @TransactionID= 14)
			BEGIN
				 UPDATE RequestHeaders 
				 SET DocumentStatus = 'C',
				-- IsApproved =0,
				 LastModUserID = @UserProfileId
				 WHERE Id = @TransactionHeaderID 
				 AND PropertyID = @CompanyId

				 SET @RowsAffected = @@ROWCOUNT;

				IF EXISTS(SELECT 1 FROM RequestHeaders  WHERE Id = @TransactionHeaderID 
				 AND PropertyID = @CompanyId)
				BEGIN
					INSERT INTO [dbo].[CommonTransactionStatusLog]([CompanyID],[TransactionID] ,[TransactionHeaderID],[TransactionStatusID],[Status],[CreatedDate] ,[UserProfileID])
					VALUES(@CompanyId ,@TransactionID,@TransactionHeaderID ,@TransactionStatusID,'C',GETDATE() ,@UserProfileId)
				END
				

			END
			ELSE IF (@TransactionID = 78) -- ADDED Tharuka 2026-08-10 - Production Process Plan (PL), single record
			BEGIN
				UPDATE ProductionConsolidateHeader
				SET Status = 'C' 
				WHERE ID = @TransactionHeaderID
				AND PropertyID = CASE WHEN @CompanyId = -999 THEN PropertyID ELSE @CompanyId END
				AND ISNULL(IsTransferComplete,0) = 0

				SET @RowsAffected = @@ROWCOUNT;

				IF EXISTS(SELECT 1 FROM ProductionConsolidateHeader
						  WHERE ID = @TransactionHeaderID
						  AND PropertyID = CASE WHEN @CompanyId = -999 THEN PropertyID ELSE @CompanyId END)
				BEGIN
					INSERT INTO [dbo].[CommonTransactionStatusLog]([CompanyID],[TransactionID] ,[TransactionHeaderID],[TransactionStatusID],[Status],[CreatedDate] ,[UserProfileID])
					VALUES(@CompanyId ,@TransactionID,@TransactionHeaderID ,@TransactionStatusID,'C',GETDATE() ,@UserProfileId)
				END
			END

			--SET @RowsAffected = @@ROWCOUNT;
		END
		ELSE IF (@TransactionHeaderID =0)
		BEGIN
			INSERT INTO #TempMulIDS
			SELECT value AS Id
			FROM OPENJSON(@JsonMultiTransactionIDs);

			

			IF(@TransactionID =2)
			BEGIN
				UPDATE PoHeaders
				SET DocumentStatus ='C',
				--IsApproved =0,
				LastModUserID = @UserProfileId
				WHERE PropertyID =@CompanyId AND Id IN (SELECT Id FROM #TempMulIDS)

				SET @RowsAffected = @@ROWCOUNT;

				IF EXISTS(SELECT 1 FROM PoHeaders WHERE PropertyID =@CompanyId AND Id IN (SELECT Id FROM #TempMulIDS))
				BEGIN

					WHILE EXISTS( SELECT 1 FROM #TempMulIDS)
					BEGIN
						SELECT TOP (1) @TransactionHeaderID = Id  FROM #TempMulIDS
						
						INSERT INTO [dbo].[CommonTransactionStatusLog]([CompanyID],[TransactionID] ,[TransactionHeaderID],[TransactionStatusID],[Status],[CreatedDate] ,[UserProfileID])
						VALUES(@CompanyId ,@TransactionID,@TransactionHeaderID ,@TransactionStatusID,'C',GETDATE() ,@UserProfileId)

						DELETE TOP (1) FROM #TempMulIDS
					END
				
				END
			END
			ELSE IF (@TransactionID= 1 OR @TransactionID= 11 OR @TransactionID= 8 OR @TransactionID= 14)
			BEGIN
				 UPDATE RequestHeaders 
				 SET DocumentStatus = 'C',
				 --IsApproved =0,
				 LastModUserID = @UserProfileId
				 WHERE  Id IN (SELECT Id FROM #TempMulIDS) 
				 AND PropertyID = @CompanyId

				 SET @RowsAffected = @@ROWCOUNT;

				IF EXISTS(SELECT 1 FROM RequestHeaders WHERE  Id IN (SELECT Id FROM #TempMulIDS) 
				 AND PropertyID = @CompanyId)
				BEGIN

					WHILE EXISTS( SELECT 1 FROM #TempMulIDS)
					BEGIN
						SELECT TOP (1) @TransactionHeaderID = Id  FROM #TempMulIDS
						
						INSERT INTO [dbo].[CommonTransactionStatusLog]([CompanyID],[TransactionID] ,[TransactionHeaderID],[TransactionStatusID],[Status],[CreatedDate] ,[UserProfileID])
						VALUES(@CompanyId ,@TransactionID,@TransactionHeaderID ,@TransactionStatusID,'C',GETDATE() ,@UserProfileId)

						DELETE TOP (1) FROM #TempMulIDS
					END
				
				END
			END
			ELSE IF (@TransactionID = 78) -- ADDED 2026-08-10 - Production Process Plan (PL), multi select
			BEGIN
				/* ---------------------------------------------------------------------------------
				   Same close as the single record branch above, for the "Select All" / check box
				   path - the UI sends @TransactionHeaderID = 0 plus a JSON array of ids.
				   See the single record branch for why IsTransferComplete is the right flag.
				   --------------------------------------------------------------------------------- */
				UPDATE ProductionConsolidateHeader
				SET Status = 'C'
				WHERE ID IN (SELECT Id FROM #TempMulIDS)
				AND PropertyID = CASE WHEN @CompanyId = -999 THEN PropertyID ELSE @CompanyId END
				AND ISNULL(IsTransferComplete,0) = 0	-- a repeated click becomes a no-op instead of a silent double close

				SET @RowsAffected = @@ROWCOUNT;

				IF EXISTS(SELECT 1 FROM ProductionConsolidateHeader
						  WHERE ID IN (SELECT Id FROM #TempMulIDS)
						  AND PropertyID = CASE WHEN @CompanyId = -999 THEN PropertyID ELSE @CompanyId END)
				BEGIN
					WHILE EXISTS( SELECT 1 FROM #TempMulIDS)
					BEGIN
						SELECT TOP (1) @TransactionHeaderID = Id FROM #TempMulIDS

						INSERT INTO [dbo].[CommonTransactionStatusLog]([CompanyID],[TransactionID] ,[TransactionHeaderID],[TransactionStatusID],[Status],[CreatedDate] ,[UserProfileID])
						VALUES(@CompanyId ,@TransactionID,@TransactionHeaderID ,@TransactionStatusID,'C',GETDATE() ,@UserProfileId)

						DELETE TOP (1) FROM #TempMulIDS
					END
				END
			END

			--SET @RowsAffected = @@ROWCOUNT;
		END	
	END
	

		COMMIT TRANSACTION;
		
    END TRY
    BEGIN CATCH
        SET @ErrorMessage = ERROR_MESSAGE();
        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;

GO

