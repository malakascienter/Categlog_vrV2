-- =============================================
-- Author:		Chiraj
-- Create date: 2020-05-16
-- Description:	Save Item Breakown
-- =============================================
CREATE PROCEDURE [dbo].[Save_ItemBreakDown]
	@MainMenuCode VARCHAR(4),
	@RecipeJson NVARCHAR(MAX),
	@PropertyId INT,
	@AdditionalCost DECIMAL(18,2)
AS
BEGIN TRY
BEGIN TRANSACTION
	
	SET NOCOUNT ON;
	DECLARE @Id BIGINT
	DECLARE @DeleteRowId BIGINT


	IF OBJECT_ID('tempdb..#tempDeleteItemBreakDown') IS NOT NULL
    BEGIN
    DROP TABLE #tempDeleteItemBreakDown
    END


	SELECT * 
	INTO #tempDeleteItemBreakDown
	FROM ItemBreakDown 
	where  MainMenuCode=@MainMenuCode AND PropertyId = @PropertyId



	WHILE EXISTS( SELECT * FROM #tempDeleteItemBreakDown )
	BEGIN

		SELECT TOP(1) @DeleteRowId = Id FROM #tempDeleteItemBreakDown

		-- Audit trail ----------------------------		
		EXEC HotelResWeb_AuditTail_WriteToLog 'ItemBreakDown',@DeleteRowId,'POS','POSIBD','D',0,'','','','','',@PropertyId
		-- End of Audit trail ---------------------

		DELETE TOP(1) FROM #tempDeleteItemBreakDown

	END


	Delete FROM ItemBreakDown where  MainMenuCode=@MainMenuCode AND PropertyId = @PropertyId

	SELECT * INTO #TmpRecipe FROM OPENJSON(@RecipeJson)
	WITH
	(
			Qty INT '$.Qty',
			RecipeCode VARCHAR(6)'$.RecipeCode'
	)

	DECLARE @RecipeCode         VARCHAR(6)
	DECLARE @Qty				INT
	select * from #TmpRecipe
	WHILE EXISTS(SELECT * FROM #TmpRecipe)
	BEGIN
		SELECT TOP(1) @RecipeCode=RecipeCode,@Qty=Qty FROM #TmpRecipe
		INSERT INTO ItemBreakDown (MainMenuCode, RecipeCode, Qty,PropertyId,IsUpload,AdditionalCost)
		VALUES( @MainMenuCode,@RecipeCode,@Qty,@PropertyId,0,@AdditionalCost)


		SET @Id = SCOPE_IDENTITY()
		-- Audit trail ----------------------------		
		EXEC HotelResWeb_AuditTail_WriteToLog 'ItemBreakDown',@Id,'POS','POSIBI','I',0,'','','','','',@PropertyId
		-- End of Audit trail ---------------------

		INSERT INTO ItemBreakDownLog (MainMenuCode, RecipeCode, Qty,PropertyId,IsUpload,AdditionalCost)
		VALUES( @MainMenuCode,@RecipeCode,@Qty,@PropertyId,0,@AdditionalCost)
		
		DELETE TOP (1) FROM #TmpRecipe
	END
COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)	
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
	RAISERROR('Record Not Save.',16,1)
END CATCH

GO

