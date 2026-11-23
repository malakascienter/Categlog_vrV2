
CREATE PROCEDURE [dbo].[POS_SetMenuItemDetails_Save] 
	@setMenuItem POS_SetMenuItemDetails_UDT READONLY,
	@LevelCode NVARCHAR(10),
	@ItemCode NVARCHAR(10),
	@PropertyId INT
	
AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY
	BEGIN TRANSACTION InProc

		CREATE TABLE #Temp_SetMenuItemDetails
		(
		[LevelItemID] [int] NOT NULL,
		[SetMenuItemID] [varchar](10) NULL,
		[SetMenuLevelID] [varchar](4) NOT NULL,
		[MenuItemID] [varchar](10) NULL,
		[SortOrder] [smallint] NOT NULL,
		[AddRate] [decimal](18, 10) NULL,
		[SetMenuSubLevelId] [varchar](10) NOT NULL,
		[IsActive] [bit] NOT NULL
		)

		INSERT INTO #Temp_SetMenuItemDetails
		 (  [LevelItemID]
		   ,[SetMenuItemID]
           ,[SetMenuLevelID]
           ,[MenuItemID]
           ,[SortOrder]
           ,[AddRate]
           ,[SetMenuSubLevelId]
           ,[IsActive]
		  )
		  SELECT [LevelItemID]
		        ,[SetMenuItemID]
				,[SetMenuLevelID]
				,[MenuItemID]
				,[SortOrder]
				,[AddRate]
				,[SetMenuSubLevelId]
				,[IsActive]
		  FROM [POS_SetMenuItemDetails]
		  WHERE [SetMenuLevelID] = @LevelCode and [SetMenuItemID] = @ItemCode and IsActive = 1 and propertyid = @PropertyId

---------------------------------------------------------------------------------------

		MERGE #Temp_SetMenuItemDetails AS trg
		USING @setMenuItem AS src
		ON src.SetMenuItemID = trg.SetMenuItemID 
		AND src.SetMenuLevelID = trg.SetMenuLevelID 
		AND src.SetMenuSubLevelId = trg.SetMenuSubLevelId
		AND src.MenuItemID = trg.MenuItemID
		WHEN MATCHED THEN
		DELETE ;


		UPDATE src
		SET src.IsActive = 0
		FROM [POS_SetMenuItemDetails] AS src
		INNER JOIN #Temp_SetMenuItemDetails AS trg
        ON src.SetMenuItemID = trg.SetMenuItemID 
		AND src.SetMenuLevelID = trg.SetMenuLevelID 
		AND src.SetMenuSubLevelId = trg.SetMenuSubLevelId
		AND src.MenuItemID = trg.MenuItemID
		where src.propertyid = @PropertyId

----------------------------------------------------------------------------------

		MERGE dbo.[POS_SetMenuItemDetails] AS trg
		USING @setMenuItem AS src
		ON src.SetMenuItemID = trg.SetMenuItemID 
		AND src.SetMenuLevelID = trg.SetMenuLevelID 
		AND src.SetMenuSubLevelId = trg.SetMenuSubLevelId
		AND src.MenuItemID = trg.MenuItemID
		AND @PropertyId = trg.PropertyId
		WHEN MATCHED THEN
		UPDATE 
		SET 
		 [AddRate] = src.[AddRate]
		,[IsActive] = src.[IsActive]		
		WHEN NOT MATCHED BY TARGET THEN
		INSERT ( 
				 [SetMenuItemID]
				,[SetMenuLevelID]
				,[MenuItemID]
				,[SortOrder]
				,[AddRate]
				,[SetMenuSubLevelId]
				,[IsActive]
				,PropertyId
				)
		VALUES ( 
				 src.[SetMenuItemID]
				,src.[SetMenuLevelID]
				,src.[MenuItemID]
				,src.[SortOrder]
				,src.[AddRate]
				,src.[SetMenuSubLevelId]
				,src.IsActive
				,@PropertyId
				);

---------------------------------------------------------------------------------	
		IF OBJECT_ID('tempdb..#Temp_SetMenuItemDetails') IS NOT NULL 
		BEGIN
			DROP TABLE #Temp_SetMenuItemDetails
		END 



		update MainMenu 
		set IsUpload = 0
		where ItemCode =  @ItemCode and PropertyId =  @PropertyId


		 ----TRANSFER FROM HO TO OUTLET SYNC
			--INSERT INTO Sync_MasterDataTransferStatus
			--SELECT A.MenuItemCode, B.code, 'MenuItem', 1
			--FROM (SELECT @ItemCode AS MenuItemCode) A
			--CROSS JOIN Location_Ref B WHERE B.Active = 1

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

