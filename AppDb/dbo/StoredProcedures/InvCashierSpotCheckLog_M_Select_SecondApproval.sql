--EXEC  [SpotCheckLog_M_Select_FirstApproval] 1,'300','27/08/2024',1
CREATE PROCEDURE [dbo].[InvCashierSpotCheckLog_M_Select_SecondApproval] 
@PropertyId INT,
@LocationID INT,
@ShiftDate VARCHAR(10),
@SpotCheckNo INT
AS
BEGIN
	 
	SET NOCOUNT OFF;

	SELECT MAX(CashierHeaderID)  AS ID, 'CASH' AS NoteType,MAX(SystemAmout) AS SystemAmount,SUM(Value) as PhysicalAmount,SUM(Value)- MAX(SystemAmout) as DiffAmount,FirstApprovalRemark
	FROM CashierDetail 
	WHERE PropertyId = @PropertyId AND CONVERT(DATE,BussinessDate) = CONVERT(DATE,@ShiftDate,103) AND LocationID = @LocationID 
	AND CashierHeaderID = @SpotCheckNo AND IsFirstApproval = 1 AND IsSecondApproval = 0 
	GROUP BY FirstApprovalRemark
	HAVING MAX(SystemAmout) <> SUM(Value)

	

END

GO

