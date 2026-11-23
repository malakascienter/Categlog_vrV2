CREATE procedure [dbo].[ProjectItemWiseSupplierPricesForApproval]
@ProjectID INT
AS
BEGIN

	select distinct ST.Id,ST.name from ProjectWiseSupplierPrices as PW 
	INNER join Stockitemheaders as ST on PW.StockItemID= ST.Id 
	WHERE PW.ProjectID=@ProjectID AND(PW.Status IS NULL OR PW.Status = 'P')


END

GO

