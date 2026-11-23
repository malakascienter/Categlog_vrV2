-- =============================================
-- Author:		Ravindu
-- Create date: 2026-03-17
-- Description:	Get Order Type validation details.
-- =============================================
-- EXEC [dbo].[SPO_GetOrderTypeValidationDetails] 27,1
CREATE   PROCEDURE [dbo].[SPO_GetOrderTypeValidationDetails] 
	@OrderTypeId INT,
	@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
	   MiniumOrderValue,
	   PlaceOrderBeforeDays,
	   AmmendmentBeforeDays,
	   IsAllowDiscounts 
	FROM SPO_OrderType
	WHERE ID = @OrderTypeId AND PropertyId = @PropertyId

END

GO

