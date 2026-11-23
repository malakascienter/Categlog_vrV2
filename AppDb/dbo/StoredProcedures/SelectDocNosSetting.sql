--EXEC SelectDocNosSetting 'OPOSBE'
CREATE PROCEDURE [dbo].[SelectDocNosSetting]
(
	@Code				VARCHAR(6)
)
AS
BEGIN	  
    DECLARE @sErrorProcedure	VARCHAR(200),
			@sLog				VARCHAR(500),
			@sErrorMessage		VARCHAR(500),
			@MsgText			VARCHAR(1000),
			@Validation			VARCHAR(1000),	
			@IsValidation		BIT

	DECLARE @Prefix				VARCHAR(6),			 
			@NextNo				BIGINT,
			@SerialLength		INT,
			@SerialNumber		VARCHAR(20)
	
	DECLARE @UniqueOrderNo	VARCHAR(10)
	DECLARE @Prefix1 VARCHAR(5)
	DECLARE	@Prefix2 VARCHAR(5)
	DECLARE @NextNoChk	BIGINT
	DECLARE @DocNosSetting TABLE (SettingID INT,Code VARCHAR(6), Description VARCHAR(250), Value VARCHAR(200), NextNo BIGINT, PossibleValues VARCHAR(40), Prefix VARCHAR(5), SerialLength INT,SerialNumber VARCHAR(20))
	
    BEGIN TRY			
		
		SET @IsValidation=0

		IF ISNULL(@Code,'')=''
		BEGIN
			IF NOT EXISTS ( SELECT 1 FROM dbo.[DocNosSetting] WHERE Code=@Code)
			BEGIN
				SET @IsValidation=1
				SET @Validation='Setting was not found!'
				RAISERROR (50005,16,1)
				RETURN 0;
			END
		END
		
		SELECT  @Prefix=Prefix,
				@SerialLength=SerialLength,
				@NextNo=NextNo
		FROM dbo.[DocNosSetting]
		WHERE Code = @Code

		IF ISNULL(@Prefix,'')<>''
			SELECT @SerialNumber=ISNULL(@Prefix,'') + RIGHT('000000000000000000' + CAST(ISNULL(@NextNo, 0) AS VARCHAR(10)),@SerialLength-LEN(@Prefix))
		ELSE
			SELECT @SerialNumber=RIGHT('000000000000000000' + CAST(ISNULL(@NextNo,0) AS VARCHAR(10)),@SerialLength)

		IF ISNULL(@SerialNumber,'')<>''
		BEGIN
			UPDATE dbo.[DocNosSetting]
			SET [NextNo] = [NextNo] + 1
			WHERE Code = @Code	
		END 
		INSERT INTO @DocNosSetting(SettingID, Code, Description, Value, NextNo, PossibleValues, Prefix, SerialLength,SerialNumber)
		SELECT	SettingID,
				Code,
				Description,
				Value,
				NextNo,
				PossibleValues,
				Prefix,
				SerialLength,
				@SerialNumber AS SerialNumber
		FROM dbo.[DocNosSetting]
		WHERE Code = CASE ISNULL(@Code,'') WHEN '' THEN Code ELSE @Code END


		SELECT @UniqueOrderNo = SerialNumber,
		   @Prefix1 = SUBSTRING(Prefix,1,1),
		   @Prefix2 = SUBSTRING(Prefix,2,1),
		   @NextNoChk = NextNo
	FROM @DocNosSetting

	IF @NextNoChk > 9999
	BEGIN
		IF @Prefix2 = 'Z'
		BEGIN						
			SET @Prefix1 = CHAR(ASCII(@Prefix1) + 1)
			SET @Prefix2 = 'A'

			UPDATE DocNosSetting
			SET Prefix = @Prefix1+@Prefix2,
				NextNo = 1
			WHERE Code = @Code
		END
		ELSE
		BEGIN
			SET @Prefix2 = CHAR(ASCII(@Prefix2) + 1)						

			UPDATE DocNosSetting
			SET Prefix = @Prefix1+@Prefix2,
				NextNo = 1
			WHERE Code = @Code
		END
	END



		SELECT * FROM @DocNosSetting

		RETURN 1
	END TRY
	BEGIN CATCH		
		
		DECLARE @iErrorNumber INT

		SELECT	@sErrorProcedure=ERROR_PROCEDURE()
		SELECT	@sErrorMessage=ERROR_MESSAGE()
		SELECT	@iErrorNumber=ERROR_NUMBER()

		IF @IsValidation=1
			RAISERROR (50005,16,1)
		ELSE
			RAISERROR (@sErrorMessage,16,1)
		
		SELECT * 
		FROM sys.messages
		WHERE message_id=50005

		EXEC sp_dropmessage 50005;	

		RETURN 0
  
    END CATCH  
END

GO

