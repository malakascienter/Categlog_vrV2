
CREATE PROCEDURE[dbo].[SP_Save_CustomerSignatures]
 --DECLARE PARAMETERS

	@Id int,
	@CustomerId nvarchar(max),
	@CustomerPerson nvarchar(max),
	@IsFromBasePath nvarchar(max),
	@ImageFileName nvarchar(max),
	@ImageFileFullPath nvarchar(max),
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


--truncate table Customers
--SELECT* FROM Customers WHERE  Code = @Code  and CompanyId = @CompanyId AND LocationId = @LocationId

IF @Action =1
	BEGIN
		IF EXISTS(SELECT* FROM dbo.CustomerSignatures WHERE   Id = @Id)
		BEGIN
		 --UPDATE THE RECORD
		 UPDATE dbo.CustomerSignatures SET
		[CustomerId] = @CustomerId,
		[CustomerPerson] = @CustomerPerson,
		[IsFromBasePath] = @IsFromBasePath,
		[ImageFileName] = @ImageFileName,
		[ImageFileFullPath] = @ImageFileFullPath
		WHERE [Id] = @Id
		SET @statusIN = 2
	END
	ELSE
	BEGIN

	--INSERT THE RECORD
	INSERT INTO dbo.CustomerSignatures
	        ( [CustomerId] ,
	          [CustomerPerson] ,
	          [IsFromBasePath] ,
	          [ImageFileName] ,
	          [ImageFileFullPath]
	        )
	VALUES  ( @CustomerId , -- CustomerId - int
	         @CustomerPerson , -- CustomerPerson - nvarchar(max)
	         @IsFromBasePath , -- IsFromBasePath - bit
	         @ImageFileName , -- ImageFileName - nvarchar(max)
	         @ImageFileFullPath  -- ImageFileFullPath - nvarchar(max)
	        )
		
		SELECT SCOPE_IDENTITY() AS ID
		SET @NewId = SCOPE_IDENTITY()
		SET @statusIN = 1;
	END
	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN
		DELETE dbo.CustomerSignatures WHERE [Id] = @Id
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

