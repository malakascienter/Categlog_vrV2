

-- =============================================
-- Author:		Chiraj
-- Create date: 2018-10-31
-- Description:	Save menu item wise printers
-- =============================================
CREATE PROCEDURE [dbo].[MenuItemWise_Printers_Save] 
	@MainMenuCode			VARCHAR(4),
	@ItemwiseprinterJson	NVARCHAR(MAX),
	@UserId					INT,
	@PropertyId				INT,
	@IsSync					BIT = 1
AS
BEGIN TRY
BEGIN TRANSACTION
 
		SELECT	* 
		INTO	#TempMenuItemWisePrinters	
		FROM	OPENJSON(@ItemwiseprinterJson,N'$.PrinterCodelst')
		WITH
		(				
			PrinterCode VARCHAR(2)'$.PrinterCode'				
		)

		--DECLARE @PrinterCode	VARCHAR(2)
			--SELECT * FROM #TempMenuItemWisePrinters
		--WHILE EXISTS (SELECT  PrinterCode FROM #TempMenuItemWisePrinters)
			--BEGIN
				
				--SET @PrinterCode=(SELECT TOP (1) PrinterCode FROM #TempMenuItemWisePrinters)
				IF EXISTS(SELECT 1 FROM ItemWisePrinters WHERE MainMenuCode=@MainMenuCode AND PropertyId=@PropertyId)
					BEGIN
					 --RAISERROR('Menu Item Alredy Assign to Same Printer',16,1)
					 DELETE  FROM ItemWisePrinters WHERE MainMenuCode=@MainMenuCode AND PropertyId=@PropertyId

					 INSERT INTO ItemWisePrinters(MainMenuCode, PrinterCode,PropertyId,IsUpload,CreatedUserId,CreatedDateTime) 
					 SELECT @MainMenuCode, PrinterCode,@PropertyId,0,@UserId,GETDATE() FROM #TempMenuItemWisePrinters

					 UPDATE MainMenu SET IsUpload=0 WHERE ItemCode=@MainMenuCode
					END
				ELSE
					BEGIN
						INSERT INTO ItemWisePrinters(MainMenuCode, PrinterCode,PropertyId,IsUpload,CreatedUserId,CreatedDateTime) 
						SELECT @MainMenuCode, PrinterCode,@PropertyId,0,@UserId,GETDATE() FROM #TempMenuItemWisePrinters
						 UPDATE MainMenu SET IsUpload=0 WHERE ItemCode=@MainMenuCode
					END			  
				--DELETE TOP (1) FROM #TempMenuItemWisePrinters
		--END
		DROP TABLE #TempMenuItemWisePrinters

DECLARE @IsActive BIT
SELECT @IsActive = Active FROM MainMenu WHERE ItemCode = @MainMenuCode AND PropertyId = @PropertyId
SET @IsActive = ISNULL(@IsActive,0)

IF( @IsSync = 1 )
BEGIN

EXEC Insert_Sync_MasterDataTransferStatus 'MainMenu',@IsActive,@MainMenuCode,@PropertyId 

END


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

