
CREATE PROCEDURE [dbo].[CashireShiftEndLog_M_Select] 
@PropertyId INT,
@Outlet VARCHAR(3),
@ShiftDate VARCHAR(10)
AS
BEGIN
	 
	SET NOCOUNT OFF;

	SELECT ShiftNo
	FROM [POS_CashireShiftEndLog] 
	WHERE PropertyId = @PropertyId AND ShiftDate = CONVERT(DATETIME,@ShiftDate,103)  AND Outlet = @Outlet
	GROUP BY ShiftNo

END

GO

