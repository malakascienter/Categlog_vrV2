--[dbo].[CostingSetting_M_Select]  2,2
CREATE PROCEDURE [dbo].[CostingSetting_M_Select]   
--@isActive INT=2,
@PropertyId INT
AS  
BEGIN  

 
 SELECT *   FROM CostingSetting  
  WHERE  PropertyId=@PropertyId AND Active=1 --AND (@IsActive=2 OR Active=@isActive)

  
END

GO

