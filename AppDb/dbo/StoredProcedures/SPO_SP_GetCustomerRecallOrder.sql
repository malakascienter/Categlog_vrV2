-- =============================================
-- Author:		Nivesh
-- Create date: 2025-12-24
-- Description:	Get Customer Recall Orders
-- =============================================
-- EXEC SPO_SP_GetCustomerRecallOrder '0702375050'
CREATE   PROCEDURE [dbo].[SPO_SP_GetCustomerRecallOrder] 
	@PhoneNumber VARCHAR(20)
AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @HasOrderPayment BIT
	
	SELECT 
		SOH.OrderId AS id,
		SOH.InvoiceNo AS text
	FROM
	SPO_OrderHeader SOH
	INNER JOIN SPO_OrderType AS OT ON SOH.OrderTypeId = OT.ID
	WHERE SOH.MobileNo = TRIM(@PhoneNumber)
	AND SOH.Status = 'C'
	AND SOH.IsApprove =1
	AND OT.IsAllowAmendment = 1
	AND NOT EXISTS (
        SELECT 1 
        FROM SPO_OrderWisePayment OWP
        WHERE OWP.OrderId     = SOH.OrderId
        AND   OWP.PaymentType = 'D'
    )
END

GO

