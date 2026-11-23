CREATE PROCEDURE [dbo].[GetProjectWisePricesForApproval]
@SupplierID INT , @ProjectId INT
As
Begin

	select PW.Id,PW.SupplierID,PW.StockItemID,PW.Price,SH.Name from ProjectWiseSupplierPrices  as PW
	inner join  StockItemHeaders as SH on PW.StockItemID=SH.Id  where  PW.SupplierID= @SupplierID and PW.ProjectID=@ProjectID



End

GO

