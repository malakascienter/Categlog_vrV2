-- =============================================
-- Author:		Ravindu
-- Create date: 2026-03-04
-- Description: Get Total Paid Amount by OrderId
-- =============================================
CREATE   FUNCTION [dbo].[fn_SPO_GetPaidAmount]
(
    @OrderId INT
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @PaidAmount DECIMAL(18, 2);

    SELECT @PaidAmount = ISNULL(SUM(PaymentAmount), 0)
    FROM SPO_OrderWisePayment
    WHERE OrderId = @OrderId;

    RETURN @PaidAmount;
END

GO

