-- =============================================
-- Author:      ISURU PRAMODYA
-- Create date: 23 MARCH 2023
-- Description: PRINTING APPROVAL GRN REPORTS

-- EXEC [dbo].[rptPrintApprovalGRN] 8515, ''

-- =============================================

-- Edited 2026-09-24: CREATE -> ALTER for this update script
CREATE PROCEDURE [dbo].[rptPrintApprovalGRN]
(
    @StockTxnID INT,
    @UserName VARCHAR(50)
)
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE
        @GRNXML VARCHAR(MAX),
        @NEWGRNXML XML,
        @iDocIDORG INT,
        @BaseCurrency VARCHAR(10),
        @TxnCurrency VARCHAR(10),
        @ExchangeRate MONEY = 1,
        @SupplierID INT,
        @LocationID INT; -- Edited 2026-09-24: passed to the tax SP

    ---------------------------------------------------------
    -- Get GRN XML
    ---------------------------------------------------------
    SELECT
        @GRNXML = XMLDetails
    FROM dbo.GRNApprovalLog
    WHERE Id = @StockTxnID;


    ---------------------------------------------------------
    -- Tax temporary table
    ---------------------------------------------------------
    CREATE TABLE #TaxTable
    (
        TaxTypeId INT,
        TaxValue DECIMAL(18,6)
    );


    ---------------------------------------------------------
    -- Convert XML
    ---------------------------------------------------------
    SET @NEWGRNXML = CONVERT(XML, @GRNXML);


    ---------------------------------------------------------
    -- Prepare XML document
    ---------------------------------------------------------
    EXEC sp_xml_preparedocument
        @iDocIDORG OUTPUT,
        @NEWGRNXML;


    ---------------------------------------------------------
    -- Get all GRN detail records from XML
    ---------------------------------------------------------
    SELECT *
    INTO #TempDetails
    FROM OPENXML
    (
        @iDocIDORG,
        '/StockTransactionHeader/StockDetailList/StockTransactionDetail',
        2
    )
    WITH StockTransactionDetails;


    ---------------------------------------------------------
    -- Get transaction currency
    ---------------------------------------------------------
    SELECT
        @TxnCurrency = ISOCode
    FROM dbo.CurrencyMasters
    WHERE Id = 154;


    ---------------------------------------------------------
    -- Get base currency
    ---------------------------------------------------------
    SELECT
        @BaseCurrency = CurrencyCode
    FROM [eFinancials_Accounting]..Destinity_Acc_CurrencyRef
    WHERE BaseCurrency = 1;


    ---------------------------------------------------------
    -- Get exchange rate
    ---------------------------------------------------------
    SELECT TOP 1
        @ExchangeRate = ExchangeRate
    FROM [eFinancials_Accounting].[dbo].[Destinity_Acc_CurrencyExchangeRate]
    WHERE [FromCurrencyCode] = @BaseCurrency
      AND ToCurrencyCode = @TxnCurrency;


    ---------------------------------------------------------
    -- Prevent NULL / zero exchange rate
    ---------------------------------------------------------
    IF ISNULL(@ExchangeRate, 0) = 0
    BEGIN
        SET @ExchangeRate = 1;
    END;


    ---------------------------------------------------------
    -- Get Supplier and Location
    --
    -- Edited 2026-09-24: LocationId is needed by the tax SP,
    -- because SupplierWiseItemDetails is kept per location.
    ---------------------------------------------------------
    SELECT
        @SupplierID = SupplierId,
        @LocationID = LocationId
    FROM dbo.GRNApprovalLog
    WHERE Id = @StockTxnID;


    ---------------------------------------------------------
    -- Item details table
    ---------------------------------------------------------
    CREATE TABLE #ItemDetails
    (
        RowNo INT IDENTITY(1,1),

        StockItemID BIGINT,
        StockItemCode VARCHAR(MAX),
        ItemName VARCHAR(MAX),
        Category VARCHAR(MAX),
        Remarks VARCHAR(MAX),

        UnitPrice DECIMAL(18,6),
        Quantity DECIMAL(18,6),
        Unit VARCHAR(MAX),

        DiscountValue DECIMAL(18,6),
        ItemTotal DECIMAL(18,6),

        NetUnitPrice DECIMAL(18,6), -- Edited 2026-09-24: unit price after discount, passed to the tax SP

        TaxAmount DECIMAL(18,6)
    );


    ---------------------------------------------------------
    -- Insert ALL items from XML
    ---------------------------------------------------------
    INSERT INTO #ItemDetails
    (
        StockItemID,
        StockItemCode,
        ItemName,
        Category,
        Remarks,
        UnitPrice,
        Quantity,
        Unit,
        DiscountValue,
        ItemTotal,
        NetUnitPrice,
        TaxAmount
    )
    SELECT
        TD.StockItemID,

        ST.StockItemCode,

        ST.Name,

        CA.Name,

        TD.Remarks,

        -----------------------------------------------------
        -- Unit price
        -----------------------------------------------------
        TD.UnitPrice / @ExchangeRate,

        -----------------------------------------------------
        -- Quantity
        -----------------------------------------------------
        TD.Quantity,

        -----------------------------------------------------
        -- Unit
        -----------------------------------------------------
        U.Name,

        -----------------------------------------------------
        -- Discount
        -----------------------------------------------------
        CASE
            WHEN TD.DiscountPercentage > 0
                 AND TD.DiscountValue = 0
            THEN
                (
                    TD.UnitPrice
                    * TD.DiscountPercentage
                    / 100
                )
                / @ExchangeRate
                * TD.Quantity

            ELSE
                TD.DiscountValue / @ExchangeRate
        END,

        -----------------------------------------------------
        -- Item total (gross, before discount and tax)
        -----------------------------------------------------
        (
            TD.UnitPrice
            * TD.Quantity
        ) / @ExchangeRate,

        -----------------------------------------------------
        -- Net unit price
        --
        -- Edited 2026-09-24: same discount rule that
        -- SP_InsertStockTransactions uses for the GRN tax
        -- (DiscountValue is a line total, so it is spread
        -- over the quantity).
        -----------------------------------------------------
        (
            TD.UnitPrice
            - CASE
                  WHEN TD.DiscountValue > 0
                  THEN CASE WHEN TD.Quantity = 0 THEN 0 ELSE TD.DiscountValue / TD.Quantity END
                  ELSE TD.UnitPrice * TD.DiscountPercentage / 100
              END
        ) / @ExchangeRate,

        -----------------------------------------------------
        -- Tax initially zero
        -----------------------------------------------------
        0

    FROM #TempDetails TD

    INNER JOIN dbo.StockItemHeaders ST
        ON ST.ID = TD.StockItemID

    INNER JOIN dbo.Categories CA
        ON CA.Id = ST.CategoryID

    INNER JOIN dbo.Units U
        ON U.Id = TD.TxnUnitID;


    ---------------------------------------------------------
    -- Calculate tax for EACH item
    ---------------------------------------------------------
    DECLARE
        @RowNo INT,
        @StockItemID BIGINT,
        @NetUnitPrice DECIMAL(18,6),
        @Quantity DECIMAL(18,6),
        @TaxAmount DECIMAL(18,6);


    DECLARE TaxCursor CURSOR LOCAL FAST_FORWARD FOR

        SELECT
            RowNo,
            StockItemID,
            NetUnitPrice,
            Quantity
        FROM #ItemDetails
        ORDER BY RowNo;


    OPEN TaxCursor;


    FETCH NEXT FROM TaxCursor
    INTO
        @RowNo,
        @StockItemID,
        @NetUnitPrice,
        @Quantity;


    WHILE @@FETCH_STATUS = 0
    BEGIN

        -----------------------------------------------------
        -- IMPORTANT:
        -- Reset tax amount for every item
        -----------------------------------------------------
        SET @TaxAmount = 0;


        -----------------------------------------------------
        -- Clear previous item's tax records
        -----------------------------------------------------
        DELETE FROM #TaxTable;


        -----------------------------------------------------
        -- Get tax for ONE unit of the current item
        --
        -- Edited 2026-09-24: pass @LocationID and the net
        -- unit price, as SP_InsertStockTransactions does.
        -----------------------------------------------------
        INSERT INTO #TaxTable
        (
            TaxTypeId,
            TaxValue
        )
        EXEC [dbo].[SP_Select_StockItemWiseTaxAmount]
            @StockItemID,
            @NetUnitPrice,
            @SupplierID,
            @LocationID;


        -----------------------------------------------------
        -- Sum ALL tax types returned by tax SP, then
        -- multiply the unit tax by the quantity
        -----------------------------------------------------
        SELECT
            @TaxAmount = ISNULL(SUM(ISNULL(TaxValue, 0)), 0) * @Quantity
        FROM #TaxTable;


        -----------------------------------------------------
        -- Update tax for current item
        -----------------------------------------------------
        UPDATE #ItemDetails
        SET TaxAmount = ISNULL(@TaxAmount, 0)
        WHERE RowNo = @RowNo;


        -----------------------------------------------------
        -- Next item
        -----------------------------------------------------
        FETCH NEXT FROM TaxCursor
        INTO
            @RowNo,
            @StockItemID,
            @NetUnitPrice,
            @Quantity;

    END;


    CLOSE TaxCursor;
    DEALLOCATE TaxCursor;


    ---------------------------------------------------------
    -- Final result
    ---------------------------------------------------------
    SELECT
        GR.ApprovalDocNo AS DocumentNo,

        GR.CreatedDate AS TransactionDate,

        LO.Name AS location,

        SU.Name AS supplierName,

        SU.Address1,

        SU.Telephone1,

        SU.Email,

        CU.Name AS Currency,

        GR.ReferenceNo AS InvoiceNo,

        SU.Code AS suppCode,


        -----------------------------------------------------
        -- ITEM DETAILS
        -----------------------------------------------------
        IT.StockItemCode,

        IT.ItemName,

        IT.Category,

        IT.Remarks,

        IT.UnitPrice,

        IT.Quantity,

        IT.ItemTotal AS total,

        IT.Unit,

        IT.DiscountValue,

        -----------------------------------------------------
        -- IMPORTANT:
        -- DO NOT divide TaxAmount by ExchangeRate here.
        --
        -- TaxAmount was already calculated using NetUnitPrice
        -- after exchange-rate conversion.
        -----------------------------------------------------
        ISNULL(IT.TaxAmount, 0) AS TaxAmount,


        -----------------------------------------------------
        -- COMPANY DETAILS
        -----------------------------------------------------
        CO.Name,

        CO.Address1 AS compAdd1,

        CO.Address2 AS compAdd2,

        CO.Address3 AS compAdd3,

        CO.Telephone1 AS compTel1,

        CO.Email AS compEmail,

        CO.WebAddress,


        -----------------------------------------------------
        -- PO DETAILS
        -----------------------------------------------------
        PO.PoNo,


        -----------------------------------------------------
        -- EXCHANGE RATE
        -----------------------------------------------------
        @ExchangeRate AS ExchangeRate


    FROM dbo.GRNApprovalLog GR


    INNER JOIN dbo.LOCATIONS LO
        ON LO.ID = GR.LocationId


    INNER JOIN dbo.SUPPLIERS SU
        ON SU.ID = GR.SupplierId


    INNER JOIN dbo.CurrencyMasters CU
        ON CU.ID = SU.CurrencyID


    INNER JOIN dbo.Companies CO
        ON CO.CompanyID = LO.CompanyID


    ---------------------------------------------------------
    -- All item rows
    ---------------------------------------------------------
    CROSS JOIN #ItemDetails IT


    ---------------------------------------------------------
    -- PO
    --
    -- Edited 2026-09-24: joined straight to PoHeaders. The
    -- old join through PoDetails repeated each item row once
    -- per PO line.
    ---------------------------------------------------------
    LEFT JOIN dbo.PoHeaders PO
        ON PO.ID = GR.ReferenceId


    WHERE GR.Id = @StockTxnID;


    ---------------------------------------------------------
    -- Remove XML document from memory
    ---------------------------------------------------------
    EXEC sp_xml_removedocument @iDocIDORG;



    ---------------------------------------------------------
    -- Drop temporary tables
    ---------------------------------------------------------
    DROP TABLE #TaxTable;
    DROP TABLE #ItemDetails;
    DROP TABLE #TempDetails;

END

GO

