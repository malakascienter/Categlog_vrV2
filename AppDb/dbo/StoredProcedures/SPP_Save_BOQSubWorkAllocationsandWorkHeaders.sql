/*** ***************************************************************************************************** ****/
-- This procedure was Auto Genarated By A tool created by S.G. Asanga Chandrakumara
-- ON3/29/2018 10:58:33 AM
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
CREATE PROCEDURE[dbo].[SPP_Save_BOQSubWorkAllocationsandWorkHeaders]
 --DECLARE PARAMETERS

	@Id int,
	@BOQID int,
	@Description nvarchar(150),
	@Quantity decimal(18, 2),
	@Rate decimal(18, 2),
	@DepartmentID int,
	@Awarded bit,
	@SeqNo int,
	@WorkID int,
	@MainWorkID int,
	@IPAddress nvarchar(max),
	@CreatedUserID int,
	@LastModUserID int,
	@CreatedDate datetime,
	@LastModDate datetime,
	@WorkHeaderStatus bit,
	@Action[int],
	@status[int] OUTPUT,
	@PropertyID INT,
	@UnitID INT,
	@SundryAmount decimal(18,2),
	@OHPPercentage decimal(18,2)

AS
	DECLARE @statusIN[int]
	SET @statusIN = 0;
BEGIN
BEGIN TRY
	BEGIN TRANSACTION
IF @Action =1
	BEGIN
	
	
	-------------work header save -----------------
	
	IF EXISTS(SELECT* FROM WorkHeaders WHERE  [Id] = @WorkID)
		BEGIN
		 --UPDATE THE RECORD-
		 UPDATE WorkHeaders SET
		[Description] = @Description,
		[IPAddress] = @IPAddress,
		[CreatedUserID] = @CreatedUserID,
		[LastModUserID] = @LastModUserID,
		[CreatedDate] = @CreatedDate,
		[LastModDate] = @LastModDate,
		[WorkHeaderStatus] = @WorkHeaderStatus
		WHERE [Id] = @Id
		SET @statusIN = 2
	END
	ELSE
	BEGIN
	--INSERT THE RECORD
	DECLARE @DocumentNo NVARCHAR(MAX)
	select @DocumentNo= dbo.FN_GetNextDocumentNumber (@PropertyID,-9999,'WK')

   IF @DocumentNo IS NULL
   BEGIN
	INSERT INTO TransactionTypeWiseNextNumbers
	(PropertyID, LocationID, TransactionType, NextNumber, LengthOfFormatting)
	VALUES (@PropertyID,-9999,'WK',1,6)
   END



select @DocumentNo= dbo.FN_GetNextDocumentNumber (@PropertyID,-9999,'WK')
SELECT @DocumentNo
--SELECT * FROM TransactionTypeWiseNextNumbers
update TransactionTypeWiseNextNumbers
set NextNumber=NextNumber+1
where locationid=-9999 and transactionType='WK'
	INSERT INTO WorkHeaders(
		[Description],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate],
		[WorkHeaderStatus],
		[WorkCode]
		)
		VALUES
		(
		@Description,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate,
		@WorkHeaderStatus,
		'W'+@DocumentNo
		)
		--SELECT SCOPE_IDENTITY() AS ID
		SELECT @WorkID=SCOPE_IDENTITY()
		SET @statusIN = 1;
	END
	
	-------------end work header save --------------

		IF EXISTS(SELECT* FROM BOQSubWorkAllocations WHERE  [Id] = @Id)
		BEGIN
		 --UPDATE THE RECORD
		 UPDATE BOQSubWorkAllocations SET
		[BOQID] = @BOQID,
		[Description] = @Description,
		[Quantity] = @Quantity,
		[Rate] = @Rate,
		[DepartmentID] = @DepartmentID,
		[Awarded] = @Awarded,
		[SeqNo] = @SeqNo,
		[WorkID] = @WorkID,
		[MainWorkID] = @MainWorkID,
		[UnitID]=@UnitID,
		[SundryAmount]=@SundryAmount
		WHERE [Id] = @Id
		SET @statusIN = 2
	END
	ELSE
	BEGIN
	--INSERT THE RECORD
	INSERT INTO BOQSubWorkAllocations(
		[BOQID],
		[Description],
		[Quantity],
		[Rate],
		[DepartmentID],
		[Awarded],
		[SeqNo],
		[WorkID],
		[MainWorkID],
		[UnitID],
		[SundryAmount],
		[OHPValue]
		)
		VALUES
		(
		@BOQID,
		@Description,
		@Quantity,
		@Rate,
		@DepartmentID,
		@Awarded,
		@SeqNo,
		@WorkID,
		@MainWorkID,
		@UnitID,
		@SundryAmount,
		case when @SundryAmount=0 then 0 Else  	@OHPPercentage * @SundryAmount/100 end
		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @statusIN = 1;
	END
	
	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN
		DELETE [BOQSubWorkAllocations] WHERE [Id] = @Id
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

