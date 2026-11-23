-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_SaveOutletWiseMenuItemPrice]	
	@OutleTWisePriceList POS_OutletWiseMenuItemPrice_UDT READONLY,
	@PropertyId INT,
	@UserId INT,
	@EffectiveDate DATETIME
AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY
	BEGIN TRANSACTION InProc
		INSERT INTO [dbo].[POS_OutletWiseMenuItemPriceChangeLog]
           (
			[MenuItemCode]
           ,[OutletCode]
           ,[PriceTypeID]
           ,[NewPrice]
		   ,[OldPrice]
           ,[IsActive]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
		   ,PropertyId
		   ,[EffectiveDate]
		   )
			SELECT
			 [MenuItemCode]
			,[OutletCode]
			,[PriceTypeID]
			,[Price]
			,[OldPrice]
			,[IsActive]
			,[CreatedUser]
			,GETDATE()
			,[ModifiedUser]
			,GETDATE()
			,@PropertyId
			,@EffectiveDate
			FROM @OutleTWisePriceList 
------------------------------------------------------------


 --Outlet wise price type wise menu item  price
IF( CONVERT(DATE,@EffectiveDate) =  CONVERT(DATE,GETDATE()))
BEGIN


			MERGE dbo.POS_OutletWiseMenuItemPrice AS trg
			--USING (SELECT T.* FROM @OutleTWisePriceList T INNER JOIN Location_ref l on t.[OutletCode] = l.code WHERE L.PropertyId = @PropertyId AND L.IsForeignCurrency = 0) AS src
			USING @OutleTWisePriceList AS src
			ON src.MenuItemCode = trg.MenuItemCode 
			AND src.OutletCode = trg.OutletCode 
			AND src.PriceTypeID = trg.PriceTypeID
			AND @PropertyId = trg.PropertyId
			WHEN MATCHED THEN
			UPDATE 
			SET 
			 [Price] = src.[Price]
			,[NewPrice] = src.[Price]
			,[IsActive] = src.[IsActive]
			,[ModifiedUser] = src.[ModifiedUser]
			,[ModifiedDate] = GETDATE()
			,PropertyId = @PropertyId
			,[EffectiveDate] = @EffectiveDate
			WHEN NOT MATCHED BY TARGET THEN
			INSERT ([MenuItemCode], [OutletCode], [PriceTypeID],[Price],[IsActive],[CreatedUser],[CreatedDate],
					[ModifiedUser],[ModifiedDate],PropertyId,EffectiveDate,NewPrice)
			VALUES (src.[MenuItemCode], src.[OutletCode], src.[PriceTypeID],src.[Price],src.[IsActive],src.[CreatedUser],GETDATE(),
					src.[ModifiedUser],GETDATE(),@PropertyId,@EffectiveDate,src.[Price]);

END
ELSE
BEGIN

			MERGE dbo.POS_OutletWiseMenuItemPrice AS trg
			--USING (SELECT T.* FROM @OutleTWisePriceList T INNER JOIN Location_ref l on t.[OutletCode] = l.code WHERE L.PropertyId = @PropertyId AND L.IsForeignCurrency = 0) AS src
			USING @OutleTWisePriceList AS src
			ON src.MenuItemCode = trg.MenuItemCode 
			AND src.OutletCode = trg.OutletCode 
			AND src.PriceTypeID = trg.PriceTypeID
			AND @PropertyId = trg.PropertyId
			WHEN MATCHED THEN
			UPDATE 
			SET 
			 [NewPrice] = src.[Price]
			,[IsActive] = src.[IsActive]
			,[ModifiedUser] = src.[ModifiedUser]
			,[ModifiedDate] = GETDATE()
			,PropertyId = @PropertyId
			,[EffectiveDate] = @EffectiveDate
			WHEN NOT MATCHED BY TARGET THEN
			INSERT ([MenuItemCode], [OutletCode], [PriceTypeID],[Price],[IsActive],[CreatedUser],[CreatedDate],
					[ModifiedUser],[ModifiedDate],PropertyId,EffectiveDate,NewPrice)
			VALUES (src.[MenuItemCode], src.[OutletCode], src.[PriceTypeID],src.[Price],src.[IsActive],src.[CreatedUser],GETDATE(),
					src.[ModifiedUser],GETDATE(),@PropertyId,@EffectiveDate,src.[Price]);

END


--Outlet wise menu item 

	CREATE TABLE #TempOutletWiseMenuItems(
		[OutletCode] [varchar](3) NOT NULL,
		[MenuCode] [varchar](10) NULL
		
	);

	
	INSERT INTO #TempOutletWiseMenuItems
           ([MenuCode]
		   ,[OutletCode]
           
           )
     SELECT
		   [MenuItemCode]
		  ,[OutletCode]
	 FROM @OutleTWisePriceList
	 GROUP BY  [MenuItemCode],[OutletCode]

	 --MERGE dbo.POS_OutletWiseMenuItems AS trg
	 --USING #TempOutletWiseMenuItems AS src
	 --ON src.MenuCode = trg.MenuCode 
	 --AND src.OutletCode = trg.OutletCode 
	 --AND @PropertyId = trg.PropertyId
	 --WHEN MATCHED THEN
	 --UPDATE 
	 --SET 
	 -- IsUpload = 0
	 --,PropertyId= @PropertyId
	 --,ModifyUserId = @UserId
	 --,ModifiedDateTime = GETDATE()		
	 --WHEN NOT MATCHED BY TARGET THEN
	 --INSERT (OutletCode, MenuCode, IsUpload,CreatedUserId,CreatedDateTime,PropertyId)
	 --VALUES ( src.[OutletCode],src.MenuCode, 0,@UserId,GETDATE(),@PropertyId);

	 UPDATE MainMenu 
	 SET IsUpload = 0
	 WHERE ItemCode in (SELECT MenuCode FROM  #TempOutletWiseMenuItems) and PropertyId = @PropertyId

	  --EXEC Insert_Sync_MasterDataTransferStatus 'MainMenu',@IsActive,@ItemCode,@PropertyId
	 IF( (SELECT IsRestaurant FROM Companies WHERE CompanyID = @PropertyId) = 1 )
	 BEGIN
	 
	   --TRANSFER FROM HO TO OUTLET SYNC
	 	--INSERT INTO Sync_MasterDataTransferStatus
	 	--SELECT @PropertyId,A.MenuCode, B.code, 'MainMenu',MM.Active
	 	--FROM #TempOutletWiseMenuItems A inner join MainMenu mm on a.MenuCode = mm.ItemCode 
	 	--CROSS JOIN Location_Ref B WHERE B.Active = 1 AND MM.PropertyId = @PropertyId

		DELETE SY
		FROM Sync_MasterDataTransferStatus SY
		INNER JOIN #TempOutletWiseMenuItems T ON SY.Code = T.[MenuCode] AND SY.Outlet = T.[OutletCode]
		WHERE SY.DataType = 'MainMenu' AND SY.PropertyId = @PropertyId 


		INSERT INTO Sync_MasterDataTransferStatus
	 	SELECT @PropertyId,A.MenuCode, B.code, 'MainMenu',MM.Active
	 	FROM #TempOutletWiseMenuItems A inner join MainMenu mm on a.MenuCode = mm.ItemCode 
		INNER JOIN POS_OutletWiseMenuItems OMP ON OMP.MenuCode = a.MenuCode AND  OMP.OutletCode = A.OutletCode
	 	INNER JOIN Location_Ref B ON B.code = OMP.OutletCode  AND B.PropertyId = OMP.PropertyId
		WHERE B.Active = 1 AND MM.PropertyId = @PropertyId AND OMP.PropertyId = @PropertyId AND B.PropertyId = @PropertyId
	 
	 END

	 --MainMenu price update when outlet wise price enable
	 UPDATE M
	 SET M.Price = T.Price
	 FROM MainMenu M  INNER JOIN  @OutleTWisePriceList T ON M.ItemCode = T.MenuItemCode
	 INNER JOIN MainMenuPriceMappig MP ON T.PriceTypeID = MP.PriceTypeId
	 INNER JOIN Location_Ref L ON T.OutletCode = L.code
	 WHERE MP.MainMenuPrice = 'Price' AND L.IsDefault = 1 and M.PropertyId = @PropertyId AND  IsForeignCurrency = 0

	 UPDATE M
	 SET M.PackingCharge = T.Price
	 FROM MainMenu M  INNER JOIN  @OutleTWisePriceList T ON M.ItemCode = T.MenuItemCode
	 INNER JOIN MainMenuPriceMappig MP ON T.PriceTypeID = MP.PriceTypeId
	 INNER JOIN Location_Ref L ON T.OutletCode = L.code
	 WHERE MP.MainMenuPrice = 'PackingCharge' AND L.IsDefault = 1 and M.PropertyId = @PropertyId AND IsForeignCurrency = 0

	 UPDATE M
	 SET M.DelivaryPrice = T.Price
	 FROM MainMenu M  INNER JOIN  @OutleTWisePriceList T ON M.ItemCode = T.MenuItemCode
	 INNER JOIN MainMenuPriceMappig MP ON T.PriceTypeID = MP.PriceTypeId
	 INNER JOIN Location_Ref L ON T.OutletCode = L.code
	 WHERE MP.MainMenuPrice = 'DelivaryPrice' AND L.IsDefault = 1 and M.PropertyId = @PropertyId AND IsForeignCurrency = 0

	 UPDATE M
	 SET M.ExecutivePrice = T.Price
	 FROM MainMenu M  INNER JOIN  @OutleTWisePriceList T ON M.ItemCode = T.MenuItemCode
	 INNER JOIN MainMenuPriceMappig MP ON T.PriceTypeID = MP.PriceTypeId
	 INNER JOIN Location_Ref L ON T.OutletCode = L.code
	 WHERE MP.MainMenuPrice = 'ExecutivePrice' AND L.IsDefault = 1 and M.PropertyId = @PropertyId AND IsForeignCurrency = 0




	--TRANSFER FROM HO TO OUTLET SYNC
	--INSERT INTO Sync_MasterDataTransferStatus
	--SELECT A.MenuCode, B.code, 'MenuItem',1
	--FROM #TempOutletWiseMenuItems A 
	--CROSS JOIN Location_Ref B WHERE B.Active = 1


	If(OBJECT_ID('tempdb..#TempOutletWiseMenuItems') Is Not Null)
	Begin
	    Drop Table #TempOutletWiseMenuItems
	End	

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
                --SELECT  0 AS Result
				DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
				RAISERROR(@ERRmsg,16,1)
            END
        ELSE 
            BEGIN
                 SELECT  0 AS Result
            END
    END CATCH
END

GO

