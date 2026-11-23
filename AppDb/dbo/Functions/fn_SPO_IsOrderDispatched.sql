-- =============================================
-- Author:		Ravindu
-- Create date: 2026-03-31
-- Description:	Get order dispatch or not
-- =============================================
CREATE   FUNCTION dbo.fn_SPO_IsOrderDispatched
(
    @PropertyId INT,
    @OrderId    INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @IsDispatched BIT = 0

    IF EXISTS (
        SELECT 1
        FROM SPO_OrderWisePayment
        WHERE OrderId    = @OrderId
          AND PropertyId = @PropertyId
          AND PaymentType = 'S'
    )
    BEGIN
        SET @IsDispatched = 1
    END

    RETURN @IsDispatched
END

GO

