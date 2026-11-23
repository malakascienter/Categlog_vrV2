-- =============================================
-- Author:		Ravindu 
-- Create date: 2026-02-27
-- Description:	Calculated Balance qty in SPO
-- =============================================
CREATE   FUNCTION [dbo].[fn_GetBalanceAmount]
(
    @OrderId INT 
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @OrderTotalAmount DECIMAL(18, 2)
    DECLARE @TotalPaid        DECIMAL(18, 2)
    DECLARE @BalanceQty       DECIMAL(18, 2)

    SELECT @OrderTotalAmount = TotalAmount
    FROM SPO_OrderHeader
    WHERE OrderId = @OrderId

    -- Get Sum of Payments from Payments table
    SELECT @TotalPaid = ISNULL(SUM(PaymentAmount), 0)
    FROM SPO_OrderWisePayment
    WHERE OrderId = @OrderId

    SET @BalanceQty = ISNULL(@OrderTotalAmount, 0) - @TotalPaid

    RETURN @BalanceQty
END

GO

