-- [dbo].[POS_SetMenuLevelDetails_T_Save]  6153,15,16,3

CREATE PROCEDURE [dbo].[POS_SetMenuSubLevelDetails_T_Save_New] 
	@SetMenuItemID	NVARCHAR(10),
	@SetMenuLevelID	NVARCHAR(10),
	@SetMenuSubLevelID		NVARCHAR(10),
	@SortOrder	INT,
	@SubLevelQuantity  INT,
	@IsActive BIT,
	@PropertyId INT
AS
BEGIN

	DECLARE @SetMenuItemCode VARCHAR(10)
		--select @SetMenuItemId
		SET @SetMenuItemCode = (SELECT ItemCode FROM MainMenu WHERE ID = @SetMenuItemId)
	
	IF EXISTS(SELECT 1 FROM POS_SetMenuSubLevelDetails WHERE [SetMenuItemID] = @SetMenuItemCode AND [SetMenuLevelID] = @SetMenuLevelId AND [SetMenuSubLevelID] = @SetMenuSubLevelID AND PropertyId = @PropertyId)
	BEGIN
		RAISERROR('This Sub level for set menu is already added', 16, 1)
	END
	
	ELSE
	BEGIN
		--Temporary Solution Aruna De Silva on 2021-08-14------------------------------------------------
		IF EXISTS(SELECT 1 FROM POS_SetMenuLevelDetails WHERE [SetMenuItemID] = @SetMenuItemCode AND [SetMenuLevelID] = @SetMenuLevelId AND IsDependLevel = 1 AND PropertyId = @PropertyId)
		BEGIN

		DECLARE @DependLevelCount AS INT = 0
		SELECT @DependLevelCount = COUNT(*) FROM POS_SetMenuLevelDetails A INNER JOIN POS_SetMenuSubLevelDetails B ON A.SetMenuLevelID = B.SetMenuLevelID AND A.SetMenuItemID = B.SetMenuItemID AND A.PropertyId = B.PropertyId 
		WHERE B.[SetMenuItemID] = @SetMenuItemCode AND B.[SetMenuLevelID] = @SetMenuLevelId AND A.IsDependLevel = 1 AND A.PropertyId = @PropertyId AND B.PropertyId = @PropertyId

		IF @DependLevelCount > 0
		BEGIN
			RAISERROR('Depend level can only have one sub level ', 16, 1)
		END
		ELSE
		BEGIN
				INSERT INTO [dbo].[POS_SetMenuSubLevelDetails]
		       ([SetMenuItemID]
		       ,[SetMenuLevelID]
		       ,[SetMenuSubLevelID]
		       ,[SortOrder]
		       ,[SubLevelQuantity]
		       ,[IsActive]
			   ,PropertyId)
				VALUES
		       (@SetMenuItemCode
		       ,@SetMenuLevelID
		       ,@SetMenuSubLevelID
		       ,@SortOrder
		       ,@SubLevelQuantity
		       ,@IsActive
			   ,@PropertyId)
		END

		END
		ELSE
		BEGIN
				INSERT INTO [dbo].[POS_SetMenuSubLevelDetails]
			   ([SetMenuItemID]
			   ,[SetMenuLevelID]
			   ,[SetMenuSubLevelID]
			   ,[SortOrder]
			   ,[SubLevelQuantity]
			   ,[IsActive]
			   ,PropertyId)
				VALUES
			   (@SetMenuItemCode
			   ,@SetMenuLevelID
			   ,@SetMenuSubLevelID
			   ,@SortOrder
			   ,@SubLevelQuantity
			   ,@IsActive
			   ,@PropertyId)
		END

		-------------------------------------------------------------------------------------------------
		

		   --TRANSFER FROM HO TO OUTLET SYNC
			--INSERT INTO Sync_MasterDataTransferStatus
			--SELECT A.MenuItemCode, B.code, 'MenuItem', 1
			--FROM (SELECT @SetMenuItemCode AS MenuItemCode) A
			--CROSS JOIN Location_Ref B WHERE B.Active = 1

		
	END
END

GO

