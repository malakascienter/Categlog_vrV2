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
CREATE PROCEDURE[dbo].[SPP_Save_RateAnalysisHeaders]
 --DECLARE PARAMETERS

	@Id int,
	@Description nvarchar(50),
	@RateCode NVARCHAR(max),
	@RateAnalysisHeaderStatus int,
	@ProfitMarginPer decimal(18, 2),
	@ProfitMarginVal decimal(18, 2),
	@OverheadCostPer decimal(18, 2),
	@OverheadCostVal decimal(18, 2),
	@TotalCost decimal(18, 2),
	@IPAddress nvarchar(max),
	@CreatedUserID int,
	@LastModUserID int,
	@CreatedDate datetime,
	@LastModDate datetime,
	@Action[int],
	@status[int] OUTPUT,
	@PropertyID INT

AS
	DECLARE @statusIN[int]
	SET @statusIN = 0;
BEGIN
BEGIN TRY
	BEGIN TRANSACTION
IF @Action =1
	BEGIN
		IF EXISTS(SELECT* FROM RateAnalysisHeaders WHERE  [Id] = @Id)
		BEGIN
		 --UPDATE THE RECORD
		 UPDATE RateAnalysisHeaders SET
		[Description] = @Description,
		[RateAnalysisHeaderStatus] = @RateAnalysisHeaderStatus,
		[ProfitMarginPer] = @ProfitMarginPer,
		[ProfitMarginVal] = @ProfitMarginVal,
		[OverheadCostPer] = @OverheadCostPer,
		[OverheadCostVal] = @OverheadCostVal,
		[RateCode]=@RateCode,
		[TotalCost] = @TotalCost,
		[IPAddress] = @IPAddress,
		[CreatedUserID] = @CreatedUserID,
		[LastModUserID] = @LastModUserID,
		[CreatedDate] = @CreatedDate,
		[LastModDate] = @LastModDate
		WHERE [Id] = @Id
		SET @statusIN = 2
	END
	ELSE
	BEGIN

	DECLARE @DocumentNo NVARCHAR(MAX)
	select @DocumentNo= dbo.FN_GetNextDocumentNumber (@PropertyID,-9999,'R9')

   IF @DocumentNo IS NULL
   BEGIN
	INSERT INTO TransactionTypeWiseNextNumbers
	(PropertyID, LocationID, TransactionType, NextNumber, LengthOfFormatting)
	VALUES (@PropertyID,-9999,'R9',1,6)
   END



    SELECT @DocumentNo= dbo.FN_GetNextDocumentNumber (@PropertyID,-9999,'R9')
    SELECT @DocumentNo
--SELECT * FROM TransactionTypeWiseNextNumbers
   UPDATE TransactionTypeWiseNextNumbers
   SET NextNumber=NextNumber+1
    WHERE locationid=-9999 and transactionType='R9'
	--INSERT THE RECORD
	INSERT INTO RateAnalysisHeaders(
		[Description],
		[RateAnalysisHeaderStatus],
		[ProfitMarginPer],
		[ProfitMarginVal],
		[OverheadCostPer],
		[OverheadCostVal],
		[RateCode],
		[TotalCost],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate]
		)
		VALUES
		(
		@Description,
		@RateAnalysisHeaderStatus,
		@ProfitMarginPer,
		@ProfitMarginVal,
		@OverheadCostPer,
		@OverheadCostVal,
		'R'+@DocumentNo,
		@TotalCost,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate
		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @statusIN = SCOPE_IDENTITY();
	END
	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN
		DELETE [RateAnalysisHeaders] WHERE [Id] = @Id
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

