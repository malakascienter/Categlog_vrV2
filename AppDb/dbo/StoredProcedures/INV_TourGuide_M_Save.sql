-- [dbo].[INV_TourGuide_M_Save]  6,'0012','6556','111','0786157468','MAIL.COM',1,'U',4168,1,9,50,'I'

CREATE PROCEDURE [dbo].[INV_TourGuide_M_Save]  
    @Id   BIGINT,  
	@Code   VARCHAR(20),  
	@Description VARCHAR(25), 
	@NIC VARCHAR(25),
	@ContactNo  VARCHAR(15),  
	@Email VARCHAR(50),
	@IsActive BIT,  
	@Operation CHAR(1),  
	@UserId    INT,  
	@PropertyId INT,
	@TourGuideCompaniesId INT,
	@CommissionPercentage MONEY,
	@Module VARCHAR(2),
	@TourGuideLicense NVARCHAR(MAX),
	@Address NVARCHAR(MAX),
	@BankName NVARCHAR(MAX),
	@Branch NVARCHAR(MAX),
	@BankAccount NVARCHAR(MAX),
	@TourGuideTypeID INT
AS  
BEGIN TRY
	SET NOCOUNT ON;
	DECLARE @Remark NVARCHAR(250);
	DECLARE @NextCatgId INT, 
	@RequestHeaderID INT,@IsApproved BIT,@IsMailNotification BIT;

	BEGIN TRANSACTION;

	SELECT @IsMailNotification =  ISNULL(IsMailNotification,0)
	FROM TransactionTypes
	WHERE CODE = 'TG'

	IF(@UserId = 0 OR @UserId IS NULL)
	BEGIN
		RAISERROR('User ID Invalid, Please Log In Again',16,1)
		ROLLBACK TRANSACTION
	END

	IF @Operation = 'I'  
	BEGIN 
		IF EXISTS (SELECT 1 FROM TourGuideMaster WHERE PropertyId = @PropertyId AND IsDelete = 0 AND Module = @Module AND (Code = @Code OR Description = @Description))         
		BEGIN  
			RAISERROR('Tour Guide Code OR Description already exists', 16, 1);  
			ROLLBACK TRANSACTION;
			RETURN;
		END  

		IF EXISTS(SELECT 1 FROM TransactionWiseApprovalTypes WHERE TransactionID = 82 AND PropertyID = @PropertyId)
		BEGIN
			SET @IsApproved = 0
		END
		ELSE
		BEGIN
			SET @IsApproved = 1
		END
		
		INSERT INTO TourGuideMaster (
			TourGuideCompaniesId, Code, Description, NIC, ContactNo, Email, 
			IsActive, PropertyId, IsUpload, CreatedUserId, CreatedDateTime,LastModifiedUserID,LastModifiedDateTime,
			CommissionPercentage, Module,
			TourGuideLicense,Address,BankName,Branch,BankAccount,TourGuideTypeID,IsApproved
		)
		VALUES (
			@TourGuideCompaniesId, @Code, @Description, @NIC, @ContactNo, @Email,
			@IsActive, @PropertyId, 0, @UserId, GETDATE(),@UserId, GETDATE(),
			@CommissionPercentage, @Module
			,@TourGuideLicense,@Address,@BankName,@Branch,@BankAccount,@TourGuideTypeID,@IsApproved
		);

		--Added by Isuru 2025-09-29 to call approval

		SELECT  @RequestHeaderID = SCOPE_IDENTITY();
		EXEC SP_InsertApprovalLevelForRequest @PropertyId,-999,82,@RequestHeaderID
		--End

		SELECT @IsApproved IsApproved,@IsMailNotification IsMailNotification

		--Added by Isuru 2025-11-10 for sending Email notifications to approve user
		IF(@IsMailNotification = 1 AND @IsApproved =0)
		BEGIN

		DECLARE @Email2 VARCHAR(MAX),@EmailBody VARCHAR(MAX), 
		@CompanyName VARCHAR(200), @LocationName VARCHAR(200), 
		@RequestedUser VARCHAR(200),@TransactionName VARCHAR(MAX),@TourGuideName NVARCHAR(MAX),@TourGuideCode nvarchar(30),@TourGuideContactNo nvarchar(30)


		SET @TransactionName = 'Tour Guide Approval'

		select @RequestHeaderID RequestHeaderID

		SELECT @RequestedUser = CU.UserName ,@CompanyName = C.Name,@TourGuideName = TG.Description
		,@TourGuideCode = TG.Code,@TourGuideContactNo = ISNULL(ContactNo,'0')
		FROM TourGuideMaster TG
		INNER JOIN CentralUsers CU ON TG.CreatedUserId = CU.Id
		INNER JOIN Companies C ON C.CompanyID =TG.PropertyID
		WHERE TG.Id = @RequestHeaderID


		SELECT DISTINCT US.Email,AL.ApprovalUserID
		INTO #TempEmail
		FROM ApprovalLogs AS AL
		INNER JOIN dbo.UserWiseApproveLevels AS UAL
		ON AL.TransactionID = UAL.TransactionTypeID
		AND AL.LocationID = UAL.LocationId
		AND AL.PropertyID = UAL.PropertyId
		AND AL.ApprovalLevelID = UAL.ApproveLevelID
		INNER JOIN CentralUsers AS US ON US.Id = AL.ApprovalUserID
		INNER JOIN TransactionTypes TR ON AL.TransactionID = TR.Id
		WHERE TR.Code = 'TG' AND AL.SendMail = 0  
		AND AL.TransactionHeaderID=@RequestHeaderID AND AL.SeqID=1


		select @TransactionName TransactionName,@TourGuideCode TourGuideCode,@TourGuideName TourGuideName,@TourGuideContactNo TourGuideContactNo
		,@CompanyName CompanyName,@RequestedUser RequestedUser

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

					  select @EmailBody EmailBody

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
			AND AL.PropertyID = UAL.PropertyId AND AL.ApprovalLevelID = UAL.ApproveLevelID AND AL.TransactionHeaderID = @RequestHeaderID
			INNER JOIN CentralUsers AS US ON US.Id = AL.ApprovalUserID
			INNER JOIN TransactionTypes TR ON TR.Id = AL.TransactionID
			WHERE TR.Code = 'TG'
				AND AL.DocStatus = 'P'
				AND AL.SeqID=1
				AND AL.ApprovalUserID=@NewApprovalUserID
			ORDER BY AL.SeqID ASC
			)
			UPDATE AL
			SET AL.SendMail = 1
			FROM ApprovalLogs AS AL
			INNER JOIN CTE ON AL.SeqID = CTE.SeqID
			WHERE AL.TransactionHeaderID = @RequestHeaderID;

			

		
		DELETE TOP(1) FROM #TempEmail
		END
		DROP TABLE #TempEmail
		
	END
	

		END

		--ENd

	END    

	ELSE IF @Operation = 'U'  
	BEGIN  
		IF EXISTS (SELECT 1 FROM TourGuideMaster WHERE PropertyId = @PropertyId AND IsDelete = 0 AND ID <> @Id AND Module = @Module AND  Description = @Description)         
		BEGIN  
			RAISERROR('Tour Guide Code OR Description already exists', 16, 1);  
			ROLLBACK TRANSACTION;
			RETURN;
		END 
		SELECT *
		FROM TourGuideMaster
		WHERE Id = @Id AND PropertyId = @PropertyId;

		UPDATE TourGuideMaster  
		SET    
			Description = @Description,  
			TourGuideCompaniesId = @TourGuideCompaniesId,
			NIC = @NIC,
			ContactNo = @ContactNo,  
			Email = @Email,
			IsActive = @IsActive,
			PropertyId = @PropertyId,
			LastModifiedUserID = @UserId,
			LastModifiedDateTime = GETDATE(),
			IsUpload = 0,
			CommissionPercentage = @CommissionPercentage,
			TourGuideLicense = @TourGuideLicense,
			Address = @Address,
			BankName = @BankName,
			Branch =@Branch,
			BankAccount = @BankAccount,
			TourGuideTypeID = @TourGuideTypeID
		WHERE Id = @Id AND PropertyId = @PropertyId;
	END 

	ELSE IF @Operation = 'D'  
	BEGIN  
		UPDATE TourGuideMaster  
		SET IsDelete = 1,LastModifiedUserID =@UserId,LastModifiedDateTime = getdate(),IsActive = 0
		WHERE Id = @Id AND PropertyId = @PropertyId ;

	END 

	COMMIT TRANSACTION;
END TRY 

BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

	INSERT INTO GEN_ErrTable (
		ErrorNumber, ErrorSeverity, ErrorState, 
		ErrorProcedure, ErrorLine, ErrorMessage
	)
	VALUES (
		ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), 
		ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE()
	);

	DECLARE @ERRmsg VARCHAR(MAX) = ERROR_MESSAGE();
	RAISERROR(@ERRmsg, 16, 1);
END CATCH;

GO

