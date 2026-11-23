/*** ***************************************************************************************************** ****/
-- This procedure was Auto Genarated By A tool created by S.G. Asanga Chandrakumara
-- ON12/14/2017 10:55:43 AM
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
CREATE PROCEDURE[dbo].[SP_Save_Companies]
 --DECLARE PARAMETERS

	@CompanyID int,
	@GroupofcompanyID int,
	@Code nvarchar(10),
	@Name nvarchar(100),
	@IsActive bit,
	@OtherBusinessName1 nvarchar(100),
	@Address1 nvarchar(50),
	@Address2 nvarchar(100),
	@Address3 nvarchar(100),
	@Telephone1 nvarchar(15),
	@Telephone2 nvarchar(15),
	@Mobile nvarchar(15),
	@FaxNo nvarchar(15),
	@Email nvarchar(255),
	@WebAddress nvarchar(max),
	@ContactPerson nvarchar(50),
	@TaxID1 int,
	@TaxID2 int,
	@TaxID3 int,
	@TaxRegistrationNumber1 nvarchar(max),
	@TaxRegistrationNumber2 nvarchar(max),
	@TaxRegistrationNumber3 nvarchar(max),
	@StartOfFiscalYear int,
	@CostingMethod nvarchar(20),
	@IsVat bit,
	@IsTaxOrSellPrice bit,
	@IsFirstOne bit,
	@IsSettlementSeparate bit,
	@NativeCurrency int,
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
	SET  @statusIN = 0;
	SET  @NewId =0
	SET  @message = ''
	SET  @IsTaxOrSellPrice=0
	SET  @IsFirstOne =0
	SET  @IsSettlementSeparate =0
	
BEGIN
BEGIN TRY
	BEGIN TRANSACTION



IF @Action =1
	BEGIN
		IF EXISTS(SELECT* FROM Companies WHERE  [CompanyID] = @CompanyID)
		BEGIN

		EXEC InsertMasterFileChangeLog 'Company',@CreatedUserID,'U',@Name
		 --UPDATE THE RECORD
		 UPDATE Companies SET
		[GroupofcompanyID] = @GroupofcompanyID,
		[Code] = @Code,
		[Name] = @Name,
		[IsActive] = @IsActive,
		[OtherBusinessName1] = @OtherBusinessName1,
		[Address1] = @Address1,
		[Address2] = @Address2,
		[Address3] = @Address3,
		[Telephone1] = @Telephone1,
		[Telephone2] = @Telephone2,
		[Mobile] = @Mobile,
		[FaxNo] = @FaxNo,
		[Email] = @Email,
		[WebAddress] = @WebAddress,
		[ContactPerson] = @ContactPerson,
		[TaxID1] = @TaxID1,
		[TaxID2] = @TaxID2,
		[TaxID3] = @TaxID3,
		[TaxRegistrationNumber1] = @TaxRegistrationNumber1,
		[TaxRegistrationNumber2] = @TaxRegistrationNumber2,
		[TaxRegistrationNumber3] = @TaxRegistrationNumber3,
		[StartOfFiscalYear] = @StartOfFiscalYear,
		[CostingMethod] = @CostingMethod,
		[IsVat] = @IsVat,
		[IsTaxOrSellPrice]=  @IsTaxOrSellPrice,
		[IsFirstOne] = @IsFirstOne,
	    [IsSettlementSeparate] = @IsSettlementSeparate,
		[NativeCurrency] = @NativeCurrency,
		[IPAddress] = @IPAddress,
		[LastModUserID] = @LastModUserID,
		[LastModDate] = @LastModDate
		WHERE [CompanyID] = @CompanyID
		SET @statusIN = 2
	END
	ELSE
	BEGIN
	EXEC InsertMasterFileChangeLog 'Company',@CreatedUserID,'I',@Name
	--INSERT THE RECORD
	INSERT INTO Companies(
		[GroupofcompanyID],
		[Code],
		[Name],
		[IsActive],
		[OtherBusinessName1],
		[Address1],
		[Address2],
		[Address3],
		[Telephone1],
		[Telephone2],
		[Mobile],
		[FaxNo],
		[Email],
		[WebAddress],
		[ContactPerson],
		[TaxID1],
		[TaxID2],
		[TaxID3],
		[TaxRegistrationNumber1],
		[TaxRegistrationNumber2],
		[TaxRegistrationNumber3],
		[StartOfFiscalYear],
		[CostingMethod],
		[IsVat],
		[IsTaxOrSellPrice],
		[IsFirstOne],
	    [IsSettlementSeparate],
		[NativeCurrency],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate]
		)
		VALUES
		(
		@GroupofcompanyID,
		@Code,
		@Name,
		@IsActive,
		@OtherBusinessName1,
		@Address1,
		@Address2,
		@Address3,
		@Telephone1,
		@Telephone2,
		@Mobile,
		@FaxNo,
		@Email,
		@WebAddress,
		@ContactPerson,
		@TaxID1,
		@TaxID2,
		@TaxID3,
		@TaxRegistrationNumber1,
		@TaxRegistrationNumber2,
		@TaxRegistrationNumber3,
		@StartOfFiscalYear,
		@CostingMethod,
		@IsVat,
		@IsTaxOrSellPrice,
		@IsFirstOne,
	    @IsSettlementSeparate,
		@NativeCurrency,
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
		EXEC InsertMasterFileChangeLog 'Company',@CreatedUserID,'D',@Name
		DELETE [Companies] WHERE [CompanyID] = @CompanyID
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

