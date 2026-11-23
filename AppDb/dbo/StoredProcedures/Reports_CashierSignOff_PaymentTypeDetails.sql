


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[dbo].[Reports_CashierSignOff_PaymentTypeDetails]'101','4','2021-04-29'
CREATE PROCEDURE [dbo].[Reports_CashierSignOff_PaymentTypeDetails]
	@Outlet NVARCHAR(3),
	@ShiftNo  NVARCHAR(5),
	@Date DateTime
	
AS
BEGIN
	SELECT	* 
	FROM	CashierSignOffPaymentDetails
	WHERE	OutletCode = @Outlet
			AND ShiftNo = @ShiftNo 
			AND CONVERT(DATE, SystemDate) = CONVERT(DATE, @Date) 
END

GO

