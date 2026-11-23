-- =============================================  
-- Author:  Yasiru  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
--[dbo].[DocTypeTemplateHeaders_M_SelectByTemplateIdAndLocationId]2,2
CREATE PROCEDURE [dbo].[Location_M_Select]-- 1,1
@Active INT=2 ,
@PropertyId INT
  
AS  
BEGIN  
 SELECT *  FROM Locations  
  WHERE CompanyID=@PropertyId AND (@Active=2 OR IsActive=@Active)
  
END

GO

