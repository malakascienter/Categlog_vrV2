
CREATE PROCEDURE [dbo].[POS_SetMenuSubLevelDetails_T_Delete] 
	@SubLevelDetailId	INT,
	@PropertyId INT
AS
BEGIN

	DECLARE @SetMenuId nVARCHAR(50), @LevelId nVARCHAR(50)

	SELECT @SetMenuId = SetMenuItemID, @LevelId = SetMenuLevelID FROM POS_SetMenuSubLevelDetails WHERE SubLevelDetailID = @SubLevelDetailId AND PropertyId = @PropertyId

	 
	
	UPDATE POS_SetMenuSubLevelDetails SET IsActive = 0
	WHERE SubLevelDetailID = @SubLevelDetailId AND PropertyId = @PropertyId

	 --TRANSFER FROM HO TO OUTLET SYNC
	   --INSERT INTO Sync_MasterDataTransferStatus
	   --SELECT A.MenuItemCode, B.code, 'MenuItem', 1
	   --FROM (SELECT @SetMenuId AS MenuItemCode) A
	   --CROSS JOIN Location_Ref B WHERE B.Active = 1

END

GO

