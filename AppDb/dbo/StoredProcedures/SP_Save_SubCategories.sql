/*** ***************************************************************************************************** ****/
-- This procedure was Auto Genarated By A tool created by S.G. Asanga Chandrakumara
-- ON9/28/2017 11:14:21 AM
/*** ***************************************************************************************************** ****/

/*
-----------------------------------------------------
INPUTS
-----------------------------------------------------
- WHEN SAVE ADD ALL OTHER COLUMNS AS DEFAULT
- PASS @Action =1 TO INSERT OR UPDATE
- PASS @Action =2 TO DELETE
-----------------------------------------------------
OUTPUTS
-----------------------------------------------------
@status RETURNS 1 WHEN RECORD INSERTED AND NO ERRORS
@status RETURNS 2 WHEN RECORD UPDATED AND NO ERRORS
@status RETURNS 3 WHEN MORE THAN ONE RECORD DELETED AND NO ERRORS
@status RETURNS -3 WHEN DELETED SUCCESS BUT NO EFFECTED NO OF RECORDS
@status RETURNS -1 WHEN ANY KIND OF ERROR OCCURED
TO INSERT A RECORD PASS A NEGATIVE)VALUE TO @ID
*/
CREATE PROCEDURE[dbo].[SP_Save_SubCategories]
 --DECLARE PARAMETERS
 
	@Id int,
	@CategoryId int,
	@Code nvarchar(max),
	@Name nvarchar(max),
	@IsActive bit,
	@IPAddress nvarchar(max),
	@CreatedUserID int,
	@LastModUserID int,
	@CreatedDate datetime,
	@LastModDate datetime,
	@Action[int],
	@CompanyId[int],
	@status[int] output,
	@NewId[int] output,
	@IsExpiryDateApplicable BIT,
	@message NVARCHAR(max) OUTPUT

AS
	DECLARE @statusIN[int]
	SET @statusIN = 0;
	SET  @NewId =0
	SET  @message = ''
BEGIN
BEGIN TRY

	BEGIN TRANSACTION


	
	IF(LEN(@Code) > 3)
	BEGIN

		RAISERROR('Maximum allowed code length is 3.',16,1)
		ROLLBACK TRANSACTION


	END


IF @Action =1
	BEGIN
		IF EXISTS(SELECT* FROM SubCategories WHERE  [Id] = @Id and CompanyId = @CompanyId)
		BEGIN
		EXEC Inventry_AuditTail_WriteToLog 'SubCategories', @Id, 'INV', 'SCU', 'U', @LastModUserID,@CompanyId, '', ''
		--EXEC InsertMasterFileChangeLog 'Sub Categories',@CreatedUserID,'U',@Name
		 --UPDATE THE RECORD
		 UPDATE SubCategories SET
		[CategoryId] = @CategoryId,
		[Code] = @Code,
		[Name] = @Name,
		[IsActive] = @IsActive,
		[IPAddress] = @IPAddress,
		[LastModUserID] = @LastModUserID,
		[LastModDate] = @LastModDate,
		CompanyId = @CompanyId,
		[IsExpiryDateApplicable] = @IsExpiryDateApplicable
		WHERE [Id] = @Id
		SET @statusIN = 2


		----Adding ExpiryDate Enable for Stock Items
		UPDATE StockItemHeaders
		SET IsExpiryDateApplicable= @IsExpiryDateApplicable
		WHERE SubCategoryID = @Id
		-----End

		-----------newly added 06.02.2024 
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
	EXEC InsertMasterFileChangeLog 'Sub Categories',@CreatedUserID,'I',@Name
	--INSERT THE RECORD
	INSERT INTO SubCategories(
		[CategoryId],
		[Code],
		[Name],
		[IsActive],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate],
		CompanyId,
		[IsExpiryDateApplicable]
		)
		VALUES
		(
		@CategoryId,
		@Code,
		@Name,
		@IsActive,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate,
		@CompanyId,
		@IsExpiryDateApplicable
		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @NewId = SCOPE_IDENTITY()
		SET @statusIN = 1;
		EXEC Inventry_AuditTail_WriteToLog 'SubCategories', @NewId, 'INV', 'SCI', 'I', @CreatedUserID,@CompanyId, '', ''
	END

			----newly added 24.01.2024 
			IF(@CreatedUserID = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

-----------------------------
	END --ACTION 1 ENDS
ELSE IF @Action = 2
	BEGIN
		-- 21.02.2024 - vinuki 
			SELECT @Id = Id FROM SubCategories WHERE Code = @Code   
		------------------------------------------------------
			SELECT * INTO #temptable FROM (
			SELECT DISTINCT SubCategoryID FROM StockItemHeaders WHERE SubCategoryID = @Id
			UNION 
			SELECT SubCategoryId FROM SubCategories02 WHERE SubCategoryId = @Id
			) AS CheckSubCategories

			IF  NOT EXISTS (SELECT 1 FROM #temptable  WHERE SubCategoryID = @Id)
			BEGIN
				EXEC Inventry_AuditTail_WriteToLog 'SubCategories', @Id, 'INV', 'SCD', 'D', @CreatedUserID,@CompanyId, '', ''
				DELETE [SubCategories] WHERE [Code] = @Code
				
			END
			ELSE
			BEGIN
				RAISERROR('Sub Category exist in transactions',16,1)
				ROLLBACK TRANSACTION
			END
			
			DROP TABLE #temptable
		------------------------------------------------------





		--DELETE [SubCategories] WHERE [Id] = @Id
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
	SET @status = -1;
--SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
SET @Message = 'Error Occured: ' + ERROR_MESSAGE() 
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH
END--SP ENDS

GO

