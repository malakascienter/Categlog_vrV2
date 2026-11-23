-- [dbo].[SP_QuotationWisePurchaseRequestionDetail] 1,1
CREATE PROCEDURE [dbo].[SP_QuotationWisePurchaseRequestionDetail]
	@headerID INT,
	@PropertyID INT
AS
BEGIN
------------------------------------------------------------------------------------
BEGIN TRY 
SELECT RD.Id RequestDetailID,RD.RequestHeaderID,SID.Id ItemID,RD.UnitID, SID.Name ItemName, SID.StockItemCode, (SELECT U.Name FROM dbo.Units AS U WHERE RD.UnitID=u.Id ) AS UnitName, CASE WHEN rd.ApprovedQuantity= 0 THEN Rd.requestedQuantity ELSE  rd.ApprovedQuantity END ApprovedQuantity
	FROM dbo.RequestDetails AS RD 
	INNER JOIN dbo.StockItemHeaders AS SID ON RD.StockItemID = SID.Id
	INNER JOIN dbo.RequestHeaders RH ON RH.Id = RD.RequestHeaderID
	WHERE RD.RequestHeaderID = @headerID AND RH.PropertyID = @PropertyID AND RH.RequestType = 'RP'
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

