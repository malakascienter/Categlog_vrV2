-- exec SP_Get_ProductionConsolidateRecipeSummary  3

CREATE PROCEDURE [dbo].[SP_Get_ProductionConsolidateRecipeSummary]
@ProdConsolidateHeaderID  BIGINT
AS
BEGIN

	SET NOCOUNT ON;

    SELECT SH.Id AS ItemId,SH.StockItemCode AS ItemCode,SH.Name AS ItemName,U.Id AS UnitId,U.Name AS UnitName,PS.ProductionQuantity as ConvertedQuanity,
	PS.ProductionQuantity - ISNULL(PS.ProceedQty,0) as ChangeQuanity
	FROM ProductionConsolidateDetails PS 
	INNER JOIN Units U ON PS.MasterUnitID = U.Id 
	inner join StockItemHeaders SH ON PS.StockItemID = SH.Id
	WHERE PS.HeaderID = @ProdConsolidateHeaderID AND IsProductionProcess = 0

END

GO

