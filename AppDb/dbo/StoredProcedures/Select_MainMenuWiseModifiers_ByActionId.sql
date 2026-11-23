
CREATE PROCEDURE [dbo].[Select_MainMenuWiseModifiers_ByActionId]  
@ActionId INT,  
@MainMenuCode NVARCHAR(5),
@PropertyId INT
AS  
BEGIN  
	SELECT * FROM MenuItemWiseModifier  
	WHERE ActionID = @ActionId AND MainMenucode = @MainMenuCode  
END

GO

