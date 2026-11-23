-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-12-24
-- Description:	Checking If item had transactions
-- =============================================
CREATE FUNCTION  [dbo].[fn_IsTransactionExistsItemWise]
(
	@StockItemID INT
)
RETURNS  BIT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM StockTransactionDetails WHERE StockItemID = @StockItemID)
        RETURN 1;

    IF EXISTS (SELECT 1 FROM PoDetails WHERE StockItemID = @StockItemID)
        RETURN 1;

    IF EXISTS (SELECT 1 FROM RequestDetails WHERE StockItemID = @StockItemID)
        RETURN 1;

    RETURN 0;

END

GO

