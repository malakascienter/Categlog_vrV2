
-- =============================================  
-- Author:  Chiraj  
-- Create date: 2018-10-22  
-- Description: Select Action Button Template  
-- =============================================  
CREATE PROCEDURE [dbo].[Select_ActionButtonTemplate]   
   @PropertyId INT
AS  
BEGIN   
 SET NOCOUNT ON;  
	SELECT DISTINCT ID,Name   
	FROM ActionTemplate  where PropertyId=@PropertyId
END

GO

