-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-09-15
-- Edited 2026-09-15 : based on the live definition (modified 13:47). An 'SR' line's ReturnableQuantity and
--                     pre-filled ReturnQuantity are also capped by what is still open on its original
--                     'BI' line, the same check SP_InsertStockTransactions applies when a 'BR' is saved.
-- Description:	get all BI and GRN documents details to the return 
-- =============================================

CREATE   PROCEDURE dbo.SP_GetFranchiseInvoiceReturnDocumentDetails
    @StockTransactionHeaderID INT,
    @Propertyid               INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SH.Id                                         AS StockTransactionHeaderID,
        SD.Id                                         AS StockTransactionDetailID,
        SH.DocumentNo,
        SD.StockItemID,
        SI.StockItemCode,
        SI.Name                                       AS ItemName,
        SI.IsExpiryDateApplicable,
        SD.TxnUnitID                                  AS UnitID,
        UN.Code                                       AS UnitCode,
        UN.Name                                       AS UnitName,
        CASE WHEN SH.TransactionType = 'SR' THEN ISNULL(SRC.InvoicedQuantity, SD.Quantity)
             ELSE SD.Quantity END                     AS InvoicedQuantity,
        ISNULL(SD.ReturnQuantity, 0)                  AS PreviouslyReturnedQuantity,
        --Edited 2026-09-15 : an SR line is also capped by what is still open on its BI line
        CAST(CASE WHEN SH.TransactionType = 'SR' AND BIO.OpenQuantity < SD.Quantity - ISNULL(SD.ReturnQuantity, 0)
                  THEN BIO.OpenQuantity
                  ELSE SD.Quantity - ISNULL(SD.ReturnQuantity, 0) END AS DECIMAL(18, 6)) AS ReturnableQuantity,
        CAST(CASE WHEN SH.TransactionType <> 'SR' THEN 0
                  WHEN BIO.OpenQuantity < SD.Quantity - ISNULL(SD.ReturnQuantity, 0) THEN BIO.OpenQuantity
                  ELSE SD.Quantity - ISNULL(SD.ReturnQuantity, 0) END AS DECIMAL(18, 6)) AS ReturnQuantity,
        --End
        ISNULL(SD.SellingPrice, 0)                    AS SellingPrice,
        ISNULL(SD.UnitPrice, 0)                       AS UnitPrice,
        SD.Remarks
    FROM StockTransactionHeaders SH
    INNER JOIN StockTransactionDetails SD ON SD.StockTransactionHeaderID = SH.Id
    INNER JOIN StockItemHeaders SI        ON SI.Id = SD.StockItemID
    LEFT JOIN  Units UN                   ON UN.Id = SD.TxnUnitID
    OUTER APPLY (
        SELECT TOP (1)
            CAST(SRCD.Quantity *
                 CASE WHEN SRCD.TxnUnitID = SD.TxnUnitID THEN 1
                      WHEN dbo.FN_GetUnitConvertionRate(@Propertyid, SRCD.TxnUnitID, SD.TxnUnitID) > 0
                           THEN dbo.FN_GetUnitConvertionRate(@Propertyid, SRCD.TxnUnitID, SD.TxnUnitID)
                      ELSE 1 END
                 AS DECIMAL(18, 6))                   AS InvoicedQuantity
        FROM StockTransactionHeaders GR
        LEFT JOIN StockTransactionHeaders BI  ON BI.Id              = GR.ReferenceID
                                             AND BI.TransactionType = 'BI'
        INNER JOIN StockTransactionDetails SRCD ON SRCD.StockTransactionHeaderID IN (BI.Id, GR.Id)
                                               AND SRCD.StockItemID = SD.StockItemID
        WHERE SH.TransactionType  = 'SR'
          AND GR.Id               = SH.ReferenceID
          AND GR.TransactionType  = 'GR'
        ORDER BY CASE WHEN SRCD.StockTransactionHeaderID = BI.Id THEN 0 ELSE 1 END,
                 SRCD.Id
    ) SRC
    --Added 2026-09-15 : quantity still open on the original BI line(s) of an SR line, in the SR line's unit
    OUTER APPLY (
        -- per-line values are worked out in BL first: SUM cannot mix the BI line's columns
        -- with the outer SR line's unit in one aggregated expression
        SELECT SUM(BL.OpenQuantity * BL.Rate)         AS OpenQuantity
        FROM StockTransactionHeaders GR
        INNER JOIN StockTransactionHeaders BI  ON BI.Id              = GR.ReferenceID
                                              AND BI.TransactionType = 'BI'
        INNER JOIN StockTransactionDetails BD  ON BD.StockTransactionHeaderID = BI.Id
                                              AND BD.StockItemID              = SD.StockItemID
        CROSS APPLY (
            SELECT CASE WHEN BD.Quantity - ISNULL(BD.ReturnQuantity, 0) > 0
                        THEN BD.Quantity - ISNULL(BD.ReturnQuantity, 0) ELSE 0 END AS OpenQuantity,
                   CASE WHEN BD.TxnUnitID = SD.TxnUnitID THEN 1
                        WHEN dbo.FN_GetUnitConvertionRate(@Propertyid, BD.TxnUnitID, SD.TxnUnitID) > 0
                             THEN dbo.FN_GetUnitConvertionRate(@Propertyid, BD.TxnUnitID, SD.TxnUnitID)
                        ELSE 1 END                                               AS Rate
        ) BL
        WHERE SH.TransactionType  = 'SR'
          AND GR.Id               = SH.ReferenceID
          AND GR.TransactionType  = 'GR'
    ) BIO
    --End
    WHERE SH.Id              = @StockTransactionHeaderID
      AND SH.PropertyID      = @Propertyid
      AND SH.TransactionType IN ('BI','SR')
      AND SD.Quantity - ISNULL(SD.ReturnQuantity, 0) > 0
    ORDER BY SI.Name;

END

GO

