-- =============================================  
-- Author:  Banu  
-- Create date: 2018-10-10  
-- Description: Select Pos Order Type  
-- =============================================  
CREATE  PROCEDURE [dbo].[Sync_UserLogSettings_Select]   
@PropertyId INT = 0
AS  
BEGIN   
 SET NOCOUNT ON;  
    SELECT * FROM Sync_UserLogSettings   
END

GO

