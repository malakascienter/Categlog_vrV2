-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- [dbo].[DayEnd_DayEndDayEndStepCompletion_Check] '2020-07-27',1
CREATE PROCEDURE [dbo].[DayEnd_DayEndDayEndStepCompletion_Retail_Check_LocationWise]
	@HotelDate		DATE,
	@Step			int,
	@PropertyId INT,
	@LocationId INT
AS
BEGIN
	
	SET NOCOUNT ON;



	SELECT * 
	INTO #DayEndDayEndStepCompletion
	FROM DayEndDayEndStepCompletion 
	WHERE HotelDate = @HotelDate AND Step = @Step AND PropertyId = @PropertyId AND DayEndLocation = @LocationId

	

	IF NOT EXISTS (	SELECT * FROM #DayEndDayEndStepCompletion)
	BEGIN 
		SELECT 
		0 AS Id, 
		@HotelDate AS 'HotelDate', 
		@Step AS 'Step', 
		0 AS  'IsCompleted', 
		'' AS 'Narration', 
		GETDATE() AS  'TxnDateTime', 
		0 AS 'UserId',
		'' AS 'DayEndOutlet',
		0 AS 'PropertyId'

	END
	ELSE 
	BEGIN
		SELECT * FROM #DayEndDayEndStepCompletion
	END


	DROP TABLE #DayEndDayEndStepCompletion
	

END

GO

