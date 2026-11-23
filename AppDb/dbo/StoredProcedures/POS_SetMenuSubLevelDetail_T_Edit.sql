
CREATE PROCEDURE [dbo].[POS_SetMenuSubLevelDetail_T_Edit] 
	@SubLevelDetailID	INT,
	@SetMenuItemID	NVARCHAR(50),
	@SetMenuLevelID	NVARCHAR(50),
	@SetMenuSubLevelID	NVARCHAR(50),
	@SortOrder	INT,
	@SubLevelQuantity  INT,
	@IsActive BIT,
	@PropertyId INT
AS
BEGIN

UPDATE [dbo].[POS_SetMenuSubLevelDetails]
   SET --[SetMenuItemID] =@SetMenuItemID
      --,[SetMenuLevelID] = @SetMenuLevelID
      --,[SetMenuSubLevelID] = @SetMenuSubLevelID
      -- [SortOrder] = @SortOrder
      [SubLevelQuantity] = @SubLevelQuantity
      ,[IsActive] = @IsActive
 WHERE SubLevelDetailID = @SubLevelDetailID AND PropertyId = @PropertyId


			--TRANSFER FROM HO TO OUTLET SYNC
			--DECLARE @SetMenuItemCode VARCHAR(10)
			----select @SetMenuItemId
			--SET @SetMenuItemCode = (SELECT ItemCode FROM MainMenu WHERE ID = @SetMenuItemID)

			--INSERT INTO Sync_MasterDataTransferStatus
			--SELECT A.MenuItemCode, B.code, 'MenuItem', 1
			--FROM (SELECT @SetMenuItemCode AS MenuItemCode) A
			--CROSS JOIN Location_Ref B WHERE B.Active = 1

	
END

GO

