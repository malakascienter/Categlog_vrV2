
-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
CREATE  PROCEDURE [dbo].[Category_M_Save]  
	@Code   CHAR(3),  
	@Description VARCHAR(25), 
	@Prefix VARCHAR(3),  
	@Active  BIT,  
	@Operation CHAR(1),  
	@UserId    INT,  
	@Colour VARCHAR(9),
	@PropertyId INT,
	@IsEButlerCategory BIT,
	@Seq INT,
	@Classification01Id INT,
	@Classification02Id INT,
	@PopularityThreshold INT,
	@ProfitabilityThreshold INT
AS  
BEGIN  TRY
	SET NOCOUNT ON;

	DECLARE @ClassificationWiseCategoryEnable BIT
	SELECT @ClassificationWiseCategoryEnable = ClassificationWiseCategoryEnable FROM Companies WHERE CompanyID = @PropertyId

	DECLARE @Remark NVARCHAR(250)
	DECLARE @NextCatgId INT	 
	IF @Operation ='I'  
	BEGIN 
		IF EXISTS (SELECT 1 FROm Category where PropertyId=@PropertyId AND (code=@Code OR Description=@Description))         
		BEGIN  
			RAISERROR('Category Code OR Description already exists',16,1)  
		END  
		ELSE IF EXISTS (SELECT 1 FROm Category where PropertyId=@PropertyId AND (Prefix=@Prefix))         
		BEGIN  


			IF( @ClassificationWiseCategoryEnable = 0 )
			BEGIN

				RAISERROR('Prefix already exists',16,1)  

			END

			
		END  
		ELSE 
		BEGIN 	


			DECLARE @UniquePrefix VARCHAR(2)

			IF( @ClassificationWiseCategoryEnable = 1 )
			BEGIN

				IF OBJECT_ID(N'tempdb..#TempUniquePrefix') IS NOT NULL
				BEGIN
				DROP TABLE #TempUniquePrefix
				END

				CREATE TABLE #TempUniquePrefix (
					UniquePrefix VARCHAR(2)
				);

				INSERT INTO #TempUniquePrefix
				EXEC dbo.sp_GetUniquePrefix @PropertyId;

				SELECT TOP(1) @UniquePrefix = UniquePrefix  FROM #TempUniquePrefix;
				SET @Prefix = @UniquePrefix


				IF OBJECT_ID(N'tempdb..#TempUniquePrefix') IS NOT NULL
				BEGIN
				DROP TABLE #TempUniquePrefix
				END
		

			END
			
			
			SET @NextCatgId=(SELECT CatgId  FROM category where Code = @Code AND PropertyId=@PropertyId) 
			-- audit trail	 
			EXEC [dbo].[AuditTrail_InsertToHistory] 'Category',@NextCatgId
			-- end of audit trail

			INSERT INTO Category(Code,Description,Prefix,Seq,Colour,Active,PropertyId,IsUpload,CreatedUserId,CreatedDateTime,IsEButlerCategory,Classification01Id,Classification02Id,PopularityThreshold,ProfitabilityThreshold)
			values (@Code,@Description,ISNULL(@Prefix,''),@Seq,@Colour,@Active,@PropertyId,0,@UserId,GETDATE(),@IsEButlerCategory,@Classification01Id,@Classification02Id,@PopularityThreshold,@ProfitabilityThreshold)  
			
			--IF( @ClassificationWiseCategoryEnable = 0 )
			--BEGIN

				INSERT INTO MainMenuItemCode_DocNos(Code, Prefix, NextNo, Length,PropertyId)VALUES(@Code,TRIM(ISNULL(@Prefix,'')),1,4,@PropertyId)

			--END
			
			 
			-- audit trail				
			SET @Remark = 'Category '+@Code+', '+@Description+' created.';
			EXEC [dbo].[AuditTrail_InsertTableChanges] 'Category',@NextCatgId,@UserId,'I',@Remark
			-- end of audit trail	
		END     
	END    
	ELSE IF @Operation ='U'  
	BEGIN  
		
		--IF EXISTS(SELECT 1 FROm BillTrans where Category=@Code)       
		--BEGIN  
		--	RAISERROR('Category already used ,You can not update the record',16,1)  
		--END  
		--ELSE  
		IF EXISTS (SELECT 1 FROm Category where PropertyId=@PropertyId AND Prefix=@Prefix and Code<>@Code)         
		BEGIN  

			IF( @ClassificationWiseCategoryEnable = 0 )
			BEGIN

				RAISERROR('Category Prefix already exists',16,1)  

			END
			
		END  
		ELSE
		BEGIN
			DECLARE @CURID INT

			SELECT @CURID = CatgId FROM Category WHERE Code = @Code AND PropertyId=@PropertyId
			-- audit trail	 
			EXEC [dbo].[AuditTrail_InsertToHistory] 'Category',@CURID
			-- end of audit trail	
			--update menu item doc no table--


			UPDATE Category  
			SET    
			Description = @Description,  
			Prefix= CASE WHEN @ClassificationWiseCategoryEnable = 0 THEN  ISNULL(@Prefix,'') ELSE Prefix END,
			Active =@Active,  
			Colour=@Colour,
			PropertyId=@PropertyId,
			ModifiedUserId=@UserId,
			ModifiedDateTime=GETDATE(),
			IsUpload=0,
			IsEButlerCategory =@IsEButlerCategory,
			Seq = @Seq,
			Classification01Id = @Classification01Id,
			Classification02Id = @Classification02Id,
			PopularityThreshold = @PopularityThreshold,
			ProfitabilityThreshold = @ProfitabilityThreshold
			WHERE Code = @Code AND PropertyId=@PropertyId
			
			
			--DECLARE @ID INT
			--SET @ID=(SELECT CatgId FROM Category WHERE Code = @Code AND PropertyId=@PropertyId )  
			 
			
			IF( @ClassificationWiseCategoryEnable = 0 )
			BEGIN

				UPDATE  MainMenuItemCode_DocNos SET Code=@Code, Prefix=TRIM(ISNULL(@Prefix,'')) WHERE code=(select code from category where prefix=@Prefix AND PropertyId=@PropertyId )

			END


			


			-- audit trail				
			SET @Remark = 'Category '+@Code+', '+@Description+' updated.';
			EXEC [dbo].[AuditTrail_InsertTableChanges] 'Category',@CURID,@UserId,'U',@Remark
			-- end of audit trail	
			
		END
	END 
		
	EXEC Insert_Sync_MasterDataTransferStatus 'Category',@Active,@Code,@PropertyId
		
	END TRY 
BEGIN CATCH
ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH

GO

