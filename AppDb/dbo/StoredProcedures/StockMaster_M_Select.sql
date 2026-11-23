

-- =============================================
-- Author:		Chiraj
-- Create date: 2018-11-12
-- Description:	StockMaster_M_Select
-- =============================================
--[dbo].[StockMaster_M_Select]1,2
CREATE PROCEDURE  [dbo].[StockMaster_M_Select]--24,1
	@Location int,
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;
	--SELECT  RTRIM(ItemNo)AS ItemNo,Description,Location,Active,Unit    
  --FROM StockMaster WHERE  Active=1 AND Location=@Location
  /****** Script for SelectTopNRows command from SSMS  ******/
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

