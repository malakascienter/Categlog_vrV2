-- =============================================
-- Author:		Chiraj
-- Create date: 2020-05-16
-- Description:	Save Item Breakown
-- =============================================
CREATE PROCEDURE [dbo].[Select_ItemPrice_ExcelUploadForApproval]
	@PriceJson NVARCHAR(MAX),
	@PropertyId INT,
	@UserId INT,
	@PriceTypeIdJson NVARCHAR(MAX)
AS
BEGIN TRY
BEGIN TRANSACTION
	
	SET NOCOUNT ON;

	IF OBJECT_ID(N'tempdb..#TempItemPriceDetails') IS NOT NULL
	BEGIN
	DROP TABLE #TempItemPriceDetails
	END
	IF OBJECT_ID(N'tempdb..#TempPriceTypeId') IS NOT NULL
	BEGIN
	DROP TABLE #TempPriceTypeId
	END

	DECLARE @tmp VARCHAR(10); 

	SET @tmp = CHAR(CAST(RAND()*26 AS int)+65) 
         + CHAR(CAST(RAND()*26 AS int)+65) 
         + CHAR(CAST(RAND()*26 AS int)+65)
         + CAST(cast(RAND()*9999 as int) AS VARCHAR(4));

	
	
	SELECT * INTO #TempItemPriceDetails FROM OPENJSON(@PriceJson)
	WITH
	(
			ItemCode VARCHAR(10) '$.ItemCode',
			NewSellingPrice MONEY '$.NewSellingPrice',
			EffectFrom Datetime '$.EffectFrom'
			
	)

		
	SELECT * INTO #TempPriceTypeId FROM OPENJSON(@PriceTypeIdJson)
	WITH
	(
			PriceTypeID INT '$.PriceTypeID',
			PriceTypeName VARCHAR(50) '$.PriceTypeName'
			
	)

	INSERT INTO [dbo].[ItemPriceDetailsTemp]
           ([ItemCode]
           ,[SellingPrice]
           ,[NewSellingPrice]
           ,[EffectFrom]
           ,[BatchID]
		   ,PriceTypeId
		   ,PriceTypeName
		   ,PropertyId)
	SELECT MM.ItemCode, MM.Price ,TM.NewSellingPrice ,TM.EffectFrom ,@tmp,TP.PriceTypeId,TP.PriceTypeName,@PropertyId
	FROM MainMenu MM INNER JOIN #TempItemPriceDetails TM ON MM.ItemCode = TM.ItemCode
	CROSS JOIN #TempPriceTypeId TP 
	WHERE MM.PropertyId = @PropertyId

	SELECT MM.ItemCode,mm.Description as ItemName, MM.Price AS SellingPrice ,TM.NewSellingPrice AS NewSellingPrice,TM.EffectFrom ,1 as IsValid,'Valid Item' as Msg,TM.[BatchID],TM.PriceTypeID,TM.PriceTypeName
	FROM MainMenu MM INNER JOIN [ItemPriceDetailsTemp] TM ON MM.ItemCode = TM.ItemCode AND MM.PropertyId = TM.PropertyId
	WHERE TM.BatchID = @tmp AND MM.PropertyId = @PropertyId AND TM.PropertyId = @PropertyId

	IF OBJECT_ID(N'tempdb..#TempItemPriceDetails') IS NOT NULL
	BEGIN
	DROP TABLE #TempItemPriceDetails
	END
	IF OBJECT_ID(N'tempdb..#TempPriceTypeId') IS NOT NULL
	BEGIN
	DROP TABLE #TempPriceTypeId
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

