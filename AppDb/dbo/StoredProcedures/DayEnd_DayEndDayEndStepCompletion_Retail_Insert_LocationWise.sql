

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- [DayEnd_DayEndDayEndStepCompletion_Insert]	105,1,'This is test 2',1
CREATE PROCEDURE [dbo].[DayEnd_DayEndDayEndStepCompletion_Retail_Insert_LocationWise]

	@Step			int, 
	@IsCompleted	bit, 
	@Narration		nvarchar(250), 
	@UserId			int,
	@HotelDate		DATE,
	@PropertyId INT,
	@LocationId INT
AS
BEGIN

BEGIN TRY
BEGIN TRANSACTION

	SET NOCOUNT ON;

	DECLARE @DayendValidationMinutes INT
	SELECT @DayendValidationMinutes = DayendValidationMinutes FROM Companies WHERE CompanyID = @PropertyId
	SET @DayendValidationMinutes = @DayendValidationMinutes * -1

	IF EXISTS (SELECT * FROM DayEndDayEndStepCompletion WHERE HotelDate < @HotelDate AND Step = 0 AND DayEndLocation = @LocationId AND PropertyId = @PropertyId AND TxnDateTime >= DATEADD(MINUTE, @DayendValidationMinutes, GETDATE()))
	BEGIN

		
			IF( @Step = 0 )
			BEGIN

			RAISERROR ('Day-end was recently processed. Please wait an 30 minute before trying again.!',16,1) 

			END
   

	END
	
	
	
	DECLARE @Id		INT

	IF NOT EXISTS (SELECT * FROM DayEndDayEndStepCompletion WHERE HotelDate = @HotelDate AND Step = @Step AND PropertyId = @PropertyId AND DayEndLocation = @LocationId)
	BEGIN
		SET @Narration = ISNULL(@Narration + ' - Step Started','N/A')

		INSERT INTO [dbo].[DayEndDayEndStepCompletion]
		(HotelDate, Step, IsCompleted, Narration, UserId,PropertyId,DayEndLocation)
		VALUES
		(@HotelDate, @Step, 0, @Narration, @UserId,@PropertyId,@LocationId)		

		SET @Id = SCOPE_IDENTITY()
		--Begin Audit trail ----------------------------	
		--EXEC HotelResWeb_AuditTail_WriteToLog 'DayEndDayEndStepCompletion',@Id,'FO','DEND1','I',@UserId,@Id
		--End Audit trail ---------------------

		print @Id
	END
 
	IF EXISTS (SELECT * FROM DayEndDayEndStepCompletion WHERE HotelDate = @HotelDate AND Step = @Step AND PropertyId = @PropertyId AND DayEndLocation = @LocationId)
	BEGIN
		print 2

		SET @Narration = ISNULL(@Narration + ' - Step Completed.','N/A')

		UPDATE [dbo].[DayEndDayEndStepCompletion]	
		SET UserId = @UserId,
		Narration = @Narration,
		IsCompleted = @IsCompleted,
		DayEndLocation = @LocationId
		WHERE HotelDate = @HotelDate AND Step = @Step  AND PropertyId = @PropertyId AND DayEndLocation = @LocationId

		SELECT @Id = Id  FROM [DayEndDayEndStepCompletion]	
		WHERE HotelDate = @HotelDate AND Step = @Step AND PropertyId = @PropertyId AND DayEndLocation = @LocationId

		print @Id

		--Begin Audit trail ----------------------------	
		--EXEC HotelResWeb_AuditTail_WriteToLog 'DayEndDayEndStepCompletion',@Id,'FO','DEND2','U',@UserId,@Id
		--End Audit trail ---------------------
	END

COMMIT TRANSACTION 
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	
	DECLARE @ErrorMessage NVARCHAR(4000);  
	DECLARE @ErrorSeverity INT;  
	DECLARE @ErrorState INT;  

	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage,SysDate)
	VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),GETDATE())

	SELECT   
    @ErrorMessage = ERROR_MESSAGE(),  
    @ErrorSeverity = ERROR_SEVERITY(),  
    @ErrorState = ERROR_STATE(); 
	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

END CATCH

END

GO

