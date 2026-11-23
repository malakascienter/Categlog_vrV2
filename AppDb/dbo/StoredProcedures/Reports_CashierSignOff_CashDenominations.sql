
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[dbo].[Reports_CashierSignOff_CashDenominations]'101','1','2021-04-29'
CREATE PROCEDURE [dbo].[Reports_CashierSignOff_CashDenominations]
	@Outlet		NVARCHAR(3),
	@ShiftNo	NVARCHAR(5),
	@Date		DATETIME

AS
BEGIN
	SELECT	dType As Description,nos As No,value As Amount,sysdate 
	FROM	CashireShiftEndLog
	WHERE	IsCash = 1 
			AND Outlet = @Outlet 
			AND ShiftNo = @ShiftNo 
			--AND CONVERT(DATETIME, sysdate, 121) = CONVERT(DATETIME, @Date, 121) 
			AND CONVERT(DATE, sysdate) = CONVERT(DATE, @Date) 
			AND PayCode = '01'
END

GO

