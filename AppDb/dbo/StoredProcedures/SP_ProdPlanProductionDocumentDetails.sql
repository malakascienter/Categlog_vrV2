--EXEC [SP_ProdPlanProductionDocumentDetails] 1,'64'
CREATE PROCEDURE [dbo].[SP_ProdPlanProductionDocumentDetails]
	@PropertyID INT,
	@TransactionIds VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;


	SELECT  STH.Id AS PU_Id, 
			STH.DocumentNo AS PU_DocumentNo,
			STH.TransactionDate AS PU_TransactionDate,
			L.Name AS PU_LocationName,
			SH.StockItemCode AS PU_StockItemCode,
			SH.Name AS PU_ItemName,
			U.Name AS PU_TxnUnitName,
			STD.Quantity AS PU_TxnQty,
			STD.UnitPrice AS PU_UnitPrice,
			PCD.ProductionQuantity AS PU_ProductionQuantity
	INTO #TempProdOutDtails
	FROM StockItemHeaders SH
	INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID	
	INNER JOIN Categories CA ON CA.Id = SH.CategoryID
	INNER JOIN StockTransactionHeaders STH ON SD.LocationID = STH.LocationID AND SH.CompanyId = STH.PropertyID
	INNER JOIN StockTransactionDetails STD ON STH.Id = STD.StockTransactionHeaderID AND STD.StockItemID = SD.StockItemHeaderID
	INNER JOIN Locations L ON STH.LocationID = L.Id
	INNER JOIN Units U ON U.Id = STD.TxnUnitID
	LEFT JOIN ProductionConsolidateDetails PCD on STH.Id = PCD.TransactionRefId AND PCD.StockItemID = STD.StockItemID
	WHERE STH.Id IN (SELECT * FROM STRING_SPLIT(@TransactionIds,',')) 




	SELECT  PU.*,STH.Id AS PI_Id, 
			STH.DocumentNo AS PI_DocumentNo,
			STH.TransactionDate AS PI_TransactionDate,
			L.Name AS PI_LocationName,
			SH.StockItemCode AS PI_StockItemCode,
			SH.Name AS PI_ItemName,
			U.Name AS PI_TxnUnitName,
			STD.Quantity AS PI_TxnQty,
			STD.UnitPrice AS PI_UnitPrice,
			PU.PU_UnitPrice
	FROM StockItemHeaders SH
	INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID	
	INNER JOIN Categories CA ON CA.Id = SH.CategoryID
	INNER JOIN StockTransactionHeaders STH ON SD.LocationID = STH.LocationID AND SH.CompanyId = STH.PropertyID
	INNER JOIN StockTransactionDetails STD ON STH.Id = STD.StockTransactionHeaderID AND STD.StockItemID = SD.StockItemHeaderID
	INNER JOIN Locations L ON STH.LocationID = L.Id
	INNER JOIN Units U ON U.Id = STD.TxnUnitID
	INNER JOIN #TempProdOutDtails PU ON PU.PU_Id = STH.ReferenceID
	WHERE STH.TransactionType = 'PI' 




	DROP TABLE #TempProdOutDtails

END

GO

