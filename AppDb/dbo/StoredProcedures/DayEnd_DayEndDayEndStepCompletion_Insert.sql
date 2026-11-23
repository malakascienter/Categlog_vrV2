

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- [DayEnd_DayEndDayEndStepCompletion_Insert]	105,1,'This is test 2',1
CREATE PROCEDURE [dbo].[DayEnd_DayEndDayEndStepCompletion_Insert]

	@Step			int, 
	@IsCompleted	bit, 
	@Narration		nvarchar(250), 
	@UserId			int,
	@HotelDate		DATE,
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @Id		INT

	IF NOT EXISTS (SELECT * FROM DayEndDayEndStepCompletion WHERE HotelDate = @HotelDate AND Step = @Step AND PropertyId = @PropertyId)
	BEGIN
		SET @Narration = ISNULL(@Narration + ' - Step Started','N/A')

		INSERT INTO [dbo].[DayEndDayEndStepCompletion]
		(HotelDate, Step, IsCompleted, Narration, UserId,PropertyId)
		VALUES
		(@HotelDate, @Step, 0, @Narration, @UserId,@PropertyId)		

		SET @Id = SCOPE_IDENTITY()
		--Begin Audit trail ----------------------------	
		--EXEC HotelResWeb_AuditTail_WriteToLog 'DayEndDayEndStepCompletion',@Id,'FO','DEND1','I',@UserId,@Id
		--End Audit trail ---------------------

		print @Id
	END
 
	IF EXISTS (SELECT * FROM DayEndDayEndStepCompletion WHERE HotelDate = @HotelDate AND Step = @Step AND PropertyId = @PropertyId)
	BEGIN
		print 2

		SET @Narration = ISNULL(@Narration + ' - Step Completed.','N/A')

		UPDATE [dbo].[DayEndDayEndStepCompletion]	
		SET UserId = @UserId,
		Narration = @Narration,
		IsCompleted = @IsCompleted
		WHERE HotelDate = @HotelDate AND Step = @Step  AND PropertyId = @PropertyId

		SELECT @Id = Id  FROM [DayEndDayEndStepCompletion]	
		WHERE HotelDate = @HotelDate AND Step = @Step AND PropertyId = @PropertyId

		print @Id

		--Begin Audit trail ----------------------------	
		--EXEC HotelResWeb_AuditTail_WriteToLog 'DayEndDayEndStepCompletion',@Id,'FO','DEND2','U',@UserId,@Id
		--End Audit trail ---------------------
	END

END

GO

