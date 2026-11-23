
CREATE FUNCTION  [dbo].[FN_GetWeekStartEndDateStr](@InvDate DATE,@FromDate DATE,@FromTo DATE)
returns  VARCHAR(500)
begin

DECLARE @WeekStartEnd VARCHAR(500)

-- Get the start of the week (Assuming week starts on Sunday)
DECLARE @WeekStart DATE = DATEADD(DAY, -DATEPART(WEEKDAY, @InvDate) + 1, @InvDate), @DayDiff INT = 0


IF( @WeekStart < @FromDate)
BEGIN

 SET @DayDiff = DATEDIFF(DAY, @WeekStart, @FromDate)
 SET @WeekStart = @FromDate

END


-- Get the end of the week (Saturday)
DECLARE @WeekEnd DATE = DATEADD(DAY, 6 - @DayDiff, @WeekStart);

IF( @WeekEnd > @FromTo)
BEGIN

 SET @WeekEnd = @FromTo

END


-- Convert to VARCHAR format
SELECT  @WeekStartEnd = CONVERT(VARCHAR, @WeekStart, 103) + ' to ' + CONVERT(VARCHAR, @WeekEnd, 103) 
SET @WeekStartEnd = CONCAT('(',ISNULL(@WeekStartEnd,''),')')
RETURN ISNULL(@WeekStartEnd,'')

end

GO

