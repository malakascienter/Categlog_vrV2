
CREATE PROCEDURE [dbo].[SpotCheckLog_M_Select] 
@PropertyId INT,
@Outlet VARCHAR(3),
@ShiftDate VARCHAR(10)
AS
BEGIN
	 
	SET NOCOUNT OFF;

	SELECT SpotCheckNo
	FROM [POS_SpotCheckLog] 
	WHERE PropertyId = @PropertyId AND ShiftDate = CONVERT(DATETIME,@ShiftDate,103)  AND Outlet = @Outlet
	GROUP BY SpotCheckNo

END

GO

