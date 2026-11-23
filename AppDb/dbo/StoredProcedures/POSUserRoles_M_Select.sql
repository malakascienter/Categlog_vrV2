-- =============================================  
-- Author:  Yasiru  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
CREATE PROCEDURE [dbo].[POSUserRoles_M_Select]  
@IsActive       INT = 2 ,
@PropertyId INT
AS  
BEGIN   
 SET NOCOUNT ON;  
  
 SELECT * FROM POSUserRoles UR  
 WHERE
 PropertyId=@PropertyId AND (@IsActive = 2 OR @IsActive = UR.IsActive)  
  
END

GO

