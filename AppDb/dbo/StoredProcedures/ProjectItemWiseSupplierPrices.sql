
-- ProjectItemWiseSupplierPrices 2
CREATE procedure [dbo].[ProjectItemWiseSupplierPrices]
@ProjectID INT
AS
BEGIN

	select distinct ST.Id,ST.name from ProjectWiseSupplierPrices as PW 
	INNER join Stockitemheaders as ST on PW.StockItemID= ST.Id 
	WHERE PW.ProjectID=@ProjectID AND(PW.Status IS NULL OR PW.Status = 'X')


END

GO

