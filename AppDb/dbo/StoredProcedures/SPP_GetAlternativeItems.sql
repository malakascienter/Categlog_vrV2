
CREATE  PROCEDURE [dbo].[SPP_GetAlternativeItems] 
@ItemID INT,
@propertyID INT,
@LocationID INT 	
	
AS
BEGIN
	
	SELECT AG.Id,AGD1.ItemId,SIH.name,SD.AveragePrice FROM dbo.AltItemGroupDetails AS AGD INNER JOIN dbo.AltItemGroups AS AG ON AG.Id=AGD.GroupID   INNER JOIN dbo.AltItemGroupDetails AS AGD1 ON AGD1.GroupID=AG.Id INNER JOIN stockitemheaders AS SIH ON SIH.Id=AGD1.ItemId INNER JOIN dbo.StockItemDetails AS SD ON SD.StockItemId=SIH.Id WHERE AGD.ItemId=@ItemID AND SD.propertyID=@propertyID AND SD.LocationID=@LocationID
	
END

GO

