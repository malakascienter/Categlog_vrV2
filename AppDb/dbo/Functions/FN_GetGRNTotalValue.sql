-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-08-27
-- Description:	Function to retrieve GRN total value
-- =============================================
CREATE FUNCTION [dbo].[FN_GetGRNTotalValue]
(
	@HeaderID INT
)
RETURNS  DECIMAL(18,6) 
AS
BEGIN
	DECLARE @AdditionalCharge DECIMAL(18,8),
			@Total DECIMAL(18,8),
			@TaxAmount DECIMAL(18,8)

	
	
		SELECT @AdditionalCharge = ISNULL(SUM(ChargeAmount),0)
		FROM StockTransactionwiseCharges
		WHERE StockTransactionHeaderID=@HeaderID

		
		SELECT @TaxAmount =ISNULL(SUM(TaxAmount),0)
		FROM StockTransactionwiseTaxes
		WHERE StockTransactionDetailID IN (SELECT ID
		FROM StockTransactionDetails
		WHERE StockTransactionHeaderID = @HeaderID)

		SELECT @Total = sum(d.Quantity * d.UnitPrice)- SUM( CASE WHEN D.DiscountValue=0 THEN d.Quantity * d.UnitPrice * d.DiscountPercentage /100 ELSE  D.DiscountValue END )+@AdditionalCharge+@TaxAmount
		FROM StockTransactionDetails D
		WHERE StockTransactionHeaderID = @HeaderID

		RETURN isnull(@Total,0)

END

GO

