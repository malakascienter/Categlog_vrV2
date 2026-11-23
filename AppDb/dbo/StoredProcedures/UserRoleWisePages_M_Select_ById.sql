-- =============================================
-- Author:		Yasiru
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UserRoleWisePages_M_Select_ById]
@RoleId			  INT,
@MainNavigationId INT,
@PropertyId INT

AS
BEGIN	
	SET NOCOUNT ON;

	 IF EXISTS(SELECT * FROM UserRoleWisePages Where RoleId = @RoleId  AND PropertyId=@PropertyId )--AND MainNavigationId = @MainNavigationId
	BEGIN
		SELECT * ,( select AccessCodeId from POS_UserRoleWiseAccess where PropertyId=@PropertyId and UserRoleId=RoleId for json auto )as posaccessjson 
		FROM UserRoleWisePages Where RoleId = @RoleId  AND PropertyId=@PropertyId --AND MainNavigationId = @MainNavigationId
	END
	ELSE
	BEGIN
		DECLARE @jsondata NVARCHAR(MAX) = (select AccessCodeId from POS_UserRoleWiseAccess where PropertyId=@PropertyId and UserRoleId=@RoleId for json auto)  
		select @jsondata as posaccessjson
	END

	
		

		


END

GO

