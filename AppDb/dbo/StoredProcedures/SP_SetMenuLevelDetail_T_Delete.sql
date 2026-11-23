
CREATE PROCEDURE [dbo].[SP_SetMenuLevelDetail_T_Delete] 
	@LevelDetailID	 INT,
	@PropertyId INT
AS
BEGIN

	DECLARE @SetMenuId nVARCHAR(50), @LevelId nVARCHAR(50)

	SELECT @SetMenuId = SetMenuItemID, @LevelId = SetMenuLevelID FROM POS_SetMenuLevelDetails WHERE LevelDetailID = @LevelDetailID AND PropertyId = @PropertyId

	 

	update	POS_SetMenuLevelDetails 
	set	IsActive = 0
	where LevelDetailID = @LevelDetailID AND PropertyId = @PropertyId


	-- Audit trail ----------------------------		
	EXEC HotelResWeb_AuditTail_WriteToLog 'POS_SetMenuLevelDetails',@LevelDetailID,'POS','POSSMLDD','D',0,'','','','','',@PropertyId
	-- End of Audit trail ---------------------

	--DELETE 
	--FROM	POS_SetMenuItemDetails
	--WHERE	SetMenuItemID = @SetMenuId AND SetMenuLevelID = @LevelId

	 --TRANSFER FROM HO TO OUTLET SYNC
	   --INSERT INTO Sync_MasterDataTransferStatus
	   --SELECT A.MenuItemCode, B.code, 'MenuItem', 1
	   --FROM (SELECT @SetMenuId AS MenuItemCode) A
	   --CROSS JOIN Location_Ref B WHERE B.Active = 1


	DELETE FROM Sync_MasterDataTransferStatus WHERE DataType = 'MainMenu' AND PropertyId = @PropertyId AND Code = @SetMenuId

	INSERT INTO Sync_MasterDataTransferStatus
	SELECT @PropertyId,mm.ItemCode, A.OutletCode, 'MainMenu',MM.Active
	FROM POS_OutletWiseMenuItems A 
	inner join MainMenu mm on a.MenuCode = mm.ItemCode 	AND A.PropertyId = MM.PropertyId
	INNER JOIN Location_Ref B ON B.code = A.OutletCode  AND B.PropertyId = A.PropertyId
	WHERE B.Active = 1 AND MM.PropertyId = @PropertyId AND A.PropertyId = @PropertyId AND B.PropertyId = @PropertyId AND MM.ItemCode = @SetMenuId AND A.MenuCode = @SetMenuId


	INSERT INTO Sync_MasterDataTransferStatus(PropertyId,Code,Outlet,DataType,Active)
	SELECT @PropertyId,@SetMenuId AS Code, L.Code, 'MainMenu',0
	FROM Location_Ref L
	WHERE L.PropertyId = @PropertyId AND L.code NOT IN (SELECT A.OutletCode FROM POS_OutletWiseMenuItems A WHERE A.PropertyId = @PropertyId AND A.MenuCode = @SetMenuId) 


END

GO

