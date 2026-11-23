CREATE PROCEDURE [dbo].[SP_GetAllPendingItemWiseLocations](@ReqItemHeaderId INT )

AS
BEGIN

	DECLARE @propertyID  INT 
	SELECT TOP 1 @propertyID   = [PropertyId]
	FROM [dbo].TempStockItemRequest WHERE id = @ReqItemHeaderId
 
 
	SELECT L.id , L.Name AS  text , CASE WHEN TS.LocationId IS NULL THEN 0 ELSE 1 END isSelected
	FROM dbo.Locations L 
	LEFT outer JOIN (SELECT * FROM [dbo].[TempStockItemRequestWiseLocations] WHERE [StockItemRequestId] = @ReqItemHeaderId)  TS ON TS.LocationId = L.Id
	WHERE L.CompanyID = @propertyID

END

GO

