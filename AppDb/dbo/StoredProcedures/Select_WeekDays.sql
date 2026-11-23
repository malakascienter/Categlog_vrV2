-- =============================================
-- Author:		Chiraj
-- Create date: 2019-9-3
-- Description:	select days
-- =============================================
CREATE PROCEDURE [dbo].[Select_WeekDays] 
	
	
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT * FROM [dbo].[DaysOfWeek] ORDER BY Id 
   
END

GO

