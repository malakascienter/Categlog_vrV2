
CREATE PROCEDURE [dbo].[Update_ItemPrice_ExcelUploadForApprovalByBatchID] 

@BatchId				VARCHAR(10),
@PropertyId					INT,
@UserId						INT
AS
BEGIN	TRY
BEGIN TRANSACTION
	
	SET NOCOUNT ON;

	IF OBJECT_ID(N'tempdb..#TempMenuItem') IS NOT NULL
	BEGIN
	DROP TABLE #TempMenuItem
	END

	SELECT * 
	INTO #TempMenuItem
	FROM ItemPriceDetailsTemp
	WHERE BatchID = @BatchId


WHILE EXISTS( SELECT * FROM #TempMenuItem )
BEGIN

 DECLARE  @ItemCode VARCHAR(10),@NewSellingPrice MONEY,@EffectFrom DATE,@PriceTypeId INT

 SELECT TOP(1) @ItemCode = ItemCode,@NewSellingPrice = NewSellingPrice,@EffectFrom = EffectFrom,@PriceTypeId = PriceTypeId  FROM #TempMenuItem



IF NOT EXISTS(SELECT 1 FROM  POS_OutletWiseMenuItemPrice WHERE MenuItemCode =  @ItemCode AND PropertyId = @PropertyId  )
BEGIN

 
INSERT INTO [dbo].[POS_OutletWiseMenuItemPrice]
           ([MenuItemCode]
           ,[OutletCode]
           ,[PriceTypeID]
           ,[Price]
           ,[IsActive]
           ,[CreatedUser]
           ,[CreatedDate]
           ,[ModifiedUser]
           ,[ModifiedDate]
           ,[PropertyId])
     SELECT
           @ItemCode
           ,L.code
           ,@PriceTypeId
           ,@NewSellingPrice
           ,1
           ,@UserId
           ,GETDATE()
           ,@UserId
           ,GETDATE()
           ,@PropertyId
		   FROM Location_Ref L WHERE L.Active = 1

END
ELSE
BEGIN
		IF( @EffectFrom = CONVERT(DATE,GETDATE()) )
		BEGIN
		
			UPDATE MM
			SET MM.Price = @NewSellingPrice,
			    MM.NewPrice = @NewSellingPrice,
				MM.ModifiedUser = @UserId,
				MM.ModifiedDate = GETDATE(),
				MM.EffectiveDate = @EffectFrom
			FROM POS_OutletWiseMenuItemPrice MM 
			WHERE MenuItemCode = @ItemCode  AND PriceTypeID = @PriceTypeId AND PropertyId = @PropertyId

			UPDATE MainMenu SET IsUpload = 0 WHERE ItemCode =  @ItemCode AND PropertyId = @PropertyId

			DELETE FROM Sync_MasterDataTransferStatus WHERE DataType = 'MainMenu' AND PropertyId = @PropertyId AND Code = @ItemCode

			INSERT INTO Sync_MasterDataTransferStatus
			SELECT @PropertyId,mm.ItemCode, A.OutletCode, 'MainMenu',MM.Active
			FROM POS_OutletWiseMenuItems A 
			inner join MainMenu mm on a.MenuCode = mm.ItemCode 	AND A.PropertyId = MM.PropertyId
			INNER JOIN Location_Ref B ON B.code = A.OutletCode  AND B.PropertyId = A.PropertyId
			WHERE B.Active = 1 AND MM.PropertyId = @PropertyId AND A.PropertyId = @PropertyId AND B.PropertyId = @PropertyId AND MM.ItemCode = @ItemCode AND A.MenuCode = @ItemCode


			INSERT INTO Sync_MasterDataTransferStatus(PropertyId,Code,Outlet,DataType,Active)
			SELECT @PropertyId,@ItemCode AS Code, L.Code, 'MainMenu',0
			FROM Location_Ref L
			WHERE L.PropertyId = @PropertyId AND L.code NOT IN (SELECT A.OutletCode FROM POS_OutletWiseMenuItems A WHERE A.PropertyId = @PropertyId AND A.MenuCode = @ItemCode) 


		
		END
		ELSE IF( @EffectFrom > CONVERT(DATE,GETDATE()) )
		BEGIN
		
			UPDATE MM
			SET MM.NewPrice = @NewSellingPrice,
				MM.ModifiedUser = @UserId,
				MM.ModifiedDate = GETDATE(),
				MM.EffectiveDate = @EffectFrom
			FROM POS_OutletWiseMenuItemPrice MM 
			WHERE MenuItemCode = @ItemCode  AND PriceTypeID = @PriceTypeId AND PropertyId = @PropertyId
		
		END
END




--UPDATE MainMenu SET IsUpload = 0 WHERE ItemCode =  @ItemCode AND PropertyId = @PropertyId

--INSERT INTO Sync_MasterDataTransferStatus
--SELECT @PropertyId,mm.ItemCode, A.OutletCode, 'MainMenu',MM.Active
--FROM POS_OutletWiseMenuItems A 
--inner join MainMenu mm on a.MenuCode = mm.ItemCode 	AND A.PropertyId = MM.PropertyId
--INNER JOIN Location_Ref B ON B.code = A.OutletCode  AND B.PropertyId = A.PropertyId
--WHERE B.Active = 1 AND MM.PropertyId = @PropertyId AND A.PropertyId = @PropertyId AND B.PropertyId = @PropertyId AND MM.ItemCode = @ItemCode AND A.MenuCode = @ItemCode

DELETE TOP(1) FROM #TempMenuItem

END

	
	
	 

	IF OBJECT_ID(N'tempdb..#TempMenuItem') IS NOT NULL
	BEGIN
	DROP TABLE #TempMenuItem
	END

	DELETE  
	FROM ItemPriceDetailsTemp
	WHERE BatchID = @BatchId


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

