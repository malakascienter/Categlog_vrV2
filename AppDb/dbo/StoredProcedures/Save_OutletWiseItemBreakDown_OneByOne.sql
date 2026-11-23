
CREATE PROCEDURE [dbo].[Save_OutletWiseItemBreakDown_OneByOne]
	@MainMenuCode VARCHAR(10),
	@RecipeCode NVARCHAR(20),
	@Qty MONEY,
	@OutletList NVARCHAR(MAX),
	@PropertyId INT
AS
BEGIN TRY
BEGIN TRANSACTION
	
	SET NOCOUNT ON;

	IF OBJECT_ID(N'tempdb..#TmpOutlet') IS NOT NULL
	BEGIN
	DROP TABLE #TmpOutlet
	END

	SELECT * INTO #TmpOutlet FROM OPENJSON(@OutletList)
	WITH
	(
			OutletCode VARCHAR(5) '$.OutletCode'
	)

	Delete FROM OutletWiseItemBreakDown where  MainMenuCode=@MainMenuCode AND RecipeCode = @RecipeCode  AND Outlet IN (SELECT OutletCode FROM #TmpOutlet) and PropertyId = @PropertyId


	INSERT INTO OutletWiseItemBreakDown (MainMenuCode, RecipeCode, Qty,Outlet,PropertyId)
	SELECT @MainMenuCode,@RecipeCode,@Qty,L.code,@PropertyId
	FROM Location_Ref  L
	WHERE L.code IN (SELECT OutletCode FROM #TmpOutlet) and L.PropertyId = @PropertyId

	IF OBJECT_ID(N'tempdb..#TmpOutlet') IS NOT NULL
	BEGIN
	DROP TABLE #TmpOutlet
	END

	
COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)	
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
	DECLARE @ErrorMsg VARCHAR(MAX) 
	SET @ErrorMsg = ERROR_MESSAGE()
	RAISERROR(@ErrorMsg,16,1)
END CATCH

GO

