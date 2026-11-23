
-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-08-21
-- Description:	Get tax breakdown for franchise issue items
-- =============================================

CREATE   PROCEDURE dbo.SP_GetFranchiseIssueTaxPreview
    @ItemsXml              NVARCHAR(MAX),
    @Supplierid            INT,
    @FranchiseLocationid   INT = NULL,
    @Departmentid          INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Locationid2 INT = NULLIF(@FranchiseLocationid, 0);

    -- Same resolution SP_InsertStockTransactions uses for @InvoiceLocationID.
    IF (@Locationid2 IS NULL AND ISNULL(@Departmentid, 0) <> 0)
    BEGIN
        SELECT @Locationid2 = LO.Id
        FROM   Locations LO
        WHERE  LO.DepartmentID = @Departmentid;
    END

    -- Assigned in an IF rather than a CASE so the CAST is never reached for an
    -- empty basket; a caller with nothing ticked sends "<Lines></Lines>", but
    -- NULL and '' have to be survivable too.
    DECLARE @Xml XML;

    IF (ISNULL(LTRIM(RTRIM(@ItemsXml)), '') <> '')
    BEGIN
        SET @Xml = CAST(@ItemsXml AS XML);
    END

    CREATE TABLE #Lines
    (
        RowNo        INT IDENTITY(1,1) PRIMARY KEY,
        StockItemID  INT,
        SellingPrice DECIMAL(18,6),
        Quantity     DECIMAL(18,6)
    );

    INSERT INTO #Lines (StockItemID, SellingPrice, Quantity)
    SELECT ISNULL(L.value('(StockItemID)[1]',  'INT'), 0),
           ISNULL(L.value('(SellingPrice)[1]', 'DECIMAL(18,6)'), 0),
           ISNULL(L.value('(Quantity)[1]',     'DECIMAL(18,6)'), 0)
    FROM   @Xml.nodes('/Lines/Line') AS T(L);

    DELETE FROM #Lines WHERE StockItemID = 0 OR Quantity = 0;

    DECLARE @SubTotal DECIMAL(18,6) =
            ISNULL((SELECT SUM(SellingPrice * Quantity) FROM #Lines), 0);

    CREATE TABLE #ItemTax (TaxTypeId INT, TaxValue DECIMAL(18,6));
    CREATE TABLE #Tax     (TaxTypeId INT, Amt      DECIMAL(18,6));

    -- No franchise location means the save would fail anyway ('Franchise
    -- Location and Department Mapping Not exists'), so there is nothing
    -- sensible to price. Sub Total and Grand Total still come back.
    IF (@Locationid2 IS NOT NULL)
    BEGIN
        DECLARE @RowNo  INT,
                @ItemID INT,
                @Price  DECIMAL(18,6),
                @Qty    DECIMAL(18,6);

        SELECT @RowNo = MIN(RowNo) FROM #Lines;

        WHILE (@RowNo IS NOT NULL)
        BEGIN
            SELECT @ItemID = StockItemID,
                   @Price  = SellingPrice,
                   @Qty    = Quantity
            FROM   #Lines
            WHERE  RowNo = @RowNo;

            DELETE FROM #ItemTax;

            -- @Price is per unit and TaxValue comes back per unit; the line
            -- tax is TaxValue * Quantity, exactly as the save path stores it.
            INSERT INTO #ItemTax (TaxTypeId, TaxValue)
            EXEC [SP_Select_StockItemWiseTaxAmount] @ItemID, @Price, @Supplierid, @Locationid2;

            INSERT INTO #Tax (TaxTypeId, Amt)
            SELECT TaxTypeId, TaxValue * @Qty
            FROM   #ItemTax
            WHERE  TaxValue > 0;

            SELECT @RowNo = MIN(RowNo) FROM #Lines WHERE RowNo > @RowNo;
        END
    END

    SELECT     TD.Name    AS TaxName,
               TD.Rate    AS Rate,
               SUM(T.Amt) AS Amt
    INTO       #TaxNamed
    FROM       #Tax T
    INNER JOIN TaxDetails TD ON TD.TaxTypeId = T.TaxTypeId
    GROUP BY   TD.Name, TD.Rate
    HAVING     SUM(T.Amt) <> 0;

    DECLARE @PreVatAmt  DECIMAL(18,6) = ISNULL((SELECT SUM(Amt) FROM #TaxNamed WHERE TaxName NOT LIKE '%VAT%'), 0);
    DECLARE @VatAmt     DECIMAL(18,6) = ISNULL((SELECT SUM(Amt) FROM #TaxNamed WHERE TaxName     LIKE '%VAT%'), 0);
    DECLARE @PreVatName VARCHAR(100)  = (SELECT TOP 1 TaxName FROM #TaxNamed WHERE TaxName NOT LIKE '%VAT%' ORDER BY Rate);
    DECLARE @VatName    VARCHAR(100)  = (SELECT TOP 1 TaxName FROM #TaxNamed WHERE TaxName     LIKE '%VAT%' ORDER BY Rate DESC);

    -- 'SSCL 2.5' -> 'SSCL 2.5%' for the levy row.
    DECLARE @PreVatLabel VARCHAR(120) =
            CASE WHEN @PreVatName IS NULL         THEN NULL
                 WHEN RIGHT(@PreVatName, 1) = '%' THEN @PreVatName
                 ELSE @PreVatName + '%' END;

    SELECT SeqNo, Label, Amount, IsLevy, IsTotal
    FROM (
        SELECT     1 AS SeqNo,
                   CAST('Sub Total' AS VARCHAR(120)) AS Label,
                   @SubTotal                         AS Amount,
                   CAST(0 AS BIT)                    AS IsLevy,
                   CAST(0 AS BIT)                    AS IsTotal
        UNION ALL
        SELECT     2, @PreVatLabel, @PreVatAmt, 1, 0
        WHERE      @PreVatName IS NOT NULL
        UNION ALL
        SELECT     3, @VatName, @VatAmt, 1, 0
        WHERE      @VatName IS NOT NULL
        UNION ALL
        -- The levies added up. Suppressed when nothing is taxed at all, so a
        -- zero-tax basket does not carry a 0.00 row it has no use for.
        SELECT     4, 'Total Tax Amount', @PreVatAmt + @VatAmt, 0, 0
        WHERE      @PreVatName IS NOT NULL OR @VatName IS NOT NULL
        UNION ALL
        SELECT     5, 'Grand Total', @SubTotal + @PreVatAmt + @VatAmt, 0, 1
    ) X
    ORDER BY SeqNo;

    DROP TABLE #TaxNamed;
    DROP TABLE #Tax;
    DROP TABLE #ItemTax;
    DROP TABLE #Lines;
END

GO

