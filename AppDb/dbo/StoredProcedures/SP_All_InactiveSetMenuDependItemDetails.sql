
CREATE PROCEDURE [dbo].[SP_All_InactiveSetMenuDependItemDetails] 
	@MainItemCode	nvarchar(50),
	@LevelCode	nvarchar(50),
	@LevelItemId	nvarchar(50),
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY
	BEGIN TRANSACTION InProc

		UPDATE src
		SET src.IsActive = 0
		FROM [POS_SetMenuDependItemDetails] AS src
        WHERE  src.[MainItemCode] = @MainItemCode
		AND src.[LevelCode] = @LevelCode
		AND src.[LevelItemId] = @LevelItemId
		AND src.PropertyId  = @PropertyId
	
	 --TRANSFER FROM HO TO OUTLET SYNC
			INSERT INTO Sync_MasterDataTransferStatus
			SELECT @PropertyId,A.MenuItemCode, B.code, 'MenuItem', 1
			FROM (SELECT @MainItemCode AS MenuItemCode) A
			CROSS JOIN Location_Ref B WHERE B.Active = 1


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

