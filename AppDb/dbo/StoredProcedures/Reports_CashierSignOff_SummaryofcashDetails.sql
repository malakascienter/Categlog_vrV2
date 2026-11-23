

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[dbo].[Reports_CashierSignOff_SummaryofcashDetails]'101','12','2021-07-16'
CREATE PROCEDURE [dbo].[Reports_CashierSignOff_SummaryofcashDetails]
	@Outlet		NVARCHAR(3),
	@ShiftNo	NVARCHAR(5),
	@Date		DATETIME
	
AS
BEGIN

	DECLARE @CalculatedCashAmount	MONEY, 
			@PhysicalAmount			MONEY,
			@TotCashSale			MONEY,
			@Variance				MONEY,
			@OpeningBalance			MONEY,
			@TotCashReceipts		MONEY,
			@Withrawals				MONEY,
			@CashierSignOnDateTime	DATETIME,
			@CashierName			VARCHAR(100),
			@SignOffAuthorizedUser	VARCHAR(20)

	SET @TotCashSale = (SELECT SystemAmount FROM CashierSignOffPaymentTypesWiseSystemAmounts WHERE ShiftID = @ShiftNo AND CONVERT(DATE, ShiftDate) = CONVERT(DATE, @Date) AND Outlet = @Outlet AND PayCode = '01')

	SET @PhysicalAmount = (SELECT SUM(value) FROM CashireShiftEndLog  WHERE ShiftNo = @ShiftNo AND CONVERT(DATE, sysdate) = CONVERT(DATE, @Date) AND Outlet = @Outlet AND IsCash = 1)

	SELECT	@OpeningBalance = OpeningBalance, 
			@TotCashReceipts = TotCashReceipts, 
			@Withrawals = Withrawals, 
			@CashierSignOnDateTime = CashierSignOnDateTime,
			@SignOffAuthorizedUser = CashierSignOffAuthorizedUser
	FROM	CashierSignOffSummaryDetails
	WHERE	OutletCode = @Outlet AND ShiftNo = @ShiftNo AND CONVERT(DATETIME, SystemDate, 121) =  CONVERT(DATETIME, @Date, 121) 

	SET @CalculatedCashAmount = (@OpeningBalance + @TotCashSale + @TotCashReceipts - @Withrawals) 
	SET @Variance = (@PhysicalAmount - @CalculatedCashAmount)

	SELECT	@ShiftNo AS ShiftNo, @Outlet AS OutletCode, @OpeningBalance AS OpeningBalance, @TotCashReceipts AS TotCashReceipts, @TotCashSale AS TotCashSale, @CashierSignOnDateTime AS CashierSignOnDateTime,
			@Withrawals AS Withrawals, @CalculatedCashAmount AS CalculatedCashAmount, @Variance AS Variance, @PhysicalAmount AS PhysicalAmount, @Date AS SystemDate, @SignOffAuthorizedUser AS SignOffAuthorizedUser
END

GO

