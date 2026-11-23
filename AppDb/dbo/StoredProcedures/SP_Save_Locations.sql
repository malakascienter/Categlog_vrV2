
-- ============================================================
-- created by S.G. Asanga Chandrakumara
-- Modified By Nivesh 
-- 2024-02-16
-- ============================================================

CREATE PROCEDURE [dbo].[SP_Save_Locations]
 --DECLARE PARAMETERS

	@Id int,
	@CompanyID int,
	@Code nvarchar(max),
	@Name nvarchar(max),
	@Prefix nvarchar(10),
	@IsActive bit,
	@IPAddress nvarchar(max),
	@CreatedUserID int,
	@LastModUserID int,
	@CreatedDate datetime,
	@LastModDate datetime,
	@Action[int],
	@status[int] output,
	@NewId[int] output,
	@message NVARCHAR(max) OUTPUT,
	@DeliveryAddress VARCHAR(MAX),
	@ContactPerson VARCHAR(MAX),
	@IsProductionLocation BIT,
	--Added by Tharuka 2026-09-08 - captured on INSERT only
	@DepartmentID BIGINT = 0,
	@DayEndValidationMode CHAR(4) = 'N',
	@IsInvoice BIT = 0,
	@HoldingDays INT = NULL --Added by Isuru 2026-09-24
AS
	DECLARE @statusIN[int],@ExistinglocName VARCHAR(MAX)
	--Added by Tharuka 2026-09-11 - franchise department for FranchiseDepartmentID; stays NULL
	--unless the company has IsFranchiseInvoiceEnable = 1
	DECLARE @FranchiseDepartmentID INT = NULL
	--Added by Isuru 2026-09-24 - Holding Days is only written while the company uses it
	DECLARE @IsLocationHoldingDays BIT = 0
	SET @statusIN = 0;
	SET  @NewId =0
	SET  @message = ''
BEGIN
BEGIN TRY
	BEGIN TRANSACTION

	
IF @Action =1
	BEGIN
		
		--Added by Isuru 2026-09-24 - Holding Days (INSERT and UPDATE)
		SELECT @IsLocationHoldingDays = ISNULL(IsLocationHoldingDays, 0) FROM Companies WHERE CompanyID = @CompanyID

		IF @IsLocationHoldingDays = 1 AND @HoldingDays < 0
		BEGIN
			RAISERROR('Holding Days cannot be negative!', 16, 1);
		END
		--end


		IF EXISTS(SELECT* FROM Locations WHERE  [Id] = @Id)
		BEGIN
		EXEC InsertMasterFileChangeLog 'Location',@CreatedUserID,'U',@Name
		 --UPDATE THE RECORD
		 
		 -----------------------------------
		 UPDATE Locations SET
		[CompanyID] = @CompanyID,
		[PropertyId]= @CompanyID,--added by Nivesh 2024-02-16
		[Code] = @Code,
		[Name] = @Name,
		[Prefix]=@Prefix,
		[IsActive] = @IsActive,
		[IPAddress] = @IPAddress,
		[LastModUserID] = @LastModUserID,
		[LastModDate] = @LastModDate,
		[DeliveryAddress] = @DeliveryAddress,
		[ContactPerson] = @ContactPerson,
		[HoldingDays] = CASE WHEN @IsLocationHoldingDays = 1 THEN @HoldingDays ELSE [HoldingDays] END
		WHERE [Id] = @Id
		SET @statusIN = 2
		---this is test 2024-02-16
		EXEC Inventry_AuditTail_WriteToLog 'Locations', @Id, 'INV', 'LOCU', 'U', @LastModUserID,@CompanyID, '', ''
			----newly added 06.02.2024 
			IF(@LastModUserID = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

-----------------------------
	END


	ELSE
	BEGIN

	--Added by Isuru 2024-09-27 to prevent same prefix first two leeters instering 
	IF EXISTS(SELECT 1 FROM Locations WHERE CompanyID = @CompanyID AND SUBSTRING(Prefix, 1, 3) = SUBSTRING(@Prefix, 1, 3))
	BEGIN
			SELECT @ExistinglocName = Name FROM Locations WHERE CompanyID = @CompanyID AND SUBSTRING(Prefix, 1, 3) = SUBSTRING(@Prefix, 1, 3)

			 RAISERROR('The first three letters of the Prefix Code are the same as an existing location - %s!', 16, 1, @ExistinglocName);
			ROLLBACK TRANSACTION
	END
	--end

	--Added by THaruka 2026-09-08 - normalise and validate the three insert only inputs

	SET @DepartmentID = ISNULL(@DepartmentID, 0)
	SET @DayEndValidationMode = ISNULL(NULLIF(LTRIM(RTRIM(@DayEndValidationMode)), ''), 'N')
	SET @IsInvoice = ISNULL(@IsInvoice, 0)

	IF NOT EXISTS(SELECT 1 FROM DayEnd_ValidationModes WHERE LTRIM(RTRIM(Code)) = @DayEndValidationMode)
	BEGIN
		RAISERROR('Invalid Day End Validation Mode - %s!', 16, 1, @DayEndValidationMode);
		ROLLBACK TRANSACTION
	END

	IF @DepartmentID <> 0 AND NOT EXISTS(SELECT 1 FROM Departments WHERE Id = @DepartmentID AND PropertyID = @CompanyID)
	BEGIN
		RAISERROR('The selected Department does not belong to this company!', 16, 1);
		ROLLBACK TRANSACTION
	END
	--end

	--Added by Tharuka 2026-09-11 - when the company invoices franchises, the selected department is
	
	IF @DepartmentID <> 0
	   AND EXISTS(SELECT 1 FROM Companies WHERE CompanyID = @CompanyID AND IsFranchiseInvoiceEnable = 1)
	BEGIN
		SET @FranchiseDepartmentID = CAST(@DepartmentID AS INT) --Departments.Id is INT
		SET @DepartmentID = 0
	END
	--end

	EXEC InsertMasterFileChangeLog 'Location',@CreatedUserID,'I',@Name
	--INSERT THE RECORD
	INSERT INTO Locations(
		[CompanyID],
		[Code],
		[Name],
		[Prefix],
		[IsActive],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate],
		[PropertyId],
		[DeliveryAddress],
		[ContactPerson],
		[IsProductionLocation],
		[DepartmentID],
		[DayEndValidationMode],
		[IsInvoice],				
		[FranchiseDepartmentID]	--Added by Tharuka 2026-09-11
		,[HoldingDays]				--Added by Isuru 2026-09-24
		)
		VALUES
		(
		@CompanyID,
		@Code,
		@Name,
		@Prefix,
		@IsActive,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate,
		@CompanyID,
		@DeliveryAddress,
		@ContactPerson,
		@IsProductionLocation,
		@DepartmentID,
		@DayEndValidationMode,
		@IsInvoice,				
		@FranchiseDepartmentID	--Added by Tharuka 2026-09-11
		,CASE WHEN @IsLocationHoldingDays = 1 THEN @HoldingDays ELSE 0 END	--Added by Isuru 2026-09-24 - 0 = column default
		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @NewId = SCOPE_IDENTITY()
		SET @statusIN = 1;
----newly added 24.01.2024 
-----------Log Delete
		EXEC Inventry_AuditTail_WriteToLog 'Locations', @NewId, 'INV', 'LOCI', 'I', @LastModUserID,@CompanyID, '', ''
		
		IF(@CreatedUserID = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

-----------------------------
	END
	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN
		EXEC InsertMasterFileChangeLog 'Location',@CreatedUserID,'D',@Name

		IF (@Id IS NULL OR @Id = 0)
		BEGIN
			SELECT @Id = Id FROM locations WHERE Code = @Code  AND CompanyID = @CompanyID -- Added By Nivesh 2024-02-16
		END
		------------------------------------------------------
			SELECT * INTO #temptable FROM (
			SELECT DISTINCT LocationID FROM PoHeaders WHERE LocationID = @Id
			UNION ALL
			SELECT DISTINCT LocationID FROM StockTransactionHeaders WHERE LocationID = @Id
			UNION ALL
			SELECT DISTINCT LocationID FROM RequestHeaders WHERE LocationID = @Id
			UNION ALL
			SELECT DISTINCT LocationID FROM StockItemDetails WHERE LocationID = @Id
			UNION ALL
			SELECT DISTINCT LocationID FROM SupplierWiseItemDetails WHERE LocationID = @Id
			) AS CheckLocations

			IF  NOT EXISTS (SELECT 1 FROM #temptable  WHERE LocationID = @Id)
			BEGIN
				EXEC Inventry_AuditTail_WriteToLog 'Locations', @Id, 'INV', 'LOCD', 'D', @LastModUserID,@CompanyID, '', ''
				DELETE [Locations] WHERE Id = @Id AND CompanyID = @CompanyID
				
			END
			ELSE
			BEGIN
				RAISERROR('Location exist in transactions',16,1)
				ROLLBACK TRANSACTION
			END
			
			DROP TABLE #temptable
		------------------------------------------------------
	IF @@ROWCOUNT >0 
	BEGIN
		SET @statusIN = 3;
		-----------Log Delete
		
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
	SET @status = -1;
--SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
SET @Message = 'Error Occured: ' + ERROR_MESSAGE() 
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH
END--SP ENDS

GO

