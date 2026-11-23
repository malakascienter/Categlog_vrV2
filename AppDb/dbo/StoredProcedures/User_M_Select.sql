-- =============================================  
-- Author:  Yasiru  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
CREATE PROCEDURE [dbo].[User_M_Select]--  1,-1,1
@IsActive       INT = 2,  
@Id    INT = -1 ,
@PropertyId INT
AS  
BEGIN   
 SET NOCOUNT ON;  
  
 SELECT * ,
 (SELECT * FROM UserWiseRoles WHERE UserId = UR.Id AND UR.PropertyId=@PropertyId FOR JSON AUTO) AS RolesJson  ,'' as EmplyeeNo
 FROM Users UR  
 WHERE(@Id = -1 OR UR.Id=@Id)    AND UR.PropertyId=@PropertyId
 AND (@IsActive = 2 OR @IsActive = UR.IsActive) --OR IsGroupUser=1  
  
  
 --WHERE UR.Id LIKE CASE WHEN @Id = -1 THEN UR.Id ELSE @Id END   
 --AND UR.IsActive LIKE CASE WHEN @IsActive = 2 THEN Ur.IsActive ELSE @IsActive END  
END

GO

