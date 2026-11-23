
-- =============================================  
-- Author:  Ovanthi Napevithanage  
-- Create date: jULY 24, 2018  
-- Description: Waiter_M_Select  
-- =============================================  
CREATE PROCEDURE [dbo].[Waiter_M_Select]  
@Active INT = 2  ,
@PropertyId INT
AS  
BEGIN  
   SELECT * FROM Waiter AS W 
	WHERE  PropertyId=@PropertyId AND (@Active = 2 OR Active = @Active) AND IsDeleted = 0
END

GO

