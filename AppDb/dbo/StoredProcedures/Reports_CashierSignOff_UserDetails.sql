

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[dbo].[Reports_CashierSignOff_UserDetails]'101','1','2021-04-29'
CREATE PROCEDURE [dbo].[Reports_CashierSignOff_UserDetails]
	@Outlet		NVARCHAR(3),
	@ShiftNo	NVARCHAR(5),
	@Date		DATETIME
AS
BEGIN
	SELECT	* 
	FROM	CashierSignOffUserDetails
	WHERE	OutletCode = @Outlet 
			AND ShiftNo = @ShiftNo 
			AND CONVERT(DATE, SystemDate) = CONVERT(DATE, @Date) 
END

GO

