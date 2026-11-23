-- [dbo].[SP_RecallHeaderDetails] 9
CREATE PROCEDURE [dbo].[SP_RecallHeaderDetails]
	@headerID int
AS
BEGIN
------------------------------------------------------------------------------------
BEGIN TRY 
SELECT RD.RequestedQuantity, RD.UnitPrice, (SELECT U.Name FROM dbo.Units AS U WHERE RD.UnitID=u.Id ) AS UnitName, SID.Name AS ItemName, RD.StockItemID,CASE WHEN rd.ApprovedQuantity= 0 THEN Rd.requestedQuantity ELSE  rd.ApprovedQuantity END ApprovedQuantity,
	rd.id AS RequestDetailID, RD.Id, RD.RequestedQuantity - RD.IssuedQuantity AS BalanceQuantity, D.Name AS DepartmentName, RD.IssuedQuantity,
	--dbo.GetStockInHand(RH.PropertyID,RH.LocationID,RD.StockItemID) AS StockInHand
	dbo.[FN_GetStockInHand_Reatils](RH.PropertyID,RH.LocationID,RD.StockItemID) AS StockInHand
	,RD.Remarks
	FROM dbo.RequestDetails AS RD 
	INNER JOIN dbo.StockItemHeaders AS SID ON RD.StockItemID = SID.Id
	INNER JOIN dbo.RequestHeaders RH ON RH.Id = RD.RequestHeaderID
	LEFT JOIN dbo.Departments D ON D.Id = RH.DepartmentID
	WHERE RD.RequestHeaderID = @headerID
END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;
------------------------------------------------------------------------------------
	
END

GO

