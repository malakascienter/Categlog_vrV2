CREATE PROCEDURE [dbo].[Sync_spGetMenuItemModifierMaxQty]
@PropertyId INT,
@MenuItem VARCHAR(6)
AS
SET NOCOUNT ON

SELECT	ModifierMenuCode, SeqNo, ActionID, MaxQty
FROM	MenuItemWiseModifier
WHERE	PropertyId = @PropertyId AND MainMenuCode = @MenuItem

GO

