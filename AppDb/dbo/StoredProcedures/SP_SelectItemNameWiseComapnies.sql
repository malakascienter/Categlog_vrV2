--[dbo].[SP_SelectItemNameWiseComapnies] 1108
--[dbo].[SP_SelectItemNameWiseComapnies] 1,1
--go
CREATE PROCEDURE [dbo].[SP_SelectItemNameWiseComapnies](@LocationId INT, @PropertyID INT =1)
AS
BEGIN	
	SELECT distinct SH.Id,SH.Name,SH.StockItemCode
FROM StockItemHeaders SH
INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID
WHERE SD.LocationID = @LocationId
AND SH.CompanyId = @PropertyID AND SD.IsActive = 1
END

GO

