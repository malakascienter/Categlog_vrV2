
-- =============================================
-- Author:		Chiraj
-- ALTER date: 2018-12-05
-- Description:	Day end summary report
-- =============================================
-----EXECUTE Report_Day_End_Summary '01/02/2019','001,002,003,004,005,013,017'
CREATE PROCEDURE [dbo].[Report_Day_End_Summary] 
	@FromDate VARCHAR(10),
	@Outlet VARCHAR(MAX),
	@PropertyId VARCHAR(2)
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT DE.Date1, DE.PayType, DE.No1, DE.Amount, DE.Cash, DE.seq, 
			DE.Outlet, DE.Upload, DE.EmpCode, L.description AS 'OutletDes'
	FROM DayeEndSummaryDetail DE 
	INNER JOIN Location_Ref L ON DE.Outlet = L.code AND L.PropertyId=DE.PropertyId
	WHERE 
	Date1 = CONVERT(DATETIME,@FromDate, 103) AND 
	Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,',')) 
		AND DE.PropertyId=@PropertyId
	ORDER BY seq
    --EXEC Repoprt_viewing_Count_By_User 'Report_Day_End_Summary','1'
END

GO

