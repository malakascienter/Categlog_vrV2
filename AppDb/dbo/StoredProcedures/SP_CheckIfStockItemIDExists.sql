-- =============================================
-- Author:		Vinuki 
-- Create date: 20.05.2024
-- Description:	
-- =============================================
--exec SP_CheckIfStockItemIDExists 1,'ENG/MCV/00333'
CREATE PROCEDURE [dbo].[SP_CheckIfStockItemIDExists] (@PropertyId int,@StockItemCode VARCHAR(20))

AS
BEGIN
SELECT SD.[Id] AS HeadID      
      ,SD.[Id] AS DeatailID
	  ,SH.Name AS HeadName
	  ,'' AS DeatailName
  FROM StockItemDetails AS SD 
  INNER JOIN Units AS U ON SD.MasterUnitID=U.Id  
  INNER JOIN StockItemHeaders AS SH ON SD.StockItemHeaderID=SH.Id AND  SH.CompanyId=@PropertyId
  INNER JOIN Locations L ON SD.LocationID = L.Id AND SD.CompanyID = L.CompanyID 
  WHERE SD.CompanyID=@PropertyId  AND SD.IsActive=1 AND SH.StockItemCode = @StockItemCode 
END

GO

