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
CREATE PROCEDURE[dbo].[SP_Save_StockItemClassificationHeaders]
 --DECLARE PARAMETERS

	@Id int,
	@CompanyId int,
	@LocationId int,
	@Code nvarchar(max),
	@Name nvarchar(max),
	@IsActive bit,
	@IPAddress nvarchar(max),
	@CreatedUserID int,
	@LastModUserID int,
	@CreatedDate datetime,
	@LastModDate datetime,
	@Action[int],
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
		IF EXISTS(SELECT* FROM StockItemClassificationHeaders WHERE  [Id] = @Id)
		BEGIN

		EXEC Inventry_AuditTail_WriteToLog 'StockItemClassificationHeaders', @Id, 'INV', 'SICHU', 'U', @LastModUserID,@CompanyId, '', ''

		EXEC InsertMasterFileChangeLog 'Stock Item Classification',@CreatedUserID,'U',@Name
		 --UPDATE THE RECORD
		 UPDATE StockItemClassificationHeaders SET
		[CompanyId] = @CompanyId,
		[LocationId] = @LocationId,
		[Code] = @Code,
		[Name] = @Name,
		[IsActive] = @IsActive,
		[IPAddress] = @IPAddress,
		[LastModUserID] = @LastModUserID,
		[LastModDate] = @LastModDate
		WHERE [Id] = @Id
		SET @statusIN = 2
	END
	ELSE
	BEGIN
	EXEC InsertMasterFileChangeLog 'Stock Item Classification',@CreatedUserID,'I',@Name
	--INSERT THE RECORD
	INSERT INTO StockItemClassificationHeaders(
		[CompanyId],
		[LocationId],
		[Code],
		[Name],
		[IsActive],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate]
		)
		VALUES
		(
		@CompanyId,
		@LocationId,
		@Code,
		@Name,
		@IsActive,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate
		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @NewId = SCOPE_IDENTITY()
		SET @statusIN = 1;

		EXEC Inventry_AuditTail_WriteToLog 'StockItemClassificationHeaders', @NewId, 'INV', 'SICHI', 'I', @CreatedUserID,@CompanyId, '', ''
	END
	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN
	if exists ( select 1 from [StockItemClassificationHeaders] WHERE [Code] = @Code and [Id] = @Id )
	begin
		EXEC Inventry_AuditTail_WriteToLog 'StockItemClassificationHeaders', @Id, 'INV', 'SICHD', 'D', @CreatedUserID,@CompanyId, '', ''
		DELETE [StockItemClassificationHeaders] WHERE [Code] = @Code and [Id] = @Id
	end
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
SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH
END--SP ENDS

GO

