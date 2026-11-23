/*** ***************************************************************************************************** ****/
-- This procedure was Auto Genarated By A tool created by S.G. Asanga Chandrakumara
-- ON2/13/2018 3:42:51 PM
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



--declare @p16 int
--set @p16=2
--declare @p18 int
--set @p18=NULL
--declare @p19 nvarchar(200)
--set @p19=NULL
--exec SP_Save_TransactionTypes @Id=55,@Code=N'BL',@Name=N'Bills',@GLNarration=N'lllll',@IsActive=1,@tempDocumentNo=N'',@DocumentNo=N'',@DocumentID=0,@CompanyId=1,@LocationId=0,@IPAddress=N'192.168.120.36',@CreatedUserID=1,@LastModUserID=1,@CreatedDate='2018-12-11 00:00:00',@LastModDate='2019-01-21 09:40:40.343',@status=@p16 output,@action=1,@NewId=@p18 output,@message=@p19 output

CREATE PROCEDURE[dbo].[SP_Save_TransactionTypes]
 --DECLARE PARAMETERS

	@Id [int] output,
	@Code nvarchar(max),
	@Name nvarchar(max),
	@GLNarration nvarchar(max),
	@IsActive bit,
	@tempDocumentNo nvarchar(20),
	@DocumentNo nvarchar(20),
	@DocumentID int,
	@CompanyId int,
	@LocationId int,
	@IPAddress nvarchar(max),
	@CreatedUserID int,
	@LastModUserID int,
	@CreatedDate datetime,
	@LastModDate datetime,
	@Action[int],
	@status[int] OUTPUT,
	@NewId[int] output,
	@message NVARCHAR(max) OUTPUT
AS
	DECLARE @statusIN[int]
	SET @statusIN = 0;
BEGIN
BEGIN TRY
	BEGIN TRANSACTION
IF @Action =1
	BEGIN
		IF EXISTS(SELECT* FROM TransactionTypes WHERE  [Id] = @Id)
		BEGIN
		 --UPDATE THE RECORD
		 UPDATE TransactionTypes SET
		[Code] = @Code,
		[Name] = @Name,
		[GLNarration] = @GLNarration,
		[IsActive] = @IsActive,
		[tempDocumentNo] = @tempDocumentNo,
		[DocumentNo] = @DocumentNo,
		[DocumentID] = @DocumentID,
		[CompanyId] = @CompanyId,
		[LocationId] = @LocationId,
		[IPAddress] = @IPAddress,
		[CreatedUserID] = @CreatedUserID,
		[LastModUserID] = @LastModUserID,
		[CreatedDate] = @CreatedDate,
		[LastModDate] = @LastModDate
		WHERE [Id] = @Id
		--SELECT SCOPE_IDENTITY() AS ID
		SET @NewId = @Id
	
		SET @statusIN = 2;
		
	   
	END
	ELSE
	BEGIN
	--INSERT THE RECORD
	INSERT INTO TransactionTypes(
		[Code],
		[Name],
		[GLNarration],
		[IsActive],
		[tempDocumentNo],
		[DocumentNo],
		[DocumentID],
		[CompanyId],
		[LocationId],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate]
		)
		VALUES
		(
		@Code,
		@Name,
		@GLNarration,
		@IsActive,
		@tempDocumentNo,
		@DocumentNo,
		@DocumentID,
		@CompanyId,
		@LocationId,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate
		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @NewId = SCOPE_IDENTITY()
	
		SET @statusIN = 1;
	END
	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN
		DELETE [TransactionTypes] WHERE [Id] = @Id
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


--select * from  

GO

