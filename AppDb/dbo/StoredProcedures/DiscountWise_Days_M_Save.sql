-- =============================================
-- Author		:	Chiraj
-- Create date	:	2019-9-3
-- Description	:	Save date by given dates
-- =============================================
 CREATE PROCEDURE [dbo].[DiscountWise_Days_M_Save] 
	
	@FromDate	DATETIME,	
	@ToDate		DATETIME,  
	@DatesJson  NVARCHAR(MAX),
	@DiscountId INT
	

AS
BEGIN
	DECLARE @availableDates TABLE([Day] NVARCHAR(10))
	INSERT INTO @availableDates([Day])
	SELECT * FROM 
	OPENJSON(@DatesJson)
	WITH
	(
	    [date] varchar(200) '$.Id' 
	)

;WITH cte_Recursion AS

(
  SELECT @FromDate AS [Date]
  UNION ALL
  SELECT DATEADD(DAY, 1, [Date])
  FROM cte_Recursion
  WHERE [Date] < @ToDate
)
--SELECT * FROM cte_Recursion


INSERT INTO [dbo].[DiscountWiseDates]([DiscountId],[Date],[DayName],DayId)
SELECT @DiscountId,[Date],DATENAME(DW,[Date]),DATEPART(WEEKDAY, [Date])
FROM cte_Recursion
WHERE DATEPART(WEEKDAY, [Date]) in (select * from @availableDates) 
OPTION (MAXRECURSION 0) -- MaxRecursion 0 is needed when dates are more than 100 days apart
END

GO

