-- =============================================
-- Author:		<Thilini Fernando>
-- Create date: <13/03/2022> 
-- =============================================
CREATE FUNCTION [dbo].[FN_GetPOwiseAdditionalChargesTotal]
(
	@PoHeaderId INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
	DECLARE @TotalPOwiseCharges DECIMAL(18,2)

	 SELECT @TotalPOwiseCharges =SUM(ChargeAmount) FROM POwiseCharges 
	 WHERE POHeaderID = @PoHeaderId

	 RETURN @TotalPOwiseCharges

END

GO

