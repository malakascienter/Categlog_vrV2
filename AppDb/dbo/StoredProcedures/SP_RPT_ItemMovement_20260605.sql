-- [dbo].[SP_RPT_ItemMovement_20260605] '2018-08-10','2026-05-30',-999,1,0,-999,-999
-- =============================================
-- Author      : Nivesh
-- Create date : 2026-06-05
-- Purpose     : Optimized rewrite of SP_RPT_ItemMovement_20260603.
--   * Opening/closing balances and Usage now come from dbo.FN_GetItemUsage_TVF
--     (inline TVF, one row per item):
--       UsageQuantity = OpenQty + GRNq + TIq - TOq - INq - SRq - ClosingQty
--       UsageValue    = OpenVal + GRNv + TIv - TOv - INv - SRv - ClosingVal
--       (GRN Out = SR = Supplier Return)
--   * Sargable optional filters + OPTION (RECOMPILE).
--   * Fixes DECIMAL(18,0) truncation on the movement columns.
-- =============================================
CREATE   PROCEDURE [dbo].[SP_RPT_ItemMovement_20260605]
(
    @DateFrom    DATE = '2018-08-10',
    @DateTo      DATE = '2018-09-30',
    @StockItemID INT  = -999,
    @LocationID  INT  = 1,
    @byValue     BIT  = 0,
    @CategoryId  INT  = -999,
    @SubCatId    INT  = -999
)
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH ItemScope AS
    (
        -- In-scope items only (sargable optional filters; RECOMPILE picks the plan).
        SELECT IH.Id, IH.StockItemCode, IH.Name
        FROM dbo.StockItemHeaders AS IH WITH (NOLOCK)
        WHERE (@StockItemID = -999 OR IH.Id            = @StockItemID)
          AND (@CategoryId  = -999 OR IH.CategoryID    = @CategoryId)
          AND (@SubCatId    = -999 OR IH.SubCategoryID = @SubCatId)
    ),
    Moves AS
    (
        -- Movements within the window, aggregated once per item in BOTH qty and value.
        SELECT D.StockItemID,
               GRNq = SUM(CASE WHEN H.TransactionType = 'GR' THEN D.Quantity               ELSE 0 END),
               GRNv = SUM(CASE WHEN H.TransactionType = 'GR' THEN D.Quantity * D.UnitPrice ELSE 0 END),
               TIq  = SUM(CASE WHEN H.TransactionType = 'TI' THEN D.Quantity               ELSE 0 END),
               TIv  = SUM(CASE WHEN H.TransactionType = 'TI' THEN D.Quantity * D.UnitPrice ELSE 0 END),
               TOq  = SUM(CASE WHEN H.TransactionType = 'TO' THEN D.Quantity               ELSE 0 END),
               TOv  = SUM(CASE WHEN H.TransactionType = 'TO' THEN D.Quantity * D.UnitPrice ELSE 0 END),
               INq  = SUM(CASE WHEN H.TransactionType = 'IN' THEN D.Quantity               ELSE 0 END),
               INv  = SUM(CASE WHEN H.TransactionType = 'IN' THEN D.Quantity * D.UnitPrice ELSE 0 END),
               IFq  = SUM(CASE WHEN H.TransactionType = 'IF' THEN D.Quantity               ELSE 0 END),
               IFv  = SUM(CASE WHEN H.TransactionType = 'IF' THEN D.Quantity * D.UnitPrice ELSE 0 END),
               IRq  = SUM(CASE WHEN H.TransactionType = 'IR' THEN D.Quantity               ELSE 0 END),
               IRv  = SUM(CASE WHEN H.TransactionType = 'IR' THEN D.Quantity * D.UnitPrice ELSE 0 END),
               DAMq = SUM(CASE WHEN H.TransactionType = 'DN' THEN D.Quantity               ELSE 0 END),
               DAMv = SUM(CASE WHEN H.TransactionType = 'DN' THEN D.Quantity * D.UnitPrice ELSE 0 END),
               SRq  = SUM(CASE WHEN H.TransactionType = 'SR' THEN D.Quantity               ELSE 0 END),
               SRv  = SUM(CASE WHEN H.TransactionType = 'SR' THEN D.Quantity * D.UnitPrice ELSE 0 END)
        FROM dbo.StockTransactionDetails AS D WITH (NOLOCK)
        INNER JOIN dbo.StockTransactionHeaders AS H WITH (NOLOCK)
               ON H.Id = D.StockTransactionHeaderID
        INNER JOIN ItemScope AS S
               ON S.Id = D.StockItemID
        WHERE H.LocationID = @LocationID
          AND H.TransactionDate BETWEEN @DateFrom AND @DateTo
        GROUP BY D.StockItemID
    )
    SELECT
        S.Id                                   AS StockItemID,
        S.StockItemCode,
        S.Name,
        U.Name                                 AS UnitName,
        OpeingBalance       = CAST(CASE WHEN @byValue = 1 THEN B.OpeningVal ELSE B.OpeningQty END AS DECIMAL(18,6)),
        -- Movement columns follow the @byValue display toggle (qty when 0, value when 1).
        GRN  = CASE WHEN @byValue = 1 THEN M.GRNv ELSE M.GRNq END,
        TI   = CASE WHEN @byValue = 1 THEN M.TIv  ELSE M.TIq  END,
        [TO] = CASE WHEN @byValue = 1 THEN M.TOv  ELSE M.TOq  END,
        [IN] = CASE WHEN @byValue = 1 THEN M.INv  ELSE M.INq  END,
        [IF] = CASE WHEN @byValue = 1 THEN M.IFv  ELSE M.IFq  END,
        [IR] = CASE WHEN @byValue = 1 THEN M.IRv  ELSE M.IRq  END,
        DAM  = CASE WHEN @byValue = 1 THEN M.DAMv ELSE M.DAMq END,
        SR   = CASE WHEN @byValue = 1 THEN M.SRv  ELSE M.SRq  END,
        ClosingBalance      = CAST(CASE WHEN @byValue = 1 THEN B.ClosingVal ELSE B.ClosingQty END AS DECIMAL(18,2)),
        ClosingBalanceValue = CAST(B.ClosingVal AS DECIMAL(18,6)),
        -- Usage straight from the TVF (always computed in both terms).
        UsageQuantity = B.UsageQuantity,
        UsageValue    = B.UsageValue
    FROM Moves AS M
    INNER JOIN ItemScope AS S
           ON S.Id = M.StockItemID
    INNER JOIN dbo.StockItemDetails AS ID WITH (NOLOCK)
           ON ID.StockItemHeaderID = S.Id AND ID.LocationID = @LocationID
    INNER JOIN dbo.Units AS U WITH (NOLOCK)
           ON U.Id = ID.MasterUnitID
    -- Opening/closing balances + usage per item (inline TVF, always returns one row).
    CROSS APPLY dbo.FN_GetItemUsage_TVF(@DateFrom, @DateTo, S.Id, @LocationID) AS B
    OPTION (RECOMPILE);
END

GO

