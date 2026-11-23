/*** ***************************************************************************************************** ****/
-- This procedure was Auto Genarated By A tool created by S.G. Asanga Chandrakumara
-- ON9/28/2017 11:14:20 AM
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
CREATE PROCEDURE[dbo].[SP_Save_CurrencyMasters]
 --DECLARE PARAMETERS

	@Id int,
	@Symbol nvarchar(max),
	@Name nvarchar(max),
	@ExchangeRate decimal(18, 2),
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
	@IsAllowSignOn bit ,
	@IsAllowBalance bit  ,
	@SortOrder int,
	@IsAllowSettlement bit

AS
	DECLARE @statusIN[int]
	SET @statusIN = 0;
	SET  @NewId =0
	SET  @message = ''
BEGIN
BEGIN TRY
	BEGIN TRANSACTION
IF @Action =1
	BEGIN
		IF EXISTS(SELECT* FROM CurrencyMasters WHERE  [Id] = @Id)
		BEGIN
		EXEC Inventry_AuditTail_WriteToLog 'CurrencyMasters', @Id, 'INV', 'CUU', 'U', @LastModUserID,0, '', ''
		--EXEC InsertMasterFileChangeLog 'Currency Master',@CreatedUserID,'U',@Name
		 --UPDATE THE RECORD
		 UPDATE CurrencyMasters SET
		[Symbol] = @Symbol,
		[Name] = @Name,
		[ExchangeRate] = @ExchangeRate,
		[IsActive] = @IsActive,
		[IPAddress] = @IPAddress,
		[LastModUserID] = @LastModUserID,
		[LastModDate] = @LastModDate,
		[IsAllowSignOn] = @IsAllowSignOn,
		[IsAllowBalance] = @IsAllowBalance,
		[SortOrder] = @SortOrder,
		[IsAllowSettlement] = @IsAllowSettlement
 
		WHERE [Id] = @Id
		SET @statusIN = 2
		--SELECT 1/0

		------------newly added 06.02.2024 
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




	--EXEC InsertMasterFileChangeLog 'Currency Master',@CreatedUserID,'I',@Name
	--INSERT THE RECORD
	INSERT INTO CurrencyMasters(
		[Symbol],
		[Name],
		[ExchangeRate],
		[IsActive],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate],
		[IsAllowSignOn],
		[IsAllowBalance],
		[SortOrder],
		[ISOCode],
		[IsAllowSettlement]

		)
		VALUES
		(
		@Symbol,
		@Name,
		@ExchangeRate,
		@IsActive,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate,
		@IsAllowSignOn,
		@IsAllowBalance,
		@SortOrder,
		@Symbol,
		@IsAllowSettlement

		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @NewId = SCOPE_IDENTITY()
		SET @statusIN = 1;
		EXEC Inventry_AuditTail_WriteToLog 'CurrencyMasters', @NewId, 'INV', 'CUI', 'I', @CreatedUserID,0, '', ''

	END

			----newly added 29.01.2024 
			IF(@CreatedUserID = 0)
		BEGIN
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

-----------------------------
	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN
		--20.02.2024 - added by vinuki 	
		------------------------------------------------------
		SELECT @Id = Id FROM CurrencyMasters WHERE Symbol = @Symbol   
			SELECT * INTO #temptable FROM (
			SELECT DISTINCT CurrencyID FROM suppliers WHERE CurrencyID = @Id

			) AS CheckCurrencyMasters

			IF  NOT EXISTS (SELECT 1 FROM #temptable  WHERE CurrencyID = @Id)
			BEGIN
			EXEC Inventry_AuditTail_WriteToLog 'CurrencyMasters', @Id, 'INV', 'CUD', 'D', @CreatedUserID,0, '', ''
				DELETE [CurrencyMasters] WHERE [Id] = @Id
			
			END
			ELSE
			BEGIN
				RAISERROR('Currency exist in transactions',16,1)
				ROLLBACK TRANSACTION
			END
			
			DROP TABLE #temptable
		------------------------------------------------------

		

	
	IF @@ROWCOUNT >0 
	BEGIN
		SET @statusIN = 3;
	END
	ELSE
	BEGIN
		SET @statusIN = -3;
	END
END --ACTIION -3 ENDS

DECLARE @PropertyID INT
SELECT CompanyID INTO #TempCompany FROM Companies where IsActive = 1 AND IsRetail = 1
WHILE EXISTS( SELECT * FROM #TempCompany )
BEGIN

SELECT top(1) @PropertyID = CompanyID FROM #TempCompany

		Declare @LocationJson VARCHAR(MAX)
		SET @LocationJson = (SELECT  Id AS LocationID FROM Locations WHERE IsActive = 1 AND CompanyID = @PropertyID AND IsSalesLocation = 1 FOR JSON PATH,INCLUDE_NULL_VALUES)
		EXEC RT_SYNC_DATA_INSERT @PropertyID,@Id,'0','Currency',1,0,@LocationJson

DELETE TOP(1) FROM #TempCompany

END

	COMMIT TRAN -- Transaction Success!
	SET @status = @statusIN
END TRY
BEGIN CATCH
	SET @status = -1;
--SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
SET @message = 'Error Occured : ' +  ERROR_MESSAGE()
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH
END--SP ENDS

GO

