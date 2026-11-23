
-- =============================================
-- Author:		Chamathka Sooriyapala
-- Create date: 2021-06-30
-- Description:	Cashier Shift End Summary Details Save
-- =============================================
CREATE PROCEDURE [dbo].[CashierShiftEnd_M_SaveSignOffSummaryDetail] 
	@ShiftNo				INT,
	@ShiftDate				DATETIME,
	@OutletCode				VARCHAR(100),
	@WorkStation			VARCHAR(100),
	@User					VARCHAR(100),
	@Location				VARCHAR(100),
	@StartingInvoiceNo		VARCHAR(100),
	@EndingInvoiceNo		VARCHAR(100),
	@InvoiceCount			INT,
	@CancelledInvoiceCount	INT,
	@TotalDiscount			DECIMAL(18,4),
	@PropertyId			    INT
AS
BEGIN
	
		
IF NOT EXISTS( select * from [CashierSignOffUserDetails] WHERE CONVERT(DATE,[ShiftDate]) = CONVERT(DATE,@ShiftDate) AND ShiftNo =@ShiftNo AND  OutletCode = @OutletCode AND PropertyId = @PropertyId )
BEGIN

INSERT INTO [dbo].[CashierSignOffUserDetails]([ShiftNo], [ShiftDate], [Location], [Users], [SystemDate], [Station], [StartingInvoiceNo], 
					[EndingInvoiceNo], [InvoiceCount], [CancelInvoiceCount], OutletCode, ReturnExchange, TotalDiscount,PropertyId)
		VALUES		(@ShiftNo, @ShiftDate, @Location, @User, @ShiftDate, @WorkStation, @StartingInvoiceNo, 
					@EndinginvoiceNo, @InvoiceCount, @CancelledInvoiceCount, @OutletCode, 0, @TotalDiscount,@PropertyId) 

END


END

GO

