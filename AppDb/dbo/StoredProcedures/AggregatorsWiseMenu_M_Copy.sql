
CREATE PROCEDURE [dbo].[AggregatorsWiseMenu_M_Copy] 
@PropertyId INT,
@Outlet VARCHAR(5),
@AggregatorId INT,
@UserId INT,
@OutletList VARCHAR(MAX)
AS
BEGIN TRY
BEGIN TRANSACTION
	
	SET NOCOUNT ON;

	DECLARE @CopyOutlet VARCHAR(5)

	IF OBJECT_ID(N'tempdb..#TempOutlet') IS NOT NULL
	BEGIN
	DROP TABLE #TempOutlet
	END

	SELECT * 
	INTO #TempOutlet	
	FROM OPENJSON(@OutletList)  
	WITH 
	(		
		Code   VARCHAR(5) '$.Code',
		Description   VARCHAR(50) '$.Description'
		
	)

	SELECT * 
	INTO #TempOutletValidate	
	FROM OPENJSON(@OutletList)  
	WITH 
	(		
		Code   VARCHAR(5) '$.Code',
		Description   VARCHAR(50) '$.Description'
		
	)

	IF OBJECT_ID(N'tempdb..#TempInvalidItem') IS NOT NULL
	BEGIN
	DROP TABLE #TempInvalidItem
	END

	CREATE TABLE #TempInvalidItem(
	OutletCode VARCHAR(5),
	ItemCode VARCHAR(10),
	)

	IF OBJECT_ID(N'tempdb..#TempMenu') IS NOT NULL
	BEGIN
	DROP TABLE #TempMenu
	END

	CREATE TABLE #TempMenu(
	 MenuCode VARCHAR(10)
	)

	
	INSERT INTO #TempMenu (MenuCode)
	SELECT MenuCode
	FROM AggregatorWiseMenuItem
	WHERE AggregatorId = @AggregatorId  AND PropertyId = @PropertyId AND Outlet = @Outlet


	WHILE EXISTS( SELECT 1 FROM #TempOutletValidate )
	BEGIN

	SELECT TOP(1) @CopyOutlet = Code FROM #TempOutletValidate

	IF( @CopyOutlet !=  @Outlet)
	BEGIN

		INSERT INTO #TempInvalidItem (OutletCode,ItemCode)
		SELECT @CopyOutlet,P.MenuCode
		FROM #TempMenu P WHERE MenuCode NOT IN (SELECT MenuCode FROM POS_OutletWiseMenuItems WHERE OutletCode =  @CopyOutlet AND PropertyId = @PropertyId)
	
	END

	

	 DELETE TOP(1) FROM #TempOutletValidate
	
	END


IF NOT EXISTS( SELECT 1 FROM #TempInvalidItem )
BEGIN

	WHILE EXISTS( SELECT 1 FROM #TempOutlet )
	BEGIN

	SELECT TOP(1) @CopyOutlet = Code FROM #TempOutlet

	IF( @CopyOutlet !=  @Outlet)
	BEGIN
	
	 DELETE FROM AggregatorWiseMenuItem WHERE Outlet = @CopyOutlet

	 INSERT INTO AggregatorWiseMenuItem (MenuCode, AggregatorId, PropertyId,CreatedUserId,CreatedDateTime,Outlet)
	 SELECT MenuCode,AggregatorId,@PropertyId,@UserId,GETDATE(),@CopyOutlet
	 FROM AggregatorWiseMenuItem
	 WHERE AggregatorId = @AggregatorId  AND PropertyId = @PropertyId AND Outlet = @Outlet
	
	END

	

	 DELETE TOP(1) FROM #TempOutlet
	
	END

END


SELECT MM.ItemCode as MenuCode,MM.FullName AS MenuName,L.code AS Outlet ,L.description AS OutletName 
FROM #TempInvalidItem T INNER JOIN MainMenu  MM ON T.ItemCode = MM.ItemCode 
INNER JOIN Location_Ref L ON T.OutletCode = L.code
WHERE MM.PropertyId = @PropertyId  AND L.PropertyId =@PropertyId
	
	
	IF OBJECT_ID(N'tempdb..#TempInvalidItem') IS NOT NULL
	BEGIN
	DROP TABLE #TempInvalidItem
	END
	IF OBJECT_ID(N'tempdb..#TempMenu') IS NOT NULL
	BEGIN
	DROP TABLE #TempMenu
	END
	IF OBJECT_ID(N'tempdb..#TempOutlet') IS NOT NULL
	BEGIN
	DROP TABLE #TempOutlet
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

