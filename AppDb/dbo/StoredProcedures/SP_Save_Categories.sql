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

--select * from Categories

CREATE PROCEDURE[dbo].[SP_Save_Categories]
 --DECLARE PARAMETERS

	@Id int,
	@PrefixLength int,
	@Prefix nvarchar(max),
	@SuffixLength int,
	@Suffix nvarchar(max),
	@SerialLength int,
	@Serial nvarchar(max),
	@CodeLength int,
	@DepartmentId int,
	@Code nvarchar(max),
	@Name nvarchar(max),
	@PurchaseAccountID nvarchar(max),
	@CostOfSalesAccountID nvarchar(max),
	@IsActive bit,
	@IPAddress nvarchar(max),
	@CreatedUserID int,
	@LastModUserID int,
	@CreatedDate datetime,
	@LastModDate datetime,
	@CompanyId int,
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
		IF EXISTS(SELECT* FROM Categories WHERE  [Id] = @Id )--and CompanyId = @CompanyId) Commented by Isuru 2024-02-27
		
		BEGIN
		EXEC Inventry_AuditTail_WriteToLog 'Categories', @Id, 'INV', 'CAU', 'U', @LastModUserID,@CompanyId, '', ''
		EXEC InsertMasterFileChangeLog 'Categories',@CreatedUserID,'U',@Name
		 --UPDATE THE RECORD
		 UPDATE Categories SET
		[DepartmentId] = @DepartmentId,
		[Code] = @Code,
		[Name] = @Name,
		[PurchaseAccountID] = @PurchaseAccountID,
		[CostOfSalesAccountID] = @CostOfSalesAccountID,
		[IsActive] = @IsActive,
		[IPAddress] = @IPAddress,
		[LastModUserID] = @LastModUserID,
		[LastModDate] = @LastModDate,
		--[CompanyId] = @CompanyId,
		[PrefixLength] = @PrefixLength,
		[Prefix]	= @Prefix ,
		[SuffixLength]	=	@SuffixLength,
		[Suffix]	=	@Suffix ,
		[SerialLength]	=@SerialLength ,
		[Serial]	=	@Serial ,
		[CodeLength] =	@CodeLength 
		WHERE [Id] = @Id
		SET @statusIN = 2
	END
	ELSE
	BEGIN
	EXEC InsertMasterFileChangeLog 'Categories',@CreatedUserID,'I',@Name
	--INSERT THE RECORD
	INSERT INTO Categories(
		[DepartmentId],
		[Code],
		[Name],
		[PurchaseAccountID],
		[CostOfSalesAccountID],
		[IsActive],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate],
		[CompanyId],
		[PrefixLength] ,
		[Prefix]	,	
		[SuffixLength],	
		[Suffix]	,
		[SerialLength],	
		[Serial]	,
		[CodeLength] 	
		)
		VALUES
		(
		@DepartmentId,
		@Code,
		@Name,
		@PurchaseAccountID,
		@CostOfSalesAccountID,
		@IsActive,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate,
		@CompanyId,
		@PrefixLength,
		@Prefix ,
		@SuffixLength,
		@Suffix ,
		@SerialLength ,
		@Serial ,
		@CodeLength 
		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @NewId = SCOPE_IDENTITY()
		SET @statusIN = 1;
		EXEC Inventry_AuditTail_WriteToLog 'Categories', @NewId, 'INV', 'CAI', 'I', @CreatedUserID,@CompanyId, '', ''
	END
	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN
	-- 21.02.2024 - vinuki 
			SELECT @Id = Id FROM Categories WHERE Code = @Code   
		------------------------------------------------------
			SELECT * INTO #temptable FROM (
			SELECT DISTINCT CategoryID 
			FROM StockItemHeaders WHERE CategoryID = @Id
			union
			select CategoryId
			from SubCategories WHERE CategoryId = @Id
			) AS CheckCategories

			IF  NOT EXISTS (SELECT 1 FROM #temptable  WHERE CategoryID = @Id)
			BEGIN
				EXEC Inventry_AuditTail_WriteToLog 'Categories', @Id, 'INV', 'CAD', 'D', @CreatedUserID,@CompanyId, '', ''
				DELETE [Categories] WHERE [code] = @Code
				
			END
			ELSE
			BEGIN
				RAISERROR('Category exist in transactions',16,1)
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
	COMMIT TRAN -- Transaction Success!
	SET @status = @statusIN
END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

	END CATCH
	
END--SP ENDS

GO

