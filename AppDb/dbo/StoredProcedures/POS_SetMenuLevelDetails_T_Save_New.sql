-- [dbo].[POS_SetMenuLevelDetails_T_Save]  6153,15,16,3

CREATE PROCEDURE [dbo].[POS_SetMenuLevelDetails_T_Save_New] 
	@SetMenuItemId	NVARCHAR(50),
	@SetMenuLevelId	NVARCHAR(50),
	@SortOrder		INT,
	@Quantity		INT,
	@MaxQuantity	INT,
	@IsDependLevel  BIT,
	@DependLevelId NVARCHAR(50),
	@IsOptional  BIT,
	@IsActive  BIT,
	@PropertyId INT =0,
	@ItemQty INT = 0
AS
BEGIN
	DECLARE @Id BIGINT
	DECLARE @SetMenuItemCode VARCHAR(10)
		--select @SetMenuItemId
		SET @SetMenuItemCode = (SELECT ItemCode FROM MainMenu WHERE ID = @SetMenuItemId AND PropertyId = @PropertyId)
	
	IF EXISTS(SELECT 1 FROM POS_SetMenuLevelDetails WHERE [SetMenuItemID] = @SetMenuItemCode AND [SetMenuLevelID] = @SetMenuLevelId AND  PropertyId = @PropertyId)
	BEGIN
		RAISERROR('This level for set menu is already added', 16, 1)
	END

	ELSE
	BEGIN
		--Temporary Solution Aruna De Silva on 2021-08-14------------------------------------------------
		
		INSERT INTO POS_SetMenuLevelDetails([SetMenuItemID], [SetMenuLevelID], [SortOrder],[IsDependLevel],[DependLevelId],[IsOptional],[IsActive],PropertyId,LevelQuantity,MaxQuantity)
		VALUES(@SetMenuItemCode, @SetMenuLevelId, @SortOrder,@IsDependLevel,@DependLevelId,@IsOptional,@IsActive,@PropertyId,@Quantity,@MaxQuantity)
		-------------------------------------------------------------------------------------------------

		SELECT @Id = Id FROM POS_SetMenuLevelDetails WHERE [SetMenuItemID] = @SetMenuItemCode AND [SetMenuLevelID] = @SetMenuLevelId AND  PropertyId = @PropertyId
		-- Audit trail ----------------------------		
		EXEC HotelResWeb_AuditTail_WriteToLog 'POS_SetMenuLevelDetails',@Id,'POS','POSSMLDI','I',0,'','','','','',@PropertyId
		-- End of Audit trail ---------------------

		--INSERT INTO POS_SetMenuLevelDetails([SetMenuItemID], [SetMenuLevelID], [SortOrder], [LevelQuantity])
		--VALUES(@SetMenuItemId, @SetMenuLevelId, @SortOrder, @LevelQuantity)

		--TRANSFER FROM HO TO OUTLET SYNC
			--INSERT INTO Sync_MasterDataTransferStatus
			--SELECT A.MenuItemCode, B.code, 'MenuItem', 1
			--FROM (SELECT @SetMenuItemCode AS MenuItemCode) A
			--CROSS JOIN Location_Ref B WHERE B.Active = 1

	END
END

GO

