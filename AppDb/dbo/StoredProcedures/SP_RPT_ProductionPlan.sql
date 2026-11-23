-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-05-22
-- Description:	Production Plan Report view
/**
 EXEC [dbo].[SP_RPT_ProductionPlan] 1,'H'
 EXEC [dbo].[SP_RPT_ProductionPlan] 1,'D'

 EXEC [dbo].[SP_RPT_ProductionPlan] 1,'PS'
 EXEC [dbo].[SP_RPT_ProductionPlan] 1,'PD'


  EXEC [dbo].[SP_RPT_ProductionPlan] 1,'L'
 **/
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_ProductionPlan]
	@HeaderID INT,
	@Mode CHAR(2)
AS
BEGIN
	SET NOCOUNT ON;

	IF(@Mode = 'H')
	BEGIN
		SELECT DISTINCT PH.ID HeaderID,LO.Name Location,CO.Name CompanyName,PH.DocumentNo,
		CASE WHEN PH.Status ='P' THEN 'Pending' WHEN PH.Status = 'C' THEN 'Complete' END AS Status,
		PH.TxnDate,PH.RequestedDate
		FROM ProductionConsolidateHeader PH
		
		INNER JOIN Locations LO ON LO.Id = PH.LocationID 
		INNER JOIN Companies CO ON CO.CompanyID = PH.PropertyID
		INNER JOIN CentralUsers CU ON CU.Id = PH.UserID
		--INNER JOIN 
		WHERE PH.ID = @HeaderID

	END

	IF(@Mode = 'D')
	BEGIN
		SELECT DISTINCT PH.ID HeaderID,SH.StockItemCode,SH.Name ItemName,PD.RequestedQTY,PD.ProductionQuantity,PD.ProceedQty,UN.Name MasterUnit,STH.DocumentNo ProductionDocument,
		CASE WHEN PD.IsProductionProcess = 0 THEN 'Pending' ELSE 'Complete' END AS ProductionProcess
		FROM ProductionConsolidateHeader PH
		INNER JOIN ProductionConsolidateDetails PD ON PH.ID = PD.HeaderID 
		INNER JOIN StockItemHeaders SH ON SH.Id = PD.StockItemID
		INNER JOIN Units UN ON UN.Id = PD.MasterUnitID
		LEFT JOIN StockTransactionHeaders STH ON STH.ID = PD.TransactionRefId AND STH.TransactionType = 'PU'
		WHERE PH.ID = @HeaderID

	END

	IF(@Mode = 'L')
	BEGIN
		SELECT DISTINCT PH.ID HeaderID,CH.TxnNo ProductionRequestDocNO,LO.Name RequestedLocation,SH.StockItemCode,SH.Name ItemName,UN.Name RequestUnit,PL.ConvertedQuantity RequestedQTY
		FROM ProductionConsolidateHeader PH
		INNER JOIN ProductionConsolidateLocationWise PL ON PL.ProductionConsolidateHeaderID = PH.ID
		INNER JOIN CommiRequestHeader CH ON CH.ID = PL.CommiRequestHeaderID AND CH.RequestedLocationID = PL.RequestedLocationID
		INNER JOIN Locations LO ON LO.ID = PL.RequestedLocationID
		INNER JOIN StockItemHeaders SH ON SH.Id = PL.StockItemID
		INNER JOIN Units UN ON UN.Id = PL.UnitID
		WHERE PH.ID = @HeaderID
	END

	IF(@Mode='PS')
	BEGIN
		SELECT DISTINCT  PS.ProductionConsolidateHeaderID HeaderID,SH.StockItemCode,SH.Name ItemName,UN.Name UnitName,PS.ConvertedQuanity,PS.RecievedQuantity
		FROM ProductionConsolidateRecipeSummary PS
		INNER JOIN StockItemHeaders SH ON SH.Id = PS.RecipeItemID
		INNER JOIN Units UN ON UN.Id = PS.MasterUnitID
		WHERE PS.ProductionConsolidateHeaderID= @HeaderID
	END

	IF(@Mode = 'PD')
	BEGIN
		SELECT PD.ProductionConsolidateHeaderID HeaderID,SIH.StockItemCode ProductionItemCode,SIH.Name ProductionItemName,UN.Name ProductionUnit,CD.ProductionQuantity,
		RH.RecipeCode,RH.RecipeName,SIH2.StockItemCode RecipeItemCode ,SIH2.Name RecipeItemName,UN2.Name RecipeUnit,PD.ConvertedQuanity
		FROM ProductionConsolidateRecipeDetails PD
		INNER JOIN ProductionConsolidateDetails CD ON CD.HeaderID = PD.ProductionConsolidateHeaderID AND PD.ProductionItemID = CD.StockItemID
		INNER JOIN StockItemHeaders SIH ON SIH.ID = PD.ProductionItemID
		INNER JOIN Inv_RecipeHeader RH ON RH.Id = PD.RecipeHeaderId
		INNER JOIN StockItemHeaders SIH2 ON SIH2.ID = PD.RecipeItemID
		INNER JOIN Units UN ON UN.Id = CD.MasterUnitID
		INNER JOIN Units UN2 ON UN2.Id = PD.MasterUnitID
		 WHERE PD.ProductionConsolidateHeaderID= @HeaderID

		



		--SELECT DISTINCT PD.ProductionConsolidateHeaderID HeaderID,CH.TxnNo ProductionRequestDocNO,lo.Name RequestLocation,RH.RecipeCode,RH.RecipeName,sih.StockItemCode ProductionItemCode
		--,SIH.Name ProductionItemName,UN.Name ProductionUnit,CRD.RequestedQTY ProductionQuantity,SIH2.StockItemCode RecipeItemCode,SIH2.Name RecipeItemName,UN2.Name RecipeUnit,PD.ConvertedQuanity RecipeQuantity
		--FROM ProductionConsolidateRecipeDetails PD
		--INNER JOIN ProductionConsolidateDetails CD ON CD.HeaderID = PD.ProductionConsolidateHeaderID AND PD.ProductionItemID = CD.StockItemID
		--INNER JOIN CommiRequestHeader CH ON CH.ID = PD.CommiRequestHeaderID
		--INNER JOIN CommiRequestDetails CRD ON CRD.HeaderID = CH.ID AND CD.StockItemID = CRD.StockItemID
		--INNER JOIN Locations LO ON LO.Id = PD.RequestedLocationID
		--INNER JOIN Inv_RecipeHeader RH ON RH.Id = PD.RecipeHeaderId
		--INNER JOIN StockItemHeaders SIH ON SIH.Id = CD.StockItemID
		--INNER JOIN StockItemHeaders SIH2 ON SIH2.Id = PD.RecipeItemID
		--INNER JOIN Units UN ON UN.Id = CD.MasterUnitID
		--INNER JOIN Units UN2 ON UN2.Id = PD.MasterUnitID
		--WHERE PD.ProductionConsolidateHeaderID= @HeaderID

	END
	
    
END

GO

