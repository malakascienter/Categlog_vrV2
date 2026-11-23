-- =============================================
-- Author:		Nivesh
-- Create date: 2025-03-30
-- Description:	Update approval transaction
-- =============================================
-- SP_Update_CommonTransactionApproval 1, 4168,5,3075,0

CREATE PROCEDURE [dbo].[SP_Update_CommonTransactionApproval] 
	@CompanyId INT ,
	@UserProfileId INT ,
	@TransactionID INT ,
	@TransactionHeaderID INT ,
	@RowsAffected INT OUTPUT 
AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT,@IsMailNotification BIT;

    BEGIN TRY
        -- Start transaction
        BEGIN TRANSACTION;
	
		IF(@TransactionID =76)
		BEGIN
			UPDATE ProcurementRequest
			SET IsApprove =1
			WHERE CompanyID =@CompanyId AND Id = @TransactionHeaderID AND UserProfileId = @UserProfileId

			SET @RowsAffected = @@ROWCOUNT;
		END


		IF(@TransactionID = 81)
		BEGIN
			
			UPDATE  ApprovalLogs 
			SET DocStatus='C',IsComplete=1,ApprovalDate = GETDATE()
			WHERE TransactionID = @TransactionID
			AND TransactionHeaderID = @TransactionHeaderID
			AND PropertyID = @CompanyId
			AND ApprovalUserID = @UserProfileId

			SET @RowsAffected = @@ROWCOUNT;

			select @RowsAffected
			IF NOT EXISTS(SELECT 1 FROM ApprovalLogs WHERE TransactionID = @TransactionID AND TransactionHeaderID = @TransactionHeaderID AND PropertyID = @CompanyId
			AND IsComplete = 0)
			BEGIN
				UPDATE TourGuideCompanies
				SET IsApproved = 1
				WHERE ID = @TransactionHeaderID;
			END

		END

		IF(@TransactionID = 82)
		BEGIN
		
			SELECT @IsMailNotification =  ISNULL(IsMailNotification,0)
			FROM TransactionTypes
			WHERE ID= @TransactionID

			UPDATE  ApprovalLogs 
			SET DocStatus='C',IsComplete=1,ApprovalDate = GETDATE()
			WHERE TransactionID = @TransactionID
			AND TransactionHeaderID = @TransactionHeaderID
			AND PropertyID = @CompanyId
			AND ApprovalUserID = @UserProfileId

			SET @RowsAffected = @@ROWCOUNT;
			select @RowsAffected

			IF NOT EXISTS(SELECT 1 FROM ApprovalLogs WHERE TransactionID = @TransactionID AND TransactionHeaderID = @TransactionHeaderID AND PropertyID = @CompanyId
			AND IsComplete = 0)
			BEGIN
				UPDATE TourGuideMaster
				SET IsApproved = 1
				WHERE ID = @TransactionHeaderID;
			END
			ELSE
			BEGIN
				IF(@IsMailNotification = 1)
				BEGIN
					DECLARE @Email VARCHAR(MAX),@EmailBody VARCHAR(MAX), @CompanyName VARCHAR(200)
					, @LocationName VARCHAR(200), @RequestedUser VARCHAR(200),@DocumentNo VARCHAR(25)
					, @EmailLocationID INT,@TransactionName VARCHAR(MAX),@RequestType CHAR(2)
					,@TourGuideName NVARCHAR(MAX),@TourGuideCode nvarchar(30),@TourGuideContactNo nvarchar(30)

					SET @TransactionName = 'Tour Guide Approval'

					SELECT @RequestedUser = CU.UserName ,@CompanyName = C.Name,@TourGuideName = TG.Description
					,@TourGuideCode = TG.Code,@TourGuideContactNo = ISNULL(ContactNo,'0')
					FROM TourGuideMaster TG
					INNER JOIN CentralUsers CU ON TG.CreatedUserId = CU.Id
					INNER JOIN Companies C ON C.CompanyID =TG.PropertyID
					WHERE TG.Id = @TransactionHeaderID

					DECLARE @SeqID INT

					SELECT TOP(1)@SeqID= AL.SeqID
					FROM ApprovalLogs AL
					WHERE AL.TransactionID= @TransactionID AND AL.TransactionHeaderID= @TransactionHeaderID AND AL.SendMail = 0 AND AL.DocStatus = 'P' 
					ORDER BY AL.SeqID ASC;


					SELECT DISTINCT US.Email,AL.ApprovalUserID
					into #TempEmail
					FROM ApprovalLogs AS AL
					INNER JOIN dbo.UserWiseApproveLevels AS UAL
					ON AL.TransactionID = UAL.TransactionTypeID
					AND AL.LocationID = UAL.LocationId
					AND AL.PropertyID = UAL.PropertyId
					AND AL.ApprovalLevelID = UAL.ApproveLevelID
					INNER JOIN CentralUsers AS US ON US.Id = AL.ApprovalUserID
					WHERE AL.TransactionID = @TransactionID AND AL.SendMail = 0  
					AND AL.TransactionHeaderID=@TransactionHeaderID AND AL.SeqID=@SeqID AND AL.DocStatus = 'P' 

					SET @EmailBody = '<html><body><p>You have to respond a pending tourguide approval</p>
						  <table border = 1>
						  <thead>
							  <th  style="width: 20%" >Approval type</th>
							  <th  style="width: 20%" >Tour Guide Code</th>
							  <th  style="width: 20%" >Tour Guide Name</th>
							  <th  style="width: 20%" >Tour Guide Contact No</th>
							  <th  style="width: 20%" >Company Name</th>
							  <th  style="width: 20%" >Requested User</th>
						  </thead>
						  <tbody >
							<tr>
							 <td  style="width: 20%" >'+@TransactionName+'</td>
							 <td  style="width: 20%" >'+@TourGuideCode+'</td>
							 <td  style="width: 20%" >'+@TourGuideName+'</td>
							 <td  style="width: 20%" >'+@TourGuideContactNo+'</td>
							 <td  style="width: 20%" >'+@CompanyName+'</td>
							 <td  style="width: 20%" >'+@RequestedUser+'</td>
							</tr>
						  </tbody>
						  </table></html></body>'
					IF EXISTS(SELECT 1 FROM #TempEmail)
					BEGIN
					DECLARE @NewEmail VARCHAR(MAX),@NewApprovalUserID INT,@MailSubject VARCHAR(MAX)

					SELECT @MailSubject = @TransactionName 

					WHILE EXISTS(SELECT 1  FROM #TempEmail)
					BEGIN
						SELECT TOP(1) @NewEmail= EMAIL,@NewApprovalUserID =ApprovalUserID  FROM #TempEmail

						EXEC [dbo].[SendReuestMail] @NewEmail, @MailSubject, @EmailBody, 2

						;WITH CTE AS (
						SELECT TOP 1 AL.SeqID
						FROM ApprovalLogs AS AL
						INNER JOIN dbo.UserWiseApproveLevels AS UAL ON AL.TransactionID = UAL.TransactionTypeID AND AL.LocationID = UAL.LocationId 
						AND AL.PropertyID = UAL.PropertyId AND AL.ApprovalLevelID = UAL.ApproveLevelID AND AL.TransactionHeaderID = @TransactionHeaderID
						INNER JOIN CentralUsers AS US ON US.Id = AL.ApprovalUserID
						WHERE AL.TransactionID = @TransactionID 
						AND AL.DocStatus = 'P'
						AND AL.SeqID=@SeqID
						AND AL.ApprovalUserID=@NewApprovalUserID
						ORDER BY AL.SeqID ASC
						)

						UPDATE AL
						SET AL.SendMail = 1
						FROM ApprovalLogs AS AL
						INNER JOIN CTE ON AL.SeqID = CTE.SeqID
						WHERE AL.TransactionHeaderID = @TransactionHeaderID;

						DELETE TOP(1) FROM #TempEmail
					END
						DROP TABLE #TempEmail

				


				END
			END


			END


		END

		--added by isuru 2026-10-28
		--Reason: Supplier Grading (SGR) approval - complete this user's level; when no level is
		--        open any more the submit is approved (IsApproved = 1, DocumentStatus = 'C')
		IF(@TransactionID = (SELECT TOP (1) Id FROM dbo.TransactionTypes WHERE Code = 'SGR'))
		BEGIN

			--changed by isuru 2026-10-28: any one user of the level approves it for all users of that level
			UPDATE ApprovalLogs
			SET DocStatus = 'C', IsComplete = 1, ApprovalDate = GETDATE(),
				LastModUserID = @UserProfileId, LastModDate = GETDATE()
			WHERE TransactionID = @TransactionID
			AND TransactionHeaderID = @TransactionHeaderID
			AND PropertyID = @CompanyId
			AND IsComplete = 0
			AND SeqID IN (SELECT AL.SeqID FROM ApprovalLogs AL
						  WHERE AL.TransactionID = @TransactionID
							AND AL.TransactionHeaderID = @TransactionHeaderID
							AND AL.PropertyID = @CompanyId
							AND AL.ApprovalUserID = @UserProfileId
							AND AL.IsComplete = 0)

			SET @RowsAffected = @@ROWCOUNT;

			IF NOT EXISTS(SELECT 1 FROM ApprovalLogs WHERE TransactionID = @TransactionID AND TransactionHeaderID = @TransactionHeaderID
			AND PropertyID = @CompanyId AND IsComplete = 0)
			BEGIN
				UPDATE SupplierEvaluationHeader
				SET IsApproved = 1,
					DocumentStatus = CASE WHEN SupplierGrade = 'X' THEN 'P' ELSE 'C' END --changed by isuru 2026-10-29: grade X stays 'P' for the blacklist approval
				WHERE ID = @TransactionHeaderID;
			END

		END
		--End

		IF (@TransactionID = 5)
		BEGIN

			DECLARE @GRNXML VARCHAR(MAX),@NEWGRNXML XML,@ApprovalDocNo VARCHAR(MAX),@SeqID5 INT,@TempRowCount INT,@TempRowCount2 INT
			,@documentNumber VARCHAR(MAX),@headerOut INT,@BulkDocNoJson VARCHAR(MAX)
			

			DECLARE @HeaderOutID INT,@DocNo VARCHAR(MAX)

			SELECT ApprovalDocNo, GA.SeqID
			FROM GRNApprovalLog GA
			INNER JOIN TransactionTypes TR ON TR.Code = GA.TransactionType
			WHERE GA.ID = @TransactionHeaderID
			AND GA.CompanyId = @CompanyId
			AND UserProfileId = @UserProfileId
			AND TR.ID = @TransactionID

			SELECT @ApprovalDocNo = ApprovalDocNo,@SeqID5 = GA.SeqID,@GRNXML =XMLDetails
			FROM GRNApprovalLog GA
			INNER JOIN TransactionTypes TR ON TR.Code = GA.TransactionType
			WHERE GA.ID = @TransactionHeaderID
			AND GA.CompanyId = @CompanyId
			AND UserProfileId = @UserProfileId
			AND TR.ID = @TransactionID

			UPDATE GA
			SET GA.Status = 'C', GA.IsComplete = 1, GA.ApprovedUserId = @UserProfileId, ApprovedDateTime = GETDATE()
			FROM GRNApprovalLog GA
			INNER JOIN TransactionTypes TR ON TR.Code = GA.TransactionType
			WHERE GA.ID = @TransactionHeaderID
			AND GA.CompanyId = @CompanyId
			AND UserProfileId = @UserProfileId
			AND TR.ID = @TransactionID

			SET @RowsAffected = @@ROWCOUNT;

			select @RowsAffected

			--FINDING SAME SEQ APPROVALS
			IF EXISTS(SELECT 1 FROM GRNApprovalLog WHERE ApprovalDocNo = @ApprovalDocNo AND SeqID = @SeqID5 AND CompanyId = @CompanyId AND Status = 'P')
			BEGIN
				UPDATE GRNApprovalLog
				SET Status = 'C' ,ApprovedUserId = @UserProfileId,ApprovedDateTime = GETDATE(),IsComplete = 1
				WHERE ApprovalDocNo = @ApprovalDocNo and SeqID = @SeqID5
				AND  CompanyId = @CompanyId and Status = 'P'
			END

			SELECT @TempRowCount = COUNT(ID) FROM GRNApprovalLog WHERE ApprovalDocNo = @ApprovalDocNo AND CompanyId = @CompanyId
	
			SELECT @TempRowCount2= COUNT(ID) FROM GRNApprovalLog WHERE ApprovalDocNo = @ApprovalDocNo AND Status ='C' AND CompanyId = @CompanyId

			IF(@TempRowCount=@TempRowCount2)
			BEGIN

				SET @NEWGRNXML = CONVERT(XML,@GRNXML)

				SELECT @NEWGRNXML NEWGRNXML

				EXEC SP_InsertStockTransactions @NEWGRNXML,@documentNumber OUTPUT,0,'',@headerOut OUTPUT,1, 0,@BulkDocNoJson OUTPUT

				SET @HeaderOutID = @headerOut;
                SET @DocNo = @documentNumber;

				UPDATE GRNApprovalLog
				SET StockTransactionHeaderID = @HeaderOutID
				WHERE ApprovalDocNo = @ApprovalDocNo 
				AND CompanyId = @CompanyId


				SELECT @HeaderOutID HeaderOutID,@DocNo DocNo

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

