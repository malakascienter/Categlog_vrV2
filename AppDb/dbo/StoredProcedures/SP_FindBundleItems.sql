CREATE procedure [dbo].[SP_FindBundleItems] 
@ID int 
AS 

BEGIN TRY
BEGIN TRANSACTION


select DISTINCT(BI.BundleStockItemHeaderId) , BI.Id AS Id,BI.DetailStockItemHeaderId,BI.Quantity,ST.Name,St.StockItemCode AS UnitName
from BundleItems AS BI inner join StockItemHeaders AS ST ON BI.DetailStockItemHeaderId=ST.Id
where BundleStockItemHeaderId=@ID

COMMIT TRAN 
END TRY
BEGIN CATCH
	return CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN 
END CATCH

--SP_FindBundleItems 56

GO

