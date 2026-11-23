/*** ***************************************************************************************************** ****/
-- This procedure was Auto Genarated By A tool created by S.G. Asanga Chandrakumara
-- ON3/29/2018 9:49:23 AM
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
CREATE PROCEDURE[dbo].[SPP_Save_BOQHeaders]
 --DECLARE PARAMETERS

	@Id int,
	@ProjectID int,
	@BOQCode VARCHAR(max),
	@BOQDate datetime,
	@BOQName VARCHAR(max),
	@Approve bit,
	@ApprovedUserID int,
	@ApprovedDate datetime,
	@BOQStatus bit,
	@CurrentVersion int,
	@isDisRate bit,
	@DisValue decimal(18, 2),
	@SundryValue decimal(18, 2),
	@Action[int],
	@status[int] OUTPUT,
	@BOQID int OUTPUT,
	@PropertyID INT,
	@OHPmaterial decimal(18,2),
	@OHPlabour decimal(18,2)

AS
	DECLARE @statusIN[int]
	SET @statusIN = 0;
BEGIN
BEGIN TRY
	BEGIN TRANSACTION
IF @Action =1
	BEGIN
		IF EXISTS(SELECT* FROM BOQHeaders WHERE  [Id] = @Id)
		BEGIN
		SELECT @ProjectID
		 --UPDATE THE RECORD
		 UPDATE BOQHeaders SET
		[ProjectID] = @ProjectID,
		[BOQDate] = @BOQDate,
		[Approve] = @Approve,
		[ApprovedUserID] = @ApprovedUserID,
		[ApprovedDate] = @ApprovedDate,
		[BOQStatus] = @BOQStatus,
		[CurrentVersion] = @CurrentVersion,
		[isDisRate] = @isDisRate,
		[DisValue] = @DisValue,
		[BOQName]=@BOQName,
		[SundryValue] = @SundryValue,
		[BOQCode] = @BOQCode
		WHERE [Id] = @Id
		SET @statusIN = 2
	END
	ELSE
	BEGIN

	DECLARE @DocumentNo NVARCHAR(MAX)
	select @DocumentNo= dbo.FN_GetNextDocumentNumber (@PropertyID,-9999,'BQ')

   IF @DocumentNo IS NULL
   BEGIN
	INSERT INTO TransactionTypeWiseNextNumbers
	(PropertyID, LocationID, TransactionType, NextNumber, LengthOfFormatting)
	VALUES (@PropertyID,-9999,'BQ',1,6)
   END



select @DocumentNo= dbo.FN_GetNextDocumentNumber (@PropertyID,-9999,'BQ')
SELECT @DocumentNo
--SELECT * FROM TransactionTypeWiseNextNumbers
update TransactionTypeWiseNextNumbers
set NextNumber=NextNumber+1

where locationid=-9999 and transactionType='BQ'

	--INSERT THE RECORD
	INSERT INTO BOQHeaders(
		[ProjectID],
		[BOQDate],
		[Approve],
		[ApprovedUserID],
		[ApprovedDate],
		[BOQStatus],
		[CurrentVersion],
		[isDisRate],
		[DisValue],
		[SundryValue],
		[BOQCode],
		[BOQName],
		[OHPmaterial],
		[OHPlabour],
		[VersionNo]
		
		)
		VALUES
		(
		@ProjectID,
		@BOQDate,
		0,
		@ApprovedUserID,
		@ApprovedDate,
		1,
		@CurrentVersion,
		@isDisRate,
		@DisValue,
		@SundryValue,
		'B'+@DocumentNo,
		@BOQName,
		@OHPmaterial,
		@OHPlabour,
		1 )
		SELECT @BOQID= SCOPE_IDENTITY() 



		UPDATE dbo.BOQHeaders SET MainBoqId=@BOQID WHERE ID = @BOQID
		SET @statusIN = 1;
	END
	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN
		DELETE [BOQHeaders] WHERE [Id] = @Id
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
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
	SET @status = -1;
		SELECT
		ERROR_NUMBER() AS ErrorNumber
		,ERROR_SEVERITY() AS ErrorSeverity
		,ERROR_STATE() AS ErrorState
		,ERROR_PROCEDURE() AS ErrorProcedure
		,ERROR_LINE() AS ErrorLine
	,ERROR_MESSAGE() AS ErrorMessage
END CATCH
END--SP ENDS

GO

