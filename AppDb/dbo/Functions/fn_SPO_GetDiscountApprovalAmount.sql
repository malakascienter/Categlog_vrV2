-- =============================================
-- Author:		Ravindu 
-- Create date: 2026-03-04
-- Description:	Get Discount Approval and non approval details
-- =============================================
CREATE   FUNCTION [dbo].[fn_SPO_GetDiscountApprovalAmount]
(
    @OrderId    INT,
    @IsApproved BIT
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @HeaderDiscount  DECIMAL(18, 2) = 0
    DECLARE @DetailsDiscount DECIMAL(18, 2) = 0
    DECLARE @TotalDiscount   DECIMAL(18, 2) = 0

    IF(@IsApproved = 1)
    BEGIN
        --SELECT @HeaderDiscount = ISNULL(Discount, 0) 
        --FROM SPO_OrderHeader 
        --WHERE OrderId = @OrderId AND IsDiscount = 1

        SELECT @DetailsDiscount = ISNULL(SUM(Discount), 0) 
        FROM SPO_OrderDetails 
        WHERE OrderId = @OrderId AND IsDiscountApprove = 1 AND DiscountStatus = 'C'
    END

    IF(@IsApproved = 0)
    BEGIN
        --SELECT @HeaderDiscount = ISNULL(Discount, 0) 
        --FROM SPO_OrderHeader 
        --WHERE OrderId = @OrderId AND IsDiscount = 0

        SELECT @DetailsDiscount = ISNULL(SUM(Discount), 0) 
        FROM SPO_OrderDetails 
        WHERE OrderId = @OrderId AND IsDiscountApprove = 0 AND  DiscountStatus = 'P'
    END

    SET @TotalDiscount = @HeaderDiscount + @DetailsDiscount

    RETURN @TotalDiscount
END

GO

