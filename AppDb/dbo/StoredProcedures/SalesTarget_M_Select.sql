-- =============================================
-- Author:		Chiraj
-- Create date: 2020-05-16
-- Description:	Save Item Breakown
-- =============================================
CREATE PROCEDURE [dbo].[SalesTarget_M_Select]
	@SalesTargetJson NVARCHAR(MAX),
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT * INTO #TempSalesTarget 
	FROM OPENJSON(@SalesTargetJson)
	WITH
	(
			Outlet VARCHAR(5) '$.Outlet',
			MonthNo VARCHAR(5)'$.MonthNo',
			YearNo VARCHAR(5)'$.YearNo',
			MonthYear VARCHAR(15)'$.MonthYear',
			SalesTarget MONEY'$.SalesTarget'
	)

	DECLARE @Outlet VARCHAR(5),@MonthNo VARCHAR(5),@YearNo VARCHAR(5)
	SELECT TOP(1) @Outlet = Outlet,@MonthNo = MonthNo,@YearNo = YearNo  FROM #TempSalesTarget

	SELECT o.*,L.description OutletName  FROM POS_SalesTarget  o inner join Location_Ref L ON o.Outlet = L.code AND o.PropertyId = L.PropertyId
	WHERE O.PropertyId = @PropertyId AND --Outlet = @Outlet AND 
	MonthNo = ISNULL(@MonthNo,MonthNo) AND YearNo = ISNULL(@YearNo,YearNo)

END

GO

