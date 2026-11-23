--EXEC  [SpotCheckLog_M_Select_FirstApproval] 1,'300','27/08/2024',1
CREATE PROCEDURE [dbo].[CashireShiftEndLog_M_Select_FirstApproval] 
@PropertyId INT,
@Outlet VARCHAR(3),
@ShiftDate VARCHAR(10),
@ShiftNo VARCHAR(10)
AS
BEGIN
	 
	SET NOCOUNT OFF;

	SELECT MAX(ID)  AS ID, 'CASH' AS NoteType,MAX(SystemAmount) AS SystemAmount,SUM(Value) as PhysicalAmount,SUM(Value)- MAX(SystemAmount) as DiffAmount
	FROM [POS_CashireShiftEndLog] 
	WHERE PropertyId = @PropertyId AND ShiftDate = CONVERT(DATETIME,@ShiftDate,103) AND Outlet = @Outlet 
	AND ShiftNo = @ShiftNo AND IsFirstApproval = 0 AND IsSecondApproval = 0 AND IsCash = 1 
	HAVING MAX(SystemAmount) <> SUM(Value)

	UNION ALL

	SELECT ID, DType AS NoteType,SystemAmount,Value as PhysicalAmount,Value- SystemAmount as DiffAmount
	FROM [POS_CashireShiftEndLog] 
	WHERE PropertyId = @PropertyId AND ShiftDate = CONVERT(DATETIME,@ShiftDate,103) AND Outlet = @Outlet 
	AND ShiftNo = @ShiftNo AND IsFirstApproval = 0 AND IsSecondApproval = 0 AND IsCash = 0 AND SystemAmount <> Value

	

	


END

GO

