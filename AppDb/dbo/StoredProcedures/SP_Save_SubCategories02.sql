CREATE PROCEDURE[dbo].[SP_Save_SubCategories02]
 --DECLARE PARAMETERS
 
	@Id int,
	@Code nvarchar(max),
	@Description nvarchar(max),
	@IsActive bit,
	@IPAddress nvarchar(max),
	@CreatedUserID int,
	@LastModUserID int,
	@CreatedDate datetime,
	@LastModDate datetime,
	@Action[int],
	@status[int] output,
	@NewId[int] output,
	@SubCategoryId int,
	@CategoryId int,
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
		IF EXISTS(SELECT* FROM SubCategories02 WHERE  [ID] = @Id )
		BEGIN
		EXEC Inventry_AuditTail_WriteToLog 'SubCategories02', @Id, 'INV', 'SUBCU', 'U', @LastModUserID,0, '', ''
		--EXEC InsertMasterFileChangeLog 'Sub Categories 02',@CreatedUserID,'U',@Description
		 --UPDATE THE RECORD
		 UPDATE SubCategories02 SET
		[Code] = @Code,
		[Description] = @Description,
		[IsActive] = @IsActive,
		[IPAddress] = @IPAddress,
		[LastModUserID] = @LastModUserID,
		[LastModDate] = @LastModDate,
		[SubCategoryId] = @SubCategoryId,
		[CategoryId] =@CategoryId
		WHERE [ID] = @Id
		SET @statusIN = 2

		-----------newly added 08.02.2024 
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
	EXEC InsertMasterFileChangeLog 'Sub Categories 02',@CreatedUserID,'I',@Description
	--INSERT THE RECORD
	INSERT INTO SubCategories02(
	
		[Code],
		[Description],
		[IsActive],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate],
		[SubCategoryId],
		[CategoryId]
		
		)
		VALUES
		(
	
		@Code,
		@Description,
		@IsActive,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate,
		@SubCategoryId,
		@CategoryId
		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @NewId = SCOPE_IDENTITY()
		SET @statusIN = 1;
		EXEC Inventry_AuditTail_WriteToLog 'SubCategories02', @NewId, 'INV', 'SUBCI', 'I', @CreatedUserID,0, '', ''
	END

----------newly added 08.02.2024 
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
			SELECT @Id = Id FROM SubCategories02 WHERE Code = @Code   
		------------------------------------------------------
			SELECT * INTO #temptable FROM (
			SELECT DISTINCT SubCategory2ID FROM StockItemHeaders WHERE SubCategory2ID = @Id
			) AS CheckSubCategories2

			IF  NOT EXISTS (SELECT 1 FROM #temptable  WHERE SubCategory2ID = @Id)
			BEGIN
				EXEC Inventry_AuditTail_WriteToLog 'SubCategories02', @Id, 'INV', 'SUBCD', 'D', @CreatedUserID,0, '', ''
				DELETE [SubCategories02] WHERE [Code] = @Code
				
			END
			ELSE
			BEGIN
				RAISERROR('Sub Category 2 exist in transactions',16,1)
				ROLLBACK TRANSACTION
			END
			
			DROP TABLE #temptable
		------------------------------------------------------





		--DELETE [SubCategories02] WHERE [Id] = @Id
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

