

 -- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-08-14
-- Description:	Tax Breakup for Franchise Issue Note

 -- [dbo].[SP_RPT_FranchiseTaxInvoiceTaxBreakup] 13108
-- =============================================

CREATE     PROCEDURE [dbo].[SP_RPT_FranchiseTaxInvoiceTaxBreakup]
    @StockTxnID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SubTotal DECIMAL(18,6);

    SELECT @SubTotal = ISNULL(SUM(SD.Quantity * SD.SellingPrice), 0)
    FROM   StockTransactionDetails SD
    WHERE  SD.StockTransactionHeaderID = @StockTxnID;

    SELECT     TD.Name            AS TaxName,
               TD.Rate            AS Rate,
               SUM(STX.TaxAmount) AS Amt
    INTO       #Tax
    FROM       StockTransactionDetails      SD
    INNER JOIN StockTransactionwiseTaxes    STX ON STX.StockTransactionDetailID = SD.Id
    INNER JOIN TaxDetails                   TD  ON TD.TaxTypeId = STX.TaxTypeID
    WHERE      SD.StockTransactionHeaderID = @StockTxnID
    GROUP BY   TD.Name, TD.Rate
    HAVING     SUM(STX.TaxAmount) <> 0;

    DECLARE @PreVatAmt  DECIMAL(18,6) = ISNULL((SELECT SUM(Amt) FROM #Tax WHERE TaxName NOT LIKE '%VAT%'), 0);
    DECLARE @VatAmt     DECIMAL(18,6) = ISNULL((SELECT SUM(Amt) FROM #Tax WHERE TaxName     LIKE '%VAT%'), 0);
    DECLARE @PreVatName VARCHAR(100)  = (SELECT TOP 1 TaxName FROM #Tax WHERE TaxName NOT LIKE '%VAT%' ORDER BY Rate);
    DECLARE @VatName    VARCHAR(100)  = (SELECT TOP 1 TaxName FROM #Tax WHERE TaxName     LIKE '%VAT%' ORDER BY Rate DESC);

    -- 'SSCL 2.5' -> 'SSCL 2.5%' for the levy row, and -> 'SSCL' for the running-total row
    DECLARE @PreVatLabel VARCHAR(120) =
            CASE WHEN @PreVatName IS NULL              THEN NULL
                 WHEN RIGHT(@PreVatName, 1) = '%'      THEN @PreVatName
                 ELSE @PreVatName + '%' END;
    DECLARE @PreVatShort VARCHAR(60) =
            CASE WHEN @PreVatName IS NULL THEN NULL
                 ELSE LEFT(@PreVatName, CHARINDEX(' ', @PreVatName + ' ') - 1) END;

    SELECT SeqNo, Label, Amount, IsTotal
    FROM (
        SELECT     1 AS SeqNo,
                   CAST('Sub Total' AS VARCHAR(120)) AS Label,
                   @SubTotal                         AS Amount,
                   CAST(0 AS BIT)                    AS IsTotal
        UNION ALL
        SELECT     2, @PreVatLabel, @PreVatAmt, 0
        WHERE      @PreVatName IS NOT NULL
        UNION ALL
        SELECT     3, 'Total with ' + @PreVatShort, @SubTotal + @PreVatAmt, 0
        WHERE      @PreVatName IS NOT NULL AND @VatName IS NOT NULL
        UNION ALL
        SELECT     4, @VatName, @VatAmt, 0
        WHERE      @VatName IS NOT NULL
        UNION ALL
        SELECT     5, 'Grand Total', @SubTotal + @PreVatAmt + @VatAmt, 1
    ) X
    ORDER BY SeqNo;

    DROP TABLE #Tax;
END

GO

