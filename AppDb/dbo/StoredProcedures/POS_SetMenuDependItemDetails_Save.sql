
CREATE PROCEDURE [dbo].[POS_SetMenuDependItemDetails_Save] 
	
	@MainItemCode	nvarchar(50),
	@LevelCode	nvarchar(50),
	@LevelItemId	nvarchar(50),
	@UserId	nvarchar(50),
	@DependItemDetails POS_SetMenuDependItemDetails_UDT READONLY,
	@PropertyId INT
	
AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY
	BEGIN TRANSACTION InProc

CREATE TABLE #Temp_SetMenuDependItemDetails (
	[DependItemDetailsID] [int] NOT NULL,
	[MainItemCode] [varchar](10) NOT NULL,
	[LevelCode] [varchar](10) NOT NULL,
	[LevelItemId] [varchar](10) NOT NULL,
	[DepenItemId] [varchar](10) NOT NULL,
	[Price] [decimal](18, 10) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedUser] [nvarchar](50) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedUser] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NOT NULL
) 

INSERT INTO #Temp_SetMenuDependItemDetails
           ([DependItemDetailsID]
		   ,[MainItemCode]
           ,[LevelCode]
           ,[LevelItemId]
           ,[DepenItemId]
           ,[Price]
           ,[IsActive]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate])
	SELECT P.[DependItemDetailsID]
		   ,P.[MainItemCode]
           ,P.[LevelCode]
           ,P.[LevelItemId]
           ,P.[DepenItemId]
           ,P.[Price]
           ,P.[IsActive]
           ,P.[CreatedUser]
           ,GETDATE()
           ,P.[ModifiedUser]
           ,GETDATE()
	FROM [dbo].[POS_SetMenuDependItemDetails] P INNER JOIN POS_SetMenuItemDetails S ON P.MainItemCode = S.SetMenuItemID and s.PropertyId = p.PropertyId
	AND P.LevelCode = S.SetMenuLevelID AND P.LevelItemId = s.MenuItemID
	WHERE P.LevelCode = @LevelCode and P.MainItemCode = @MainItemCode and P.LevelItemId = @LevelItemId and P.IsActive = 1 
	AND S.IsActive = 1 and s.PropertyId = @PropertyId and p.PropertyId = @PropertyId

	MERGE #Temp_SetMenuDependItemDetails AS trg
		USING @DependItemDetails AS src
		ON src.[MainItemCode] = trg.[MainItemCode] 
		AND src.[LevelCode] = trg.[LevelCode] 
		AND src.[LevelItemId] = trg.[LevelItemId]
		AND src.[DepenItemId] = trg.[DepenItemId]
		WHEN MATCHED THEN
		DELETE ;


		UPDATE src
		SET src.IsActive = 0 ,src.ModifiedDate = GETDATE(),src.ModifiedUser = @UserId
		FROM [POS_SetMenuDependItemDetails] AS src
		INNER JOIN #Temp_SetMenuDependItemDetails AS trg
        ON src.[MainItemCode] = trg.[MainItemCode] 
		AND src.[LevelCode] = trg.[LevelCode] 
		AND src.[LevelItemId] = trg.[LevelItemId]
		AND src.[DepenItemId] = trg.[DepenItemId]
		WHERE src.Propertyid = @PropertyId


		MERGE dbo.[POS_SetMenuDependItemDetails] AS trg
		USING @DependItemDetails AS src
		ON src.[MainItemCode] = trg.[MainItemCode] 
		AND src.[LevelCode] = trg.[LevelCode] 
		AND src.[LevelItemId] = trg.[LevelItemId]
		AND src.[DepenItemId] = trg.[DepenItemId]
		and @PropertyId = trg.PropertyId
		WHEN MATCHED THEN
		UPDATE 
		SET 
		 [Price] = src.[Price]
		,[IsActive] = src.[IsActive]
		,[ModifiedDate] = getdate()
		,[ModifiedUser] = @UserId
		WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			[MainItemCode]
           ,[LevelCode]
           ,[LevelItemId]
           ,[DepenItemId]
           ,[Price]
           ,[IsActive]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
		   ,PropertyId
		   )
		VALUES
			( 
			 src.[MainItemCode]
			,src.[LevelCode]
			,src.[LevelItemId]
			,src.[DepenItemId]
			,src.[Price]
			,src.[IsActive]
			,@UserId
			,getdate()
			,@UserId
			,getdate()
			,@PropertyId
			);

		
		IF OBJECT_ID('tempdb..#Temp_SetMenuDependItemDetails') IS NOT NULL 
		BEGIN
			DROP TABLE #Temp_SetMenuDependItemDetails
		END 

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

