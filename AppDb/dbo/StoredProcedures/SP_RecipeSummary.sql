-- =============================================
-- Author:      Ravindu
-- Create date: 2026-01-09
-- Description: Get item wise summary 
-- =============================================
-- EXEC [dbo].[SP_RecipeSummary] N'[{"PropertyId":1,"LocationId":8,"ApproveItem":[{"StockItemId":51167,"TotalQty":160.0}],"ManualItem":[{"StockItemId":10343,"TotalQty":50.0}]}]';

CREATE PROCEDURE [dbo].[SP_RecipeSummary] 
    @SummaryItemListJson NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @LocationId INT,@CompanyId INT

        
        IF OBJECT_ID('tempdb..#FnalSelect') IS NOT NULL
        DROP TABLE #FnalSelect

        IF OBJECT_ID('tempdb..#SummaryItemHeader') IS NOT NULL
        DROP TABLE #SummaryItemHeader

        IF OBJECT_ID('tempdb..#ApproveItemDetail') IS NOT NULL
        DROP TABLE #ApproveItemDetail

        IF OBJECT_ID('tempdb..#ManualItemDetail') IS NOT NULL
        DROP TABLE #ManualItemDetail

        CREATE TABLE #SummaryItemHeader (
            PropertyId INT,
            LocationId INT
        );

        CREATE TABLE #ApproveItemDetail (
            StockItemId INT,
            TotalQty DECIMAL(18,2)
        );

        CREATE TABLE #ManualItemDetail (
            StockItemId INT,
            TotalQty DECIMAL(18,2)
        );

         CREATE TABLE #ItemDetail (
            StockItemId INT,
            TotalQty DECIMAL(18,2)
        );

        INSERT INTO #SummaryItemHeader(PropertyId, LocationId)
        SELECT
            JSON_VALUE([value], '$.PropertyId') AS PropertyId,
            JSON_VALUE([value], '$.LocationId') AS LocationId
        FROM OPENJSON(@SummaryItemListJson);


        INSERT INTO #ApproveItemDetail(StockItemId, TotalQty)
        SELECT
            JSON_VALUE(child.[value], '$.StockItemId') AS StockItemId,
            JSON_VALUE(child.[value], '$.TotalQty') AS TotalQty
        FROM OPENJSON(@SummaryItemListJson) AS parent
        CROSS APPLY OPENJSON(parent.[value], '$.ApproveItem') AS child;

       
        INSERT INTO #ManualItemDetail(StockItemId, TotalQty)
        SELECT
            JSON_VALUE(child.[value], '$.StockItemId') AS StockItemId,
            JSON_VALUE(child.[value], '$.TotalQty') AS TotalQty
        FROM OPENJSON(@SummaryItemListJson) AS parent
        CROSS APPLY OPENJSON(parent.[value], '$.ManualItem') AS child;



        Select @LocationId = LocationId,@CompanyId = PropertyId 
        from #SummaryItemHeader;
        
        INSERT INTO #ItemDetail(StockItemId,TotalQty)
        SELECT StockItemId,SUM(TotalQty) TotalQty
        FROM #ApproveItemDetail
        GROUP  BY StockItemId
        UNION 
        
        SELECT StockItemId,SUM(TotalQty) TotalQty
        FROM #ManualItemDetail
        GROUP  BY StockItemId

      


        SELECT D.StockItemId, U.Name AS Unit,U.Id AS UnitId,
    --    SUM(D.Quantity * PID.TotalQty) AS Qty,
     --  SUM( (dbo.FN_GetUnitConvertionRate(@CompanyId,d.UnitId,dbo.FN_GetMasterUnitID(@CompanyId,@LocationID, D.StockItemId)) * D.Quantity)* PID.TotalQty) Qty,
       SUM((dbo.FN_GetUnitConvertionRate(@CompanyId,d.UnitId,dbo.FN_GetMasterUnitID(@CompanyId,@LocationID, D.StockItemId)) * D.Quantity)* PID.TotalQty)
	   *(dbo.FN_GetUnitConvertionRate(@CompanyId,H.UnitId,I.UnitId) / I.Quantity) Qty,

        SH.Name AS ItemName
        INTO #FnalSelect
		FROM Inv_ItemWiseRecipes I
		INNER JOIN Inv_RecipeHeader H ON H.Id = I.RecipeId
		INNER JOIN Inv_RecipeDetails d ON D.RecipeHeaderId = H.Id 
		INNER JOIN StockItemHeaders SH ON SH.Id = D.StockItemId
		INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = Sh.Id AND SD.LocationID = @LocationId
        INNER JOIN Units U ON U.Id = SD.MasterUnitID
        INNER JOIN #ItemDetail PID ON PID.StockItemId = I.StockItemId
		WHERE  I.CompanyId = @CompanyId
        GROUP BY D.StockItemId, U.Name,U.Id,D.Quantity,PID.TotalQty,SH.Name,d.UnitId,h.UnitId,I.UnitId,I.Quantity

        SELECT StockItemId,Unit,UnitId,SUM(Qty) Qty,ItemName
        FROM #FnalSelect
        GROUP BY StockItemId,Unit,UnitId,ItemName

    END TRY
    BEGIN CATCH
        DECLARE 
            @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (
            'SP_RecipeSummary failed: %s',
            @ErrorSeverity,
            @ErrorState,
            @ErrorMessage
        );
    END CATCH
END

GO

