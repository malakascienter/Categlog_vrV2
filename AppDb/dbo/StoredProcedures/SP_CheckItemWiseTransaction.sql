-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2023-12-04
-- Description:	Check Transaction for Items

-- [dbo].[SP_CheckItemWiseTransaction] 38093
-- =============================================
CREATE PROCEDURE [dbo].[SP_CheckItemWiseTransaction]
@ID INT
AS
BEGIN
	SET NOCOUNT ON;

	--Added by Isuru 2025-02-03 to check if Stock Item had any transactions in other properties also

	IF OBJECT_ID('tempdb..#TempID') IS NOT NULL
	DROP TABLE #TempID


	DECLARE @StockItemCode VARCHAR(MAX)

	 DECLARE @TempID TABLE (ID INT PRIMARY KEY);

	SELECT @StockItemCode = StockItemCode
	FROM STOCKITEMHEADERS
	WHERE ID = @ID

	 INSERT INTO @TempID (ID)
    SELECT ID
    FROM STOCKITEMHEADERS
    WHERE StockItemCode = @StockItemCode;

	--End

    SELECT DISTINCT  StockItemID
	FROM StockTransactionDetails std
	WHERE EXISTS (SELECT 1 FROM @TempID t WHERE t.ID = std.StockItemID)  --Added by Isuru 2025-02-03 to check if Stock Item had any transactions in other properties also
	UNION ALL
	SELECT DISTINCT StockItemID
	FROM RequestDetails rd
	 WHERE EXISTS (SELECT 1 FROM @TempID t WHERE t.ID = rd.StockItemID) --Added by Isuru 2025-02-03 to check if Stock Item had any transactions in other properties also
	UNION ALL
	SELECT DISTINCT StockItemID
	FROM Podetails pd
	 WHERE EXISTS (SELECT 1 FROM @TempID t WHERE t.ID = pd.StockItemID); --Added by Isuru 2025-02-03 to check if Stock Item had any transactions in other properties also
	--UNION ALL
	--SELECT DISTINCT StockItemID
	--FROM SupplierWiseItemDetails
	--WHERE StockItemID = @ID

END

GO

