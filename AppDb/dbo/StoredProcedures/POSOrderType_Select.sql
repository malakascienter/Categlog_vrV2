-- =============================================  
-- Author:  Banu  
-- Create date: 2018-10-10  
-- Description: Select Pos Order Type  
-- =============================================  
CREATE  PROCEDURE [dbo].[POSOrderType_Select]   
@PropertyId INT
AS  
BEGIN   
 SET NOCOUNT ON;  
    SELECT Code, Name FROM POSOrderTypes   WHERE PropertyId=@PropertyId
END

GO

