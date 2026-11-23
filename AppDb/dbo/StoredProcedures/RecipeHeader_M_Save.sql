-- =============================================
-- Author:		chiraj
-- Create date: 2019-2-7
-- Description:	Save Recipe header table data
-- =============================================
CREATE PROCEDURE [dbo].[RecipeHeader_M_Save] 
 @RecipeCode VARCHAR(6),
 @Description VARCHAR(50),
 @UserId INT,
 @Operation CHAR(1),
 @PropertyId INT,
 @IsBanquetRecipe BIT,
 @AdditionalCost DECIMAL(18,2),
 @IsPercentage BIT
 --LowerVariencePerc , HigherVariencePerc	
AS
BEGIN TRY
BEGIN TRANSACTION

	DECLARE @Id BIGINT

	IF @Operation='I'
	BEGIN
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

		END
	END
	ELSE
	BEGIN

		SELECT @Id = Id FROM RecipeHeader WHERE RecipeCode=@RecipeCode AND PropertyId=@PropertyId
		-- Audit trail ----------------------------		
		EXEC HotelResWeb_AuditTail_WriteToLog 'RecipeHeader',@Id,'POS','POSRHU','U',@UserId,'','','','','',@PropertyId
		-- End of Audit trail ---------------------

		UPDATE RecipeHeader 
		SET
		Description=@Description
		,UpdateUserId=@UserId
		,UpdatedDateTime=GETDATE(),
		PropertyId=@PropertyId,
		IsUpload=0,
		IsBanquetRecipe = @IsBanquetRecipe,
		AdditionalCost = @AdditionalCost,
		IsPercentage = @IsPercentage
		WHERE RecipeCode=@RecipeCode AND PropertyId=@PropertyId


		

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

