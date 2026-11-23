-- =============================================
-- added by Isuru 2026-09-18 Franchise Invoice Return tax preview: the source BI's stored tax
--   scaled by the Return QTY the user typed, so the screen shows exactly what
--   SP_InsertStockTransactions will save for the 'BR' (no live tax setup is read).
--   Output shape matches SP_GetFranchiseIssueTaxPreview so the screen renders it the same way.
-- =============================================
CREATE PROCEDURE dbo.SP_GetFranchiseInvoiceReturnTaxPreview
    @StockTransactionHeaderID INT,            -- the selected SR / BI (what becomes BR.ReferenceID)
    @Propertyid               INT,
    @ItemsXml                 NVARCHAR(MAX)   -- <Lines><Line><StockItemID/><TxnUnitID/><SellingPrice/><Quantity/></Line></Lines>
AS
BEGIN
    SET NOCOUNT ON;

    -- same source resolution the save path uses: a 'BI' is itself, an 'SR' goes SR -> GR -> BI
    DECLARE @SrcType CHAR(2), @BIHeaderID INT;

    SELECT @SrcType = TransactionType
    FROM   dbo.StockTransactionHeaders
    WHERE  Id = @StockTransactionHeaderID AND PropertyID = @Propertyid;

    IF (@SrcType = 'BI')
        SET @BIHeaderID = @StockTransactionHeaderID;
    ELSE IF (@SrcType = 'SR')
        SELECT @BIHeaderID = BI.Id
        FROM   dbo.StockTransactionHeaders SR
        INNER JOIN dbo.StockTransactionHeaders GR ON GR.Id = SR.ReferenceID AND GR.TransactionType = 'GR'
        INNER JOIN dbo.StockTransactionHeaders BI ON BI.Id = GR.ReferenceID AND BI.TransactionType = 'BI'
        WHERE  SR.Id = @StockTransactionHeaderID;

    DECLARE @Xml XML;
    IF (ISNULL(LTRIM(RTRIM(@ItemsXml)), '') <> '')
        SET @Xml = CAST(@ItemsXml AS XML);

    CREATE TABLE #Lines (StockItemID INT, TxnUnitID INT, SellingPrice DECIMAL(18,6), Quantity DECIMAL(18,6));

    INSERT INTO #Lines (StockItemID, TxnUnitID, SellingPrice, Quantity)
    SELECT ISNULL(L.value('(StockItemID)[1]',  'INT'), 0),
           ISNULL(L.value('(TxnUnitID)[1]',    'INT'), 0),
           ISNULL(L.value('(SellingPrice)[1]', 'DECIMAL(18,6)'), 0),
           ISNULL(L.value('(Quantity)[1]',     'DECIMAL(18,6)'), 0)
    FROM   @Xml.nodes('/Lines/Line') AS T(L);

    DELETE FROM #Lines WHERE StockItemID = 0 OR Quantity = 0;

    DECLARE @SubTotal DECIMAL(18,6) = ISNULL((SELECT SUM(SellingPrice * Quantity) FROM #Lines), 0);

    -- returned qty per item, in the return line's unit (same grouping as #BRLines on save)
    SELECT   StockItemID,
             MAX(TxnUnitID) AS TxnUnitID,
             SUM(Quantity)  AS Quantity
    INTO     #PreviewLines
    FROM     #Lines
    GROUP BY StockItemID;

    -- the BI's open lines for those items, with the rate to the return unit
    SELECT BD.Id                                                            AS DetailID,
           BD.StockItemID,
           PL.Quantity                                                      AS ReturnQty,
           CASE WHEN BD.TxnUnitID = PL.TxnUnitID THEN 1
                WHEN dbo.FN_GetUnitConvertionRate(@Propertyid, BD.TxnUnitID, PL.TxnUnitID) > 0
                     THEN dbo.FN_GetUnitConvertionRate(@Propertyid, BD.TxnUnitID, PL.TxnUnitID)
                ELSE 1 END                                                  AS Rate,
           CASE WHEN BD.Quantity - ISNULL(BD.ReturnQuantity, 0) > 0
                THEN BD.Quantity - ISNULL(BD.ReturnQuantity, 0) ELSE 0 END  AS OpenQty,
           BD.Quantity                                                      AS BIQty
    INTO   #BISource
    FROM   dbo.StockTransactionDetails BD
    INNER JOIN #PreviewLines PL ON PL.StockItemID = BD.StockItemID
    WHERE  BD.StockTransactionHeaderID = @BIHeaderID;

    -- spread the return over those lines in line order, exactly as the save does
    CREATE TABLE #Tax (TaxTypeId INT, Amt DECIMAL(18,6));

    ;WITH Alloc AS (
        SELECT S.DetailID,
               S.Rate,
               S.BIQty,
               S.ReturnQty,
               S.OpenQty * S.Rate AS OpenInReturnUnit,
               ISNULL(SUM(S.OpenQty * S.Rate) OVER (PARTITION BY S.StockItemID ORDER BY S.DetailID
                                                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) AS OpenBefore
        FROM   #BISource S
    )
    INSERT INTO #Tax (TaxTypeId, Amt)
    SELECT TX.TaxTypeID,
           SUM(TX.TaxAmount * CAST(X.Alloc / A.Rate AS DECIMAL(18, 6)) / A.BIQty)
    FROM   Alloc A
    CROSS APPLY (SELECT CASE WHEN A.ReturnQty - A.OpenBefore <= 0                  THEN 0
                             WHEN A.ReturnQty - A.OpenBefore >= A.OpenInReturnUnit THEN A.OpenInReturnUnit
                             ELSE A.ReturnQty - A.OpenBefore END AS Alloc) X
    INNER JOIN dbo.StockTransactionwiseTaxes TX ON TX.StockTransactionDetailID = A.DetailID
    WHERE  X.Alloc > 0 AND A.BIQty > 0
    GROUP BY TX.TaxTypeID;

    -- label shaping identical to SP_GetFranchiseIssueTaxPreview
    SELECT     TD.Name AS TaxName, TD.Rate AS Rate, SUM(T.Amt) AS Amt
    INTO       #TaxNamed
    FROM       #Tax T
    INNER JOIN dbo.TaxDetails TD ON TD.TaxTypeId = T.TaxTypeId
    GROUP BY   TD.Name, TD.Rate
    HAVING     SUM(T.Amt) <> 0;

    DECLARE @PreVatAmt  DECIMAL(18,6) = ISNULL((SELECT SUM(Amt) FROM #TaxNamed WHERE TaxName NOT LIKE '%VAT%'), 0);
    DECLARE @VatAmt     DECIMAL(18,6) = ISNULL((SELECT SUM(Amt) FROM #TaxNamed WHERE TaxName     LIKE '%VAT%'), 0);
    DECLARE @PreVatName VARCHAR(100)  = (SELECT TOP 1 TaxName FROM #TaxNamed WHERE TaxName NOT LIKE '%VAT%' ORDER BY Rate);
    DECLARE @VatName    VARCHAR(100)  = (SELECT TOP 1 TaxName FROM #TaxNamed WHERE TaxName     LIKE '%VAT%' ORDER BY Rate DESC);

    DECLARE @PreVatLabel VARCHAR(120) =
            CASE WHEN @PreVatName IS NULL         THEN NULL
                 WHEN RIGHT(@PreVatName, 1) = '%' THEN @PreVatName
                 ELSE @PreVatName + '%' END;

    SELECT SeqNo, Label, Amount, IsLevy, IsTotal
    FROM (
        SELECT 1 AS SeqNo, CAST('Sub Total' AS VARCHAR(120)) AS Label, @SubTotal AS Amount,
               CAST(0 AS BIT) AS IsLevy, CAST(0 AS BIT) AS IsTotal
        UNION ALL SELECT 2, @PreVatLabel, @PreVatAmt, 1, 0 WHERE @PreVatName IS NOT NULL
        UNION ALL SELECT 3, @VatName,     @VatAmt,    1, 0 WHERE @VatName    IS NOT NULL
        UNION ALL SELECT 4, 'Total Tax Amount', @PreVatAmt + @VatAmt, 0, 0
                  WHERE @PreVatName IS NOT NULL OR @VatName IS NOT NULL
        UNION ALL SELECT 5, 'Grand Total', @SubTotal + @PreVatAmt + @VatAmt, 0, 1
    ) X
    ORDER BY SeqNo;

    DROP TABLE #TaxNamed;
    DROP TABLE #Tax;
    DROP TABLE #BISource;
    DROP TABLE #PreviewLines;
    DROP TABLE #Lines;
END

GO

