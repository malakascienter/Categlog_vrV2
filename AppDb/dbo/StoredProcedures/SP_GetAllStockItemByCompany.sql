create PROCEDURE [dbo].[SP_GetAllStockItemByCompany]
	@PropertyId INT =1
AS
BEGIN
	SELECT SH.Id, SH.Name as ItemName FROM StockItemHeaders SH WHERE (CompanyId = @PropertyId)  ORDER BY SH.Name
END

GO

