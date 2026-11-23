-- =============================================
-- Author:		Ravindu
-- Create date: 2026-03-09
-- Description:	Get payment details
-- =============================================
-- EXEC SPO_GetPaymentDetails 10,0
CREATE    PROCEDURE [dbo].[SPO_GetPaymentDetails]
(
	 @OrderId INT ,
	 @PropertyId INT
)
AS
BEGIN
    SELECT
        OWP.Id,
        OWP.OrderId,
        OWP.Paycode,
        PT.Description AS PaymentTypeName,
        OWP.PaymentAmount,
        OWP.PaymentDate,
        OWP.OutletCode,
        L.description AS OutletName,
        OWP.PreviousAmount,
        OWP.BalanceAmount,
        OWP.Recipet
    FROM SPO_OrderWisePayment AS OWP
    INNER JOIN PaymentTypes AS PT ON PT.PayCode = OWP.PayCode
    INNER JOIN Location_Ref AS L ON L.code = OWP.OutletCode
    WHERE OrderId = @OrderId AND OWP.PropertyId = @PropertyId
    ORDER BY ID ASC
END

GO

