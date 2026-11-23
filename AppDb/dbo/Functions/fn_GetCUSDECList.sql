create FUNCTION dbo.fn_GetCUSDECList
(
    @LocationID          INT,
    @StockitemID         INT,
    @ID                  INT,
    @propertyId          INT,       -- kept for future use
    @IsCUSDECSelection   BIT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        CASE 
            WHEN @IsCUSDECSelection = 1 THEN
            (
                SELECT
                    SH.ID,
                    SH.ReferenceNo
                FROM StockTransactionHeaders SH
                INNER JOIN StockTransactionDetails SD
                    ON SD.StockTransactionHeaderID = SH.ID
                WHERE SH.TransactionType = 'GR'
                  AND SD.StockItemID = @StockitemID
                  AND SH.LocationID = @LocationID
                  AND SH.ID = CASE WHEN @ID = -999 THEN SH.ID ELSE @ID END
                  AND SH.ReferenceNo <> 'FreeQty'
                FOR JSON PATH
            )
            ELSE ''
        END AS CUSDECList
);

GO

