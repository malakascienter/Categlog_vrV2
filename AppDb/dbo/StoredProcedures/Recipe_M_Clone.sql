-- =============================================
-- Author:		chiraj
-- Create date: 2019-2-7
-- Description:	Save Recipe header table data
-- =============================================
CREATE PROCEDURE [dbo].[Recipe_M_Clone] 
 @RecipeCode VARCHAR(6),
 @Description VARCHAR(50),
 @UserId INT,
 @Operation CHAR(1),
 @PropertyId INT,
 @IsBanquetRecipe BIT,
 @AdditionalCost DECIMAL(18,2),
 @IsPercentage BIT,
 @CloneRecipeCode VARCHAR(6)
AS
BEGIN TRY
BEGIN TRANSACTION

	DECLARE @Id BIGINT

		IF EXISTS(SELECT 1 FROM RecipeHeader WHERE PropertyId=@PropertyId AND(RecipeCode=@RecipeCode OR Description=@Description))
		BEGIN
			RAISERROR('Recipe Code OR Description Already Exists',16,1)
		END
		ELSE
		BEGIN

			INSERT INTO RecipeHeader(RecipeCode, Description, Ord_Type, PropertyId,IsUpload,LowerVariencePerc, HigherVariencePerc,CreatedUserId,CreatedDateTime,IsBanquetRecipe,AdditionalCost,IsPercentage)
			VALUES(@RecipeCode,@Description,'B',@PropertyId,0,0.00,0.00,@UserId,GETDATE(),@IsBanquetRecipe,@AdditionalCost,@IsPercentage)

			SET @Id = SCOPE_IDENTITY()

			-- Audit trail ----------------------------		
			EXEC HotelResWeb_AuditTail_WriteToLog 'RecipeHeader',@Id,'POS','POSRHI','I',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------


			INSERT INTO RecipeDetails(RecipeCode, StockItemCode, Seq, Unit, Qty, Cost, Yeild, Ord_Type, Loc, isMainItem, Type,PropertyId,IsUpload,CreatedUserId,CreatedDateTime)
			SELECT @RecipeCode, StockItemCode, Seq, Unit, Qty, Cost, Yeild, Ord_Type, Loc, isMainItem, Type,PropertyId,0,@UserId,GETDATE() 
			FROM RecipeDetails
			WHERE RecipeCode = @CloneRecipeCode


		END

	INSERT INTO RecipeHeaderLog(RecipeCode, Description, Ord_Type, PropertyId,IsUpload,LowerVariencePerc, HigherVariencePerc,CreatedUserId,CreatedDateTime,IsBanquetRecipe,AdditionalCost,IsPercentage)
	VALUES(@RecipeCode,@Description,'B',@PropertyId,0,0.00,0.00,@UserId,GETDATE(),@IsBanquetRecipe,@AdditionalCost,@IsPercentage)

COMMIT TRANSACTION    
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH

GO

