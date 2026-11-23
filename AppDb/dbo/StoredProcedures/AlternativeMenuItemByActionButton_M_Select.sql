
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AlternativeMenuItemByActionButton_M_Select]
	@MainMenuCode VARCHAR(6),
	@MenuCode VARCHAR(6),
	@ActionButton INT,
	@PropertyId	INT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT * FROM [dbo].[MenuItemWiseAlternatives] 
	WHERE MainMenuCode=@MainMenuCode AND  MenuCode=@MenuCode AND ActionButtonID = @ActionButton
END

GO

