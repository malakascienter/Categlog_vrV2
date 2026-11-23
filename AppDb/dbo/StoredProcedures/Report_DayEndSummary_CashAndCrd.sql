
-- =============================================
-- Author:		Banu
-- ALTER date: 07/02/2016
-- Description:	ALTER a empty dataset for selected outlets
-- =============================================
-----execute Report_DayEndSummary_CashAndCrd '001,002,003','01/01/2019'
CREATE PROCEDURE [dbo].[Report_DayEndSummary_CashAndCrd]
	@Outlet		VARCHAR(MAX),
	@FromDate	VARCHAR(30),
	@PropertyId VARCHAR(2)
AS
BEGIN
	SELECT DE.Date1, SUM(DE.Amount) AS 'TotAmount', DE.Cash, 
			DE.Outlet, L.description AS 'OutletDes'
	FROM 
	DayeEndSummaryDetail DE 
	INNER JOIN Location_Ref L ON DE.Outlet = L.code AND L.PropertyId=DE.PropertyId
	WHERE
	DE.Date1 = CONVERT(DATETIME,@FromDate, 103) 
	AND DE.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
	AND DE.PropertyId=@PropertyId
	GROUP BY DE.Date1, DE.Cash,DE.Outlet,L.description
END

GO

