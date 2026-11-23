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
CREATE PROCEDURE[dbo].[SP_Save_Units]
 --DECLARE PARAMETERS

	@Id int,
	@LocationID int,
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
	@message NVARCHAR(max) OUTPUT

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
		IF EXISTS(SELECT* FROM Units WHERE  [Id] = @Id )--and CompanyId = @CompanyId) commented by Isuru 2025-07-08
		BEGIN
		EXEC Inventry_AuditTail_WriteToLog 'Units', @Id, 'INV', 'UNU', 'U', @LastModUserID,@CompanyId, '', ''
		--EXEC InsertMasterFileChangeLog 'Units',@CreatedUserID,'U',@Name
		 --UPDATE THE RECORD
		 UPDATE Units SET
		[LocationID] = @LocationID,
		[Code] = @Code,
		[Name] = @Name,
		[IsActive] = @IsActive,
		[IPAddress] = @IPAddress,
		[LastModUserID] = @LastModUserID,
		[LastModDate] = @LastModDate
		--,CompanyId= @CompanyId commented by Isuru 2025-07-08
		WHERE [Id] = @Id
		SET @statusIN = 2

					----newly added 08.02.2024 
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
	EXEC InsertMasterFileChangeLog 'Units',@CreatedUserID,'I',@Name
	--INSERT THE RECORD
	INSERT INTO Units(
		[LocationID],
		[Code],
		[Name],
		[IsActive],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate],
		CompanyId
		)
		VALUES
		(
		@LocationID,
		@Code,
		@Name,
		@IsActive,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate,
		@CompanyId
		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @NewId = SCOPE_IDENTITY()
		SET @statusIN = 1;
		EXEC Inventry_AuditTail_WriteToLog 'Units', @NewId, 'INV', 'UNI', 'I', @CreatedUserID,@CompanyId, '', ''	
	END
			----newly added 08.02.2024 
			IF(@CreatedUserID = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

-----------------------------

	END --ACTION 2 ENDS
ELSE IF @Action = 2

	BEGIN
	--21.02.2024 by vinuki 
		SELECT @Id = Id FROM Units WHERE Code = @Code 
		------------------------------------------------------
			SELECT * INTO #temptable FROM (
			SELECT DISTINCT MasterUnitID  AS UnitID FROM StockItemDetails WHERE MasterUnitID = @Id
			UNION ALL
			SELECT DISTINCT FromUnitID  AS UnitID FROM UnitConversions WHERE FromUnitID = @Id
			UNION ALL
			SELECT DISTINCT ToUnitID  AS UnitID FROM UnitConversions WHERE ToUnitID = @Id
			UNION ALL
			SELECT DISTINCT MasterUnitID  AS UnitID FROM StockTransactionDetails WHERE MasterUnitID = @Id
			UNION ALL
			SELECT DISTINCT UnitID  AS UnitID FROM PoDetails WHERE UnitID = @Id
			) AS CheckUnits

			IF  NOT EXISTS (SELECT 1 FROM #temptable  WHERE UnitID  = @Id)
			BEGIN
				EXEC Inventry_AuditTail_WriteToLog 'Units', @Id, 'INV', 'UND', 'D', @CreatedUserID,@CompanyId, '', ''	
				DELETE [Units] WHERE Code = @Code
				
			END
			ELSE
			BEGIN
				RAISERROR('Units exist in transactions',16,1)
				ROLLBACK TRANSACTION
			END
			
			DROP TABLE #temptable
		------------------------------------------------------

		--DELETE [Units] WHERE [Id] = @Id
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

