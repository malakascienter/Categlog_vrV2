
CREATE PROCEDURE [dbo].[POS_SetMenuLevelDetail_T_Edit] 
	@LevelDetailID	INT,
	@SetMenuItemId	nVARCHAR(50),
	@SetMenuLevelId	nVARCHAR(50),
	@SortOrder		INT,
	@Quantity		INT,
	@MaxQuantity	INT,
	@IsDependLevel  BIT,
	@DependLevelId NVARCHAR(50),
	@IsOptional  BIT,
	@IsActive  BIT,
	@PropertyId INT,
	@ItemQty INT
AS
BEGIN



UPDATE POS_SetMenuLevelDetails
SET 
	IsDependLevel = @IsDependLevel,
	IsOptional =@IsOptional,
	DependLevelId = @DependLevelId,
	IsActive = @IsActive,
	MaxQuantity = @MaxQuantity,
	LevelQuantity = @Quantity,
	ItemCount = isnull(@ItemQty,0)
WHERE LevelDetailID = @LevelDetailID AND PropertyId = @PropertyId

 -- Audit trail ----------------------------		
EXEC HotelResWeb_AuditTail_WriteToLog 'POS_SetMenuLevelDetails',@LevelDetailID,'POS','POSSMLDU','U',0,'','','','','',@PropertyId
-- End of Audit trail ---------------------

			--TRANSFER FROM HO TO OUTLET SYNC
			--DECLARE @SetMenuItemCode VARCHAR(10)
			----select @SetMenuItemId
			--SET @SetMenuItemCode = (SELECT ItemCode FROM MainMenu WHERE ID = @SetMenuItemId)

			--INSERT INTO Sync_MasterDataTransferStatus
			--SELECT A.MenuItemCode, B.code, 'MenuItem', 1
			--FROM (SELECT @SetMenuItemCode AS MenuItemCode) A
			--CROSS JOIN Location_Ref B WHERE B.Active = 1
	
END

GO

