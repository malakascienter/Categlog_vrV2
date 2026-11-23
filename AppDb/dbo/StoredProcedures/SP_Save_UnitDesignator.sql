CREATE PROCEDURE[dbo].[SP_Save_UnitDesignator]
 --DECLARE PARAMETERS

	@Id int,
	@CompanyID INT,
	@UnitID int,
	@Name nvarchar(50),
	@Rate decimal,	
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
		IF EXISTS(SELECT* FROM UnitDesignators WHERE  [Id] = @Id)
		BEGIN
		EXEC Inventry_AuditTail_WriteToLog 'UnitDesignators', @Id, 'INV', 'UTDU', 'U', @LastModUserID,@CompanyID, '', ''
		 --UPDATE THE RECORD
		 UPDATE UnitDesignators SET
		[CompanyID] = @CompanyID,
		[UnitID] = @UnitID,
		[Name] = @Name,
		[Rate] = @Rate,
		[IPAddress] = @IPAddress,
		[LastModUserID] = @LastModUserID,
		[LastModDate] = @LastModDate
		
		WHERE [Id] = @Id
		SET @statusIN = 2

		---------newly added 07.02.2024 
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
	--INSERT THE RECORD
	INSERT INTO UnitDesignators(
		[CompanyID] ,
		[UnitID],
		[Name],
		[Rate],		
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate]
		
		)
		VALUES
		(
		@CompanyID,
		@UnitID,
		@Name,
		@Rate,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate

		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @NewId = SCOPE_IDENTITY()
		SET @statusIN = 1;
		EXEC Inventry_AuditTail_WriteToLog 'UnitDesignators', @NewId, 'INV', 'UTDI', 'I', @CreatedUserID,@CompanyID, '', ''
		
	END

-------newly added 24.01.2024 
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
	if exists( select 1 from [UnitDesignators] WHERE [Id] = @Id)
	begin 
	EXEC Inventry_AuditTail_WriteToLog 'UnitDesignators', @Id, 'INV', 'UTDD', 'D', @CreatedUserID,@CompanyID, '', ''
		DELETE [UnitDesignators] WHERE [Id] = @Id
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
--SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
SET @Message = 'Error Occured: ' + ERROR_MESSAGE() 
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH
END--SP ENDS

GO

