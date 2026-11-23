CREATE PROCEDURE [dbo].[SP_Save_AltGroups]  --20,'G005','qqqqq','192.168.0.0',1,1,'2018-04-24','2018-04-25',1,1,1

						@Id int ,
						@GropCOde varchar(max),
						@GropName varchar(max),
						@IPAddress varchar(max),
						@CreatedUserID int,
						@LastModUserID int,
						@CreatedDate datetime,
						@LastModDate datetime,
						@PropertyID int,
						@LocationID int,
						@DepartmentID int,
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
	BEGIN
		IF EXISTS(SELECT* FROM AltItemGroups WHERE  [Id] = @Id)
		BEGIN

		EXEC Inventry_AuditTail_WriteToLog 'AltItemGroups', @Id, 'INV', 'AIGU', 'U', @LastModUserID,@PropertyID, '', ''
						----newly added 06.02.2024 
			IF(@LastModUserID = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END
		 --UPDATE THE RECORD
		 UPDATE AltItemGroups SET
		[GropCOde] = @GropCOde,
		[GropName] = @GropName,
		[IPAddress] = @IPAddress,
		[LastModUserID] = @LastModUserID,
		[LastModDate] = @LastModDate
		WHERE [Id] = @Id
		SET @statusIN = 2
	END
	ELSE
	BEGIN
	--INSERT THE RECORD
	INSERT INTO AltItemGroups(
		[GropCOde],
		[GropName],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate],
		[LocationID],
		[PropertyID],
		[DepartmentID]

		)
		VALUES
		(
		@GropCOde,
		@GropName,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		GETDATE(),
		GETDATE(),
		@LocationID,
		@PropertyID,
		@DepartmentID

		)
----------------------- 12.02.2024-----------------------------------------
		IF(@CreatedUserID = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END
----------------------------------------------------------------------------
		SELECT SCOPE_IDENTITY() AS Id
		SET @NewId = SCOPE_IDENTITY()
		SET @statusIN = 1;
		EXEC Inventry_AuditTail_WriteToLog 'AltItemGroups', @NewId, 'INV', 'AIGI', 'I', @CreatedUserID,@PropertyID, '', ''
	END
	END
	
	COMMIT TRAN -- Transaction Success!
	SET @status = @statusIN
END TRY
BEGIN CATCH
	SET @status = -1;
--SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))

set @message = 'Error Occured: '+ ERROR_MESSAGE();
Raiserror(@message,16,1)
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH
END

GO

