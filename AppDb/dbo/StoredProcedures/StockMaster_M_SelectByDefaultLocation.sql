
CREATE PROCEDURE  [dbo].[StockMaster_M_SelectByDefaultLocation]
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;

DECLARE @Location INT
SELECT TOP(1) @Location = Id FROM Locations WHERE CompanyID = @PropertyId AND DefaultLocation = 1

SELECT SD.[Id]      
      ,SD.[CompanyID]
      ,SD.[LocationID]
      ,SD.[StockItemHeaderID]
      ,SD.[MasterUnitID]      
      ,SD.[IsActive]      
      ,SD.[StockItemId]   
	  ,U.Id AS UnitId
	  --,U.Code AS Unit
	   ,U.Name AS Unit
	  ,U.Name
	  ,CONCAT(SH.Name,'-',SH.StockItemCode) AS ItemName
  FROM StockItemDetails AS SD 
  INNER JOIN Units AS U ON SD.MasterUnitID=U.Id  
  INNER JOIN StockItemHeaders AS SH ON SD.StockItemHeaderID=SH.Id AND  SH.CompanyId=@PropertyId
  WHERE SD.CompanyID=@PropertyId AND SD.LocationID=@Location AND SD.IsActive=1 AND U.IsActive=1

END

GO

