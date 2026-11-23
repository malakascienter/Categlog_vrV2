-- =============================================  
-- Author:  Yasiru  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
--[UserWiseIndividualAccess_M_Select_ById]   27, 1, 2
CREATE PROCEDURE [dbo].[UserWiseIndividualAccess_M_Select_ById]  
@UserId     INT,  
@MainNavigationId INT  ,
@PropertyId INT
  
AS  
BEGIN   
 SET NOCOUNT ON;  
  IF EXISTS(SELECT 1 FROM UserWiseIndividualAccess  Where UserId = @UserId AND PropertyId=@PropertyId  )--AND MainNavigationId = @MainNavigationId
  BEGIN
		SELECT *,( select AccessCodeId from POS_UserAccessTemp where PropertyId=@PropertyId and UserId=@UserId for json auto )as posaccessjson 
		FROM UserWiseIndividualAccess  
		Where UserId = @UserId AND PropertyId=@PropertyId --AND MainNavigationId = @MainNavigationId		
  END
  ELSE
  BEGIN
  DECLARE @jsondata NVARCHAR(MAX) = (select AccessCodeId from POS_UserAccessTemp where PropertyId=@PropertyId and UserId=@UserId for json auto)  
  select @jsondata as posaccessjson
  END
 
  
 

END

GO

