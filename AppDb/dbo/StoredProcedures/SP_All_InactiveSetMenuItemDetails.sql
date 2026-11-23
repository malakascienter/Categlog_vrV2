
CREATE PROCEDURE [dbo].[SP_All_InactiveSetMenuItemDetails] 
	@LevelCode NVARCHAR(10),
	@ItemCode NVARCHAR(10),
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY
	BEGIN TRANSACTION InProc

		UPDATE src
		SET src.IsActive = 0
		FROM [POS_SetMenuItemDetails] AS src
        WHERE src.SetMenuItemID = @ItemCode
		AND src.SetMenuLevelID = @LevelCode
		AND src.Propertyid = @PropertyId
		--AND src.SetMenuSubLevelId = @SubLevelCode
	
	----TRANSFER FROM HO TO OUTLET SYNC
	--		INSERT INTO Sync_MasterDataTransferStatus
	--		SELECT A.MenuItemCode, B.code, 'MenuItem', 1
	--		FROM (SELECT @ItemCode AS MenuItemCode) A
	--		CROSS JOIN Location_Ref B WHERE B.Active = 1

IF @@TRANCOUNT > 0 
            BEGIN
                COMMIT TRANSACTION InProc;
                SELECT  1 AS Result
            END
     
ELSE
BEGIN
            SELECT  0 AS Result
END

END TRY  
     
BEGIN CATCH
        IF @@TRANCOUNT > 0 
            BEGIN
                ROLLBACK TRANSACTION
                 SELECT  0 AS Result

            END
        ELSE 
            BEGIN
                 SELECT  0 AS Result
            END
    END CATCH
END

GO

