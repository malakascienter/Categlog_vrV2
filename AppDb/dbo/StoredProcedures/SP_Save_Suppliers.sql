
CREATE PROCEDURE [dbo].[SP_Save_Suppliers]
 --DECLARE PARAMETERS

--2026-10-28-- commented: supplier details now come in @SupplierXML
--	@ID int,
--	@PropertyID int,
--	@Code nvarchar(10),
--	@Name nvarchar(100),
--	@Address1 nvarchar(100),
--	@BillingAddress nvarchar(100),
--	@Email nvarchar(255),
--	@Telephone1 nvarchar(15),
--	@Telephone2 nvarchar(15),
--	@FaxNo nvarchar(15),
--	@ContactPerson nvarchar(50),
--	@CountryID int,
--	@Remarks nvarchar(max),
--	@CreditLimit decimal(18, 2),
--	@CreditPeriod real,
--	@PaymentTermID int,
--	@CurrencyID int,
--	@NameOnCheque nvarchar(max),
--	@SupplierGradingID int,
--	@IsDefaultSupplier bit,
--	@IsActive bit,
--	@IsLabor bit,
--	@IPAddress nvarchar(max),
--	@CreatedUserID int,
--	@LastModUserID int,
--	@CreatedDate datetime,
--	@LastModDate datetime,
--	@Action[INT],
--	@TempSupplierId int,
--	@status[int] output,
--	@NewId[int] output,
--	@VatNo varchar(100),
--	@DefaultPayType INT,
--	@BankCode VARCHAR(5),
--	@BranchCode VARCHAR(5),
--	@CommAcc VARCHAR(12),
--	@AccountNo VARCHAR(20),
--	@PaymentGracePeriod MONEY,
--	@DeductionCon BIT,
--	@CreditorTypeID int,
--	@IsConsigments BIT,
--	@IsPettyCash BIT,
--	@SupplierCategoryID INT,
--	@Email2 nvarchar(255),
--	@message NVARCHAR(max) OUTPUT
--2026-10-28-- start
	@SupplierXML XML,
	@Action[INT],
	@status[int] output,
	@NewId[int] output,
	@message NVARCHAR(max) OUTPUT
--2026-10-28-- end
AS
	--2026-10-02-- start: any error or client timeout rolls back the whole transaction
	SET XACT_ABORT ON;
	--2026-10-02-- end

	--2026-10-28-- start: read the supplier details from @SupplierXML.
	IF @SupplierXML IS NULL OR @SupplierXML.exist('/Suppliers') = 0
	BEGIN
		RAISERROR('Supplier details were not received. Please try again.', 16, 1)
		RETURN
	END

	DECLARE
		@ID int,
		@PropertyID int,
		@Code nvarchar(10),
		@Name nvarchar(100),
		@Address1 nvarchar(100),
		@BillingAddress nvarchar(100),
		@Email nvarchar(255),
		@Telephone1 nvarchar(15),
		@Telephone2 nvarchar(15),
		@FaxNo nvarchar(15),
		@ContactPerson nvarchar(50),
		@CountryID int,
		@Remarks nvarchar(max),
		@CreditLimit decimal(18, 2),
		@CreditPeriod real,
		@PaymentTermID int,
		@CurrencyID int,
		@NameOnCheque nvarchar(max),
		@SupplierGradingID int,
		@IsDefaultSupplier bit,
		@IsActive bit,
		@IsLabor bit,
		@IPAddress nvarchar(max),
		@CreatedUserID int,
		@LastModUserID int,
		@CreatedDate datetime,
		@LastModDate datetime,
		@TempSupplierId int,
		@VatNo varchar(100),
		@DefaultPayType INT,
		@BankCode VARCHAR(5),
		@BranchCode VARCHAR(5),
		@CommAcc VARCHAR(12),
		@AccountNo VARCHAR(20),
		@PaymentGracePeriod MONEY,
		@DeductionCon BIT,
		@CreditorTypeID int,
		@IsConsigments BIT,
		@IsPettyCash BIT,
		@SupplierCategoryID INT,
		@Email2 nvarchar(255)

	SELECT
		@ID = S.value('(ID/text())[1]', 'int'),
		@PropertyID = S.value('(PropertyID/text())[1]', 'int'),
		@Code = S.value('(Code)[1]', 'nvarchar(10)'),
		@Name = S.value('(Name)[1]', 'nvarchar(100)'),
		@Address1 = S.value('(Address1)[1]', 'nvarchar(100)'),
		@BillingAddress = S.value('(BillingAddress)[1]', 'nvarchar(100)'),
		@Email = S.value('(Email)[1]', 'nvarchar(255)'),
		@Telephone1 = S.value('(Telephone1)[1]', 'nvarchar(15)'),
		@Telephone2 = S.value('(Telephone2)[1]', 'nvarchar(15)'),
		@FaxNo = S.value('(FaxNo)[1]', 'nvarchar(15)'),
		@ContactPerson = S.value('(ContactPerson)[1]', 'nvarchar(50)'),
		@CountryID = S.value('(CountryID/text())[1]', 'int'),
		@Remarks = S.value('(Remarks)[1]', 'nvarchar(max)'),
		@CreditLimit = S.value('(CreditLimit/text())[1]', 'decimal(18, 2)'),
		@CreditPeriod = S.value('(CreditPeriod/text())[1]', 'real'),
		@PaymentTermID = S.value('(PaymentTermID/text())[1]', 'int'),
		@CurrencyID = S.value('(CurrencyID/text())[1]', 'int'),
		@NameOnCheque = S.value('(NameOnCheque)[1]', 'nvarchar(max)'),
		@SupplierGradingID = S.value('(SupplierGradingID/text())[1]', 'int'),
		@IsDefaultSupplier = S.value('(IsDefaultSupplier/text())[1]', 'bit'),
		@IsActive = S.value('(IsActive/text())[1]', 'bit'),
		@IsLabor = S.value('(IsLabor/text())[1]', 'bit'),
		@IPAddress = S.value('(IPAddress)[1]', 'nvarchar(max)'),
		@CreatedUserID = S.value('(CreatedUserID/text())[1]', 'int'),
		@LastModUserID = S.value('(LastModUserID/text())[1]', 'int'),
		-- via datetimeoffset: keeps the clock time the API sent (Z or +05:30), as the datetime parameter did
		@CreatedDate = CONVERT(datetime, S.value('(CreatedDate/text())[1]', 'datetimeoffset')),
		@LastModDate = CONVERT(datetime, S.value('(LastModDate/text())[1]', 'datetimeoffset')),
		@TempSupplierId = S.value('(TempSupplierId/text())[1]', 'int'),
		@VatNo = S.value('(VatNo)[1]', 'varchar(100)'),
		@DefaultPayType = S.value('(DefaultPaymentType/text())[1]', 'int'),	-- element DefaultPaymentType
		@BankCode = S.value('(BankCode)[1]', 'varchar(5)'),
		@BranchCode = S.value('(BranchCode)[1]', 'varchar(5)'),
		@CommAcc = S.value('(CommissionAcc)[1]', 'varchar(12)'),				-- element CommissionAcc
		@AccountNo = S.value('(AccountNo)[1]', 'varchar(20)'),
		@PaymentGracePeriod = CONVERT(money, S.value('(GracePeriod/text())[1]', 'float')),	-- element GracePeriod (a float in the API)
		@DeductionCon = S.value('(DeductionControl/text())[1]', 'bit'),			-- element DeductionControl
		@CreditorTypeID = S.value('(CreditorTypeID/text())[1]', 'int'),
		@IsConsigments = S.value('(IsConsigments/text())[1]', 'bit'),
		@IsPettyCash = S.value('(IsPettyCash/text())[1]', 'bit'),
		@SupplierCategoryID = S.value('(SupplierCategoryID/text())[1]', 'int'),
		@Email2 = S.value('(Email2)[1]', 'nvarchar(255)')
	FROM @SupplierXML.nodes('/Suppliers') AS X(S)
	--2026-10-28-- end

	DECLARE @statusIN[int]
	SET @statusIN = 0;
	SET  @NewId =0
	SET  @message = ''
BEGIN
BEGIN TRY

	IF(@CreditorTypeID =0)
	BEGIN

	SET @CreditorTypeID=2
	END

	insert into tempSupp values(@ID ,
	@PropertyID ,
	@Code ,
	@Name ,
	@Address1 ,
	@BillingAddress ,
	@Email ,
	@Telephone1 ,
	@Telephone2,
	@FaxNo ,
	@ContactPerson ,
	@CountryID ,
	@Remarks ,
	@CreditLimit,
	@CreditPeriod ,
	@PaymentTermID ,
	@CurrencyID ,
	@NameOnCheque,
	@SupplierGradingID ,
	@IsDefaultSupplier ,
	@IsActive ,
	@IsLabor ,
	@IPAddress ,
	@CreatedUserID ,
	@LastModUserID ,
	@CreatedDate ,
	@LastModDate ,
	@Action,
	@TempSupplierId ,
	@VatNo,
	@AccountNo,
	@PaymentGracePeriod,
	@DefaultPayType,
	@BankCode,
	@BranchCode,
	@CommAcc,
	@DeductionCon,
	@CreditorTypeID,
	@IsConsigments,
	@IsPettyCash
	)

	--2026-10-02-- start: validations moved here, before BEGIN TRANSACTION
	-- (inside TRY, RAISERROR jumps straight to CATCH, so the ROLLBACK after it never ran)
	IF (@Telephone1 LIKE '%[^0-9]%')
	BEGIN
		RAISERROR('Special Characters not allowed', 16, 1)
	END

	IF (@Action = 1 AND @CreatedUserID = 0)
	BEGIN
		RAISERROR('User ID Invalid, Please Log In Again',16,1)
	END
	--2026-10-02-- end

	BEGIN TRANSACTION
	DECLARE @bspCode VARCHAR(50)

	IF(@Telephone2 = '' OR @Telephone2 IS NULL )
		SET @Telephone2 = '-'
	IF(@FaxNo = '' OR @Telephone2 IS NULL )
		SET @FaxNo = '-'
	IF(@AccountNo IS NULL )
		SET @AccountNo = 0
	IF(@PaymentGracePeriod IS NULL  )
		SET @PaymentGracePeriod = 0
	IF(@DefaultPayType IS NULL )
		SET @DefaultPayType = 0
	IF(@BankCode IS NULL )
		SET @BankCode = 0
	IF(@BranchCode IS NULL )
		SET @BranchCode = 0
	IF(@CommAcc IS NULL )
		SET @CommAcc = 0


		--added by Isuru 2026-05-07 to validate - inserting into Telephone line 1
	--2026-10-02-- commented: moved before BEGIN TRANSACTION
	--IF (@Telephone1 LIKE '%[^0-9]%')
	--BEGIN
	--	RAISERROR('Special Characters not allowed', 16, 1)
	--	ROLLBACK TRANSACTION
	--END
	--end

	--SELECT @Action 'SSS'
	--2026-10-02-- commented: PRINT text is appended to the error message sent to the screen
	--PRINT @Action
IF @Action =1
	BEGIN
	 UPDATE SuppliersRequest SET IsApprove = 1 WHERE Id = @TempSupplierId  

	 



		IF EXISTS(SELECT* FROM Suppliers WHERE  [Code] = @Code  )
		BEGIN

		
		--- ADDED BY ISURU 2023-08-07
		DECLARE @LeasingCode VARCHAR(MAX),@DefaultPayTypeOld INT

		SELECT @LeasingCode = BSPCode,@DefaultPayTypeOld = DefaultPaymentType
		FROM Suppliers 
		WHERE  [Code] = @Code 

		--END

		IF(@DefaultPayType = 0 OR @DefaultPayType IS NULL) --by Isuru 2025-11-10 to prevent paymenttype null insert issue
		BEGIN
		SET @DefaultPayType = @DefaultPayTypeOld
		END

		--ADDED BY ISURU 2023-08-23
		DECLARE @IsGLSupplierUpdate BIT

		SELECT TOP(1) @IsGLSupplierUpdate = IsGLSupplierUpdate
		FROM Companies
		--END





		EXEC InsertMasterFileChangeLog 'Suppliers',@CreatedUserID,'U',@Name

		select 'update sup code',@Code
		select 'inv @bspCode',@bspCode

		IF(@IsGLSupplierUpdate =1)
		BEGIN
		EXEC [dbo].[CreateBusinessPartnerWithoutNICNo]
			@Code OUTPUT
			,'C'
			,@Name
			,@Telephone1
			,@Telephone2
			,'-'
			,@Email
			,''
			,''
			,@FaxNo
			,@Address1
			,'-'
			,'-'
			,'B490B26A-2886-4671-8253-A8644C76660F' 
			,'LKR'
			,'U'
			,@LeasingCode--,@Code
			,''
			,''
			,@CreditPeriod
			--,2
			,@CreditorTypeID
			,0
			,@CreditLimit
			,@NameOnCheque
			,@VatNo
			,@CommAcc
			,@DefaultPayType
			,@BankCode
			,@BranchCode
			,@AccountNo	
			,@PaymentGracePeriod
			,@DeductionCon
			,@IsActive

		END

		--adding into log talbe before inserting
			SELECT *
			INTO #BeforeTempSUppliers
			FROM Suppliers
			WHERE [ID] = @ID

			select '@ID',@ID

			INSERT INTO Suppliers_Log
                         (SupplierID, PropertyID, Code, Name, Address1, BillingAddress, Email, Telephone1, Telephone2, FaxNo, ContactPerson, CountryID, Remarks, CreditLimit, CreditPeriod, PaymentTermID, CurrencyID, NameOnCheque, SupplierGradingID, 
                         IsDefaultSupplier, IsActive, IPAddress, CreatedUserID, LastModUserID, CreatedDate, LastModDate, IsLabor, IsForeign, VatNo, BSPCODE, AccountNo, Graceperiod, DefaultPaymenttype, Bankcode, BranchCode, CommissionAcc, 
                         DeductionControl, CreditorTypeID,Versions,IsConsigments)
			SELECT        ID, PropertyID, Code, Name, Address1, BillingAddress, Email, Telephone1, Telephone2, FaxNo, ContactPerson, CountryID, Remarks, CreditLimit, CreditPeriod, PaymentTermID, CurrencyID, NameOnCheque, 
                         SupplierGradingID, IsDefaultSupplier, IsActive, IPAddress, CreatedUserID, LastModUserID, CreatedDate, LastModDate, IsLabor, IsForeign, VatNo, BSPCODE, AccountNo, Graceperiod, DefaultPaymenttype, Bankcode, 
                         BranchCode, CommissionAcc, DeductionControl, CreditorTypeID,'Before',IsConsigments
			FROM            #BeforeTempSUppliers
			WHERE        [ID] = @ID

	--end

		--2026-10-02-- commented: PRINT text is appended to the error message sent to the screen
		--PRINT 'update'

		SET @PropertyID =0
		 --UPDATE THE RECORD
		UPDATE Suppliers SET
		[PropertyID] = @PropertyID,
		[Code] = @Code,
		[Name] = UPPER(@Name),
		[Address1] =  UPPER(@Address1),
		[BillingAddress] =  UPPER(@BillingAddress),
		[Email] =  UPPER(@Email),
		[Telephone1] = @Telephone1,
		[Telephone2] = @Telephone2,
		[FaxNo] = @FaxNo,
		[ContactPerson] =  UPPER(@ContactPerson),
		[CountryID] = @CountryID,
		[Remarks] =  UPPER(@Remarks),
		[CreditLimit] = @CreditLimit,
		[CreditPeriod] = @CreditPeriod,
		[PaymentTermID] = @PaymentTermID,
		[CurrencyID] = @CurrencyID,
		[NameOnCheque] = UPPER(@NameOnCheque),
		[SupplierGradingID] = @SupplierGradingID,
		[IsDefaultSupplier] = @IsDefaultSupplier,
		[IsActive] = @IsActive,
		[IsLabor] = @IsLabor,
		[IPAddress] = @IPAddress,
		[LastModUserID] = @LastModUserID,
		[LastModDate] = @LastModDate,
		VatNo= @VatNo,
		CommissionAcc =  @CommAcc,
		DefaultPaymentType = CASE WHEN @DefaultPayType = 0 OR @DefaultPayType IS NULL THEN DefaultPaymentType ELSE @DefaultPayType END,
		--DefaultPaymentType = @DefaultPayType, -- Commented by Isuru 2025-11-10 to prevent paymenttype null insert issue
		BankCode = @BankCode,
		BranchCode = @BranchCode,
		AccountNo = @AccountNo,	
		GracePeriod = @PaymentGracePeriod,
		DeductionControl = @DeductionCon,
		CreditorTypeID = @CreditorTypeID,
		IsConsigments = @IsConsigments,
		IsPettyCash =@IsPettyCash,
		SupplierCategoryID = @SupplierCategoryID,
		[Email2] =  UPPER(@Email2)
		WHERE [ID] = @ID
		SET @statusIN = 2

		EXEC Inventry_AuditTail_WriteToLog 'Suppliers', @ID, 'INV', 'SUU', 'U', @LastModUserID,@PropertyID, '', ''


									--adding into log talbe AFTER inserting
	SELECT *
	INTO #NewTempSUppliers
	FROM Suppliers
	WHERE [ID] = @ID

	INSERT INTO Suppliers_Log
                         (SupplierID, PropertyID, Code, Name, Address1, BillingAddress, Email, Telephone1, Telephone2, FaxNo, ContactPerson, CountryID, Remarks, CreditLimit, CreditPeriod, PaymentTermID, CurrencyID, NameOnCheque, SupplierGradingID, 
                         IsDefaultSupplier, IsActive, IPAddress, CreatedUserID, LastModUserID, CreatedDate, LastModDate, IsLabor, IsForeign, VatNo, BSPCODE, AccountNo, Graceperiod, DefaultPaymenttype, Bankcode, BranchCode, CommissionAcc, 
                         DeductionControl, CreditorTypeID,Versions,IsConsigments)
			SELECT        ID, PropertyID, Code, Name, Address1, BillingAddress, Email, Telephone1, Telephone2, FaxNo, ContactPerson, CountryID, Remarks, CreditLimit, CreditPeriod, PaymentTermID, CurrencyID, NameOnCheque, 
                         SupplierGradingID, IsDefaultSupplier, IsActive, IPAddress, CreatedUserID, LastModUserID, CreatedDate, LastModDate, IsLabor, IsForeign, VatNo, BSPCODE, AccountNo, Graceperiod, DefaultPaymenttype, Bankcode, 
                         BranchCode, CommissionAcc, DeductionControl, CreditorTypeID,'After',IsConsigments
			FROM            #NewTempSUppliers
			WHERE        [ID] = @ID





		drop Table #BeforeTempSUppliers
		drop Table #NewTempSUppliers

	--end
	END
		ELSE
		BEGIN
	
		IF @Telephone2 IS NULL
			SET @Telephone2 = '-'
	
			DECLARE  @Prefix VARCHAR(20) = 'SC', @Result VARCHAR(200), @IsAutoGen BIT

		------Added by Nivesh 2024-11-19------
		------Check Supplier Code Auto Generate Start---------------
		DECLARE @isSupplierCodeAutoGenerate BIT = 1
		
		SELECT @isSupplierCodeAutoGenerate = ISNULL(isSupplierCodeAutoGenerate,1) FROM Companies WHERE CompanyID = @PropertyID
		SET @PropertyID = 0
		
		IF(@isSupplierCodeAutoGenerate = 1)
		BEGIN
		
			EXEC [dbo].[SP_AutoGenerateSupplierCode] @Prefix, @PropertyId,@Code OUTPUT
		
		END
		-----------------------------------------End-----------------------------------------
		 EXEC InsertMasterFileChangeLog 'Suppliers',@CreatedUserID,'I',@Name	
	


			EXEC [dbo].[CreateBusinessPartnerWithoutNICNo]
				@bspCode OUTPUT
				,'C'
				,@Name
				,@Telephone1
				,@Telephone2
				,'-'
				,@Email
				,''
				,''
				,@FaxNo
				,@Address1
				,'-'
				,'-'
				,'B490B26A-2886-4671-8253-A8644C76660F' 
				,'LKR'
				,'I'
				,@BSPCode
				,''
				,''
				,@CreditPeriod
				--,2
				,@CreditorTypeID
				,0
				,@CreditLimit
				,@NameOnCheque
				,@VatNo
				,@CommAcc
				,@DefaultPayType
				,@BankCode
				,@BranchCode
				,@AccountNo	
				,@PaymentGracePeriod
				,@DeductionCon
				,@IsActive


			INSERT INTO Suppliers(
			[PropertyID],
			[Code],
			[Name],
			[Address1],
			[BillingAddress],
			[Email],
			[Telephone1],
			[Telephone2],
			[FaxNo],
			[ContactPerson],
			[CountryID],
			[Remarks],
			[CreditLimit],
			[CreditPeriod],
			[PaymentTermID],
			[CurrencyID],
			[NameOnCheque],
			[SupplierGradingID],
			[IsDefaultSupplier],
			[IsActive],
			[IsLabor],
			[IPAddress],
			[CreatedUserID],
			[LastModUserID],
			[CreatedDate],
			[LastModDate],
			vatNo,
			BSPcode,
			CommissionAcc,
			DefaultPaymentType,
			BankCode,
			BranchCode,
			AccountNo,
			GracePeriod,
			DeductionControl,
			CreditorTypeID,
			IsConsigments,
			IsPettyCash,
			SupplierCategoryID,
			Email2
			)
			VALUES
			(
			@PropertyID,
			@Code,
			 UPPER(@Name),
			 UPPER(@Address1),
			 UPPER(@BillingAddress),
			 UPPER(@Email),
			@Telephone1,
			@Telephone2,
			@FaxNo,
			 UPPER(@ContactPerson),
			@CountryID,
			 UPPER(@Remarks),
			@CreditLimit,
			@CreditPeriod,
			@PaymentTermID,
			@CurrencyID,
			UPPER(@NameOnCheque),
			@SupplierGradingID,
			@IsDefaultSupplier,
			@IsActive,
			@IsLabor,
			@IPAddress,
			@CreatedUserID,
			@LastModUserID,
			@CreatedDate,
			@LastModDate,
			@VatNo,
			@bspCode,
			@CommAcc,
			@DefaultPayType,
			@BankCode,
			@BranchCode,
			@AccountNo,	
			@PaymentGracePeriod,
			@DeductionCon,
			@CreditorTypeID,
			@IsConsigments,
			@IsPettyCash,
			@SupplierCategoryID,
			UPPER(@Email2)
			)
			SELECT SCOPE_IDENTITY() AS ID
			SET @NewId = SCOPE_IDENTITY()
			SET @statusIN = 1;
			EXEC Inventry_AuditTail_WriteToLog 'Suppliers', @NewId, 'INV', 'SUI', 'I', @LastModUserID,@PropertyID, '', ''

			DECLARE @IsSupplierDocAttached BIT

			SELECT TOP (1) @IsSupplierDocAttached = ISNULL(IsSupplierDocAttached,0)
			FROM Companies
			



			IF(@TempSupplierId >0 AND @IsSupplierDocAttached = 1)
			BEGIN
				IF EXISTS(SELECT 1 FROM SupplierDocUploads WITH (NOLOCK) WHERE SupplierReqID =@TempSupplierId)
				BEGIN
					UPDATE SupplierDocUploads
					SET SupplierID = @NewId,Type = 'SU'
					WHERE SupplierReqID =@TempSupplierId 

				END
			END
		END

		---------------newly added 30.01.2024
		--2026-10-02-- commented: moved before BEGIN TRANSACTION
		--		IF(@CreatedUserID = 0)
		--	BEGIN
		--		RAISERROR('User ID Invalid, Please Log In Again',16,1)
		--		ROLLBACK TRANSACTION
		--	END

-----------------------------
	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN
	EXEC Inventry_AuditTail_WriteToLog 'Suppliers', @ID, 'INV', 'SUD', 'D', @LastModUserID,@PropertyID, '', ''
		DELETE [Suppliers] WHERE [ID] = @ID
	IF @@ROWCOUNT >0 
	BEGIN
		SET @statusIN = 3;
	END
	ELSE
	BEGIN
		SET @statusIN = -3;
	END
END --ACTIION -3 ENDS
	COMMIT TRAN -- Transaction Success!
	SET @status = @statusIN
END TRY
BEGIN CATCH
--	SET @status = -1;
--SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
--	IF @@TRANCOUNT > 0
--	ROLLBACK TRAN --RollBack in case of Error
--	PRINT @message

--2026-10-02-- commented: this IF only guarded the DECLARE below, nothing was rolled back
--IF @@TRANCOUNT>0
--2026-10-02-- start: roll back before re-raising so no transaction / locks are left open
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
--2026-10-02-- end

		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH
END--SP ENDS

GO

