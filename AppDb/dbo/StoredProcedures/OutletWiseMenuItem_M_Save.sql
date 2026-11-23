-- =============================================
-- Author:		Chiraj
-- Create date: 2020-6-15
-- Description:	OutletWiseMenuItem_M_Save
-- =============================================

--DECLARE	@return_value int

--EXEC	@return_value = [dbo].[OutletWiseMenuItem_M_Save]
--		@OutletCode = N'001',
--		@MenuItemsJson = N'{"OutletCode":"001","lstMenuItems":[{"MenuCode":"9523"},{"MenuCode":"9522"},{"MenuCode":"9521"},{"MenuCode":"9520"}]}',
--		@UserId = 1,
--		@PropertyId = 222

--SELECT	'Return Value' = @return_value




CREATE PROCEDURE [dbo].[OutletWiseMenuItem_M_Save] 
@OutletCode					VARCHAR(3),
@MenuItemsJson				NVARCHAR(MAX),
@UserId					INT,
@PropertyId				INT

	AS
BEGIN	TRY
BEGIN TRANSACTION
	
	SET NOCOUNT ON;

	SELECT * 
	INTO #TempMenuCodes	
	FROM OPENJSON(@MenuItemsJson,N'$.lstMenuItems')  
	WITH 
	(		
		MenuCode   VARCHAR(50) '$.MenuCode'
		
	)

	SELECT * 
	INTO #TempMenuCodes2	
	FROM OPENJSON(@MenuItemsJson,N'$.lstMenuItems')  
	WITH 
	(		
		MenuCode   VARCHAR(50) '$.MenuCode'
		
	)

	

	CREATE TABLE #TempDeleteMenuCodes
	(
	 MenuCode   VARCHAR(50)	
	)

	INSERT INTO #TempDeleteMenuCodes (MenuCode)
	SELECT MenuCode FROM [dbo].[Temp_POS_OutletWiseMenuItems]
    WHERE MenuCode NOT IN (SELECT MenuCode FROM #TempMenuCodes)

	DELETE FROM [dbo].[POS_OutletWiseMenuItems]
    WHERE MenuCode  IN (SELECT MenuCode FROM #TempDeleteMenuCodes) AND OutletCode = @OutletCode

	INSERT INTO POS_OutletWiseMenuItemsRemoveLog(OutletCode, MenuCode, IsUpload, PropertyId, CreatedUserId, CreatedDateTime)
	SELECT @OutletCode,MenuCode,0,@PropertyId,@UserId,GETDATE()FROM #TempDeleteMenuCodes

	DELETE FROM [dbo].[Temp_POS_OutletWiseMenuItems]
    WHERE MenuCode NOT IN (SELECT MenuCode FROM #TempMenuCodes)

	DELETE  FROM #TempMenuCodes WHERE MenuCode IN (SELECT MenuCode FROM Temp_POS_OutletWiseMenuItems)

	INSERT INTO POS_OutletWiseMenuItems(OutletCode, MenuCode, IsUpload, PropertyId, CreatedUserId, CreatedDateTime)
	SELECT @OutletCode,MenuCode,0,@PropertyId,@UserId,GETDATE()FROM #TempMenuCodes
	


	UPDATE MainMenu SET IsUpload=0 WHERE PropertyId=@PropertyId AND ItemCode in (SELECT MenuCode FROM #TempMenuCodes)
	UPDATE MainMenu SET IsUpload=0 WHERE PropertyId=@PropertyId AND ItemCode in (SELECT MenuCode FROM #TempDeleteMenuCodes)

	  --EXEC Insert_Sync_MasterDataTransferStatus 'MainMenu',@IsActive,@ItemCode,@PropertyId
	 IF( (SELECT IsRestaurant FROM Companies WHERE CompanyID = @PropertyId) = 1 )
	 BEGIN
	 
	   --TRANSFER FROM HO TO OUTLET SYNC
	 	INSERT INTO Sync_MasterDataTransferStatus
	 	SELECT @PropertyId,A.MenuCode, B.code, 'MainMenu',MM.Active
	 	FROM #TempMenuCodes2 A inner join MainMenu mm on a.MenuCode = mm.ItemCode 
	 	CROSS JOIN Location_Ref B WHERE B.Active = 1 AND MM.PropertyId = @PropertyId

		--TRANSFER FROM HO TO OUTLET SYNC
	 	INSERT INTO Sync_MasterDataTransferStatus
	 	SELECT @PropertyId,A.MenuCode, B.code, 'MainMenu',MM.Active
	 	FROM #TempDeleteMenuCodes A inner join MainMenu mm on a.MenuCode = mm.ItemCode 
	 	CROSS JOIN Location_Ref B WHERE B.Active = 1 AND MM.PropertyId = @PropertyId

	 END


	DROP TABLE #TempMenuCodes
	DROP TABLE #TempMenuCodes2
	DROP TABLE #TempDeleteMenuCodes
	DELETE FROM [dbo].[Temp_POS_OutletWiseMenuItems]
COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	DECLARE @Message NVARCHAR(100)
	SET @Message = N'Record Not Save. ''' + ERROR_MESSAGE() + ''''
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)	
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
	RAISERROR(@Message,16,1)
END CATCH

GO

