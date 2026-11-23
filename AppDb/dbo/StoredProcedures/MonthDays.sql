

-- =============================================
-- Author:		Banu
-- Create date: 13/11/2018
-- Description:	Create month days
-- =============================================
CREATE PROCEDURE [dbo].[MonthDays]  
AS
BEGIN  
	DECLARE @I INT = 0
	CREATE TABLE #DAYS(
		MONTH_DAYS INT
	)
	WHILE (@I<=31)
	BEGIN
		INSERT INTO #DAYS(MONTH_DAYS)
		SELECT @I
		SET @I = @I + 1
	END  

	SELECT * FROM #DAYS

	DROP TABLE #DAYS
END

GO

