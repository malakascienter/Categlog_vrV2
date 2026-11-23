-- =============================================
-- Author:		Isuru Pramodya
-- Create date:2026-04-24
-- Description:	Load Production Plan Listing
-- [dbo].[SP_RPT_ProductionPlanListing]  '2026-01-01','2026-04-30',8

-- =============================================
CREATE   PROCEDURE [dbo].[SP_RPT_ProductionPlanListing] 
@DateFrom DATE='2020/08/01', 
@DateTo DATE='2020/10/10', 
@LocationID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT LO.Name LocationName,PH.DocumentNo,PH.TxnDate,CU.UserName,SIH.StockItemCode,SIH.Name ItemName,UN.Name UnitName,PD.ProductionQuantity,PD.ProceedQty
	FROM ProductionConsolidateHeader PH
	INNER JOIN ProductionConsolidateDetails PD ON PH.ID = PD.HeaderID
	INNER JOIN StockItemHeaders SIH ON SIH.ID = PD.StockItemID
	INNER JOIN Locations LO ON LO.ID = PH.LocationID
	INNER JOIN Units UN ON UN.ID = PD.MasterUnitID
	INNER JOIN CentralUsers CU ON CU.ID = PH.UserID
	WHERE PH.TxnDate BETWEEN @DateFrom AND @DateTo
	AND PH.LocationID = @LocationID
	ORDER BY PH.SysDateTime 
   

END

GO

