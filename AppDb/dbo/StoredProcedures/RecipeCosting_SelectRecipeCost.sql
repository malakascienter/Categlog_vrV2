CREATE PROCEDURE [dbo].[RecipeCosting_SelectRecipeCost]
    @MenuItemCode CHAR(4),
    @LocationId   INT,
    @PropertyId   INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        RTRIM(mm.ItemCode)                                  AS MenuCode,
        mm.Description                                      AS MenuName,
        RTRIM(ibd.RecipeCode)                               AS RecipeCode,
        sih.StockItemCode                                   AS StockItemCode,
        sih.Name  + ' : Recipe Unit - ' + (SELECT top(1) Name FROM Units WHERE ID = rd.Unit) AS StockItemName,
		([dbo].[FN_GetUnitConvertionRate](@PropertyId, grn.TxnUnitID, rd.Unit))  as ConvertionRate,
		grn.LastGRNPrice as CheckLastGRNPrice,
		CAST(
		grn.LastGRNPrice /
		NULLIF([dbo].[FN_GetUnitConvertionRate](@PropertyId, grn.TxnUnitID, rd.Unit), 0)
		AS DECIMAL(18,4)) AS LastGRNPrice,

		CAST(
			sid.AveragePrice /
			NULLIF([dbo].[FN_GetUnitConvertionRate](@PropertyId, sid.MasterUnitID, rd.Unit), 0)
		AS DECIMAL(18,4)) AS AveragePrice,

		CAST(rd.Qty * ibd.Qty AS DECIMAL(18,4)) AS RecipeQty,

		CAST(
			(
				grn.LastGRNPrice /
				NULLIF([dbo].[FN_GetUnitConvertionRate](@PropertyId, grn.TxnUnitID, rd.Unit), 0)
			) * rd.Qty * ibd.Qty
		AS DECIMAL(18,4)) AS TotalLastGRN,

		CAST(
			(
				sid.AveragePrice /
				NULLIF([dbo].[FN_GetUnitConvertionRate](@PropertyId, sid.MasterUnitID, rd.Unit), 0)
			) * rd.Qty * ibd.Qty
		AS DECIMAL(18,4)) AS TotalAverage
    FROM dbo.ItemBreakDown ibd
        INNER JOIN dbo.MainMenu mm
            ON mm.ItemCode = ibd.MainMenuCode
        INNER JOIN dbo.RecipeDetails rd
            ON rd.RecipeCode = ibd.RecipeCode
		inner join RecipeHeader rh on rh.RecipeCode = rd.RecipeCode
        INNER JOIN dbo.StockItemHeaders sih
            ON sih.Id = rd.StockItemCode      -- RecipeDetails.StockItemCode holds StockItemHeaders.Id
        OUTER APPLY
        (
            SELECT TOP (1) d.AveragePrice,d.MasterUnitID
            FROM dbo.StockItemDetails d
            WHERE d.StockItemHeaderID = sih.Id
              AND d.LocationID = @LocationId
              AND d.IsActive = 1
            ORDER BY d.Id DESC
        ) sid
        OUTER APPLY
        (
            SELECT TOP (1)
                   std.UnitPrice  AS LastGRNPrice,std.TxnUnitID
            FROM dbo.StockTransactionDetails std
                INNER JOIN dbo.StockTransactionHeaders sth
                    ON sth.Id = std.StockTransactionHeaderID
            WHERE std.StockItemID = sih.Id
              AND sth.TransactionType = 'GR'
              AND sth.LocationID = @LocationId
            ORDER BY sth.TransactionDate DESC, std.Id DESC
        ) grn
    WHERE ibd.MainMenuCode = @MenuItemCode
      AND (@PropertyId IS NULL OR ibd.PropertyId IS NULL OR ibd.PropertyId = @PropertyId)
    ORDER BY rd.Seq, sih.Name;
END

GO

