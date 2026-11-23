
-- =============================================
-- Author:		Banu
-- ALTER date: 07/02/2016
-- Description:	ALTER a empty dataset for selected outlets
-- =============================================
-----execute Report_DayEndSummary_EmptyDS '001,002,003'
CREATE PROCEDURE [dbo].[Report_DayEndSummary_EmptyDS]
	@Outlet	 VARCHAR(MAX),
	@PropertyId VARCHAR(2)
AS
BEGIN
	SELECT '' AS Expr1, description
	FROM  Location_Ref
	WHERE  (Active = 1) AND code in (select * from STRING_SPLIT(@Outlet,',')) AND PropertyId=@PropertyId
END

GO

