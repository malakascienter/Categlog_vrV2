
CREATE PROCEDURE [dbo].[InvCashierSpotCheckLog_M_Select] 
@PropertyId INT,
@LocationID INT,
@ShiftDate VARCHAR(10)
AS
BEGIN
	 
	SET NOCOUNT OFF;

	SELECT CashierHeaderID AS SpotCheckNo
	FROM CashierDetail 
	WHERE PropertyId = @PropertyId AND CONVERT(DATE,BussinessDate) = CONVERT(DATE,@ShiftDate,103)  AND LocationID = @LocationID
	GROUP BY CashierHeaderID

END

GO

