




CREATE PROCEDURE [dbo].[Sync_spInsertLog]
@Logxml VARCHAR(MAX)
AS

DECLARE @tLogxml XML, @PropertyId INT, @Outlet VARCHAR(5), @RowNumber AS INT

SET @tLogxml = REPLACE(@Logxml,'encoding="utf-8"','encoding="ISO-8859-9"') 


BEGIN TRY
	BEGIN TRAN
		
		--SET @PropertyId = (SELECT TOP 1 ISNULL(SyncLog.element.value('@PropertyId','INT'),0) FROM	@tLogxml.nodes('/root/Sync/Log') AS SyncLog(element)
		--					ORDER BY ISNULL(SyncLog.element.value('@PropertyId','INT'),0) DESC)
		SELECT	TOP 1 @PropertyId = ISNULL(SyncLog.element.value('@PropertyId','INT'),0),
				@Outlet = ISNULL(SyncLog.element.value('@Outlet','VARCHAR(5)'),'')
		FROM	@tLogxml.nodes('/root/Sync/Log') AS SyncLog(element)
		ORDER BY ISNULL(SyncLog.element.value('@PropertyId','INT'),0) DESC


		IF EXISTS (SELECT Name FROM  Companies WHERE CompanyID = @PropertyId AND IsRestaurant = 0)
			BEGIN
				DELETE FROM Sync_Log WHERE PropertyId = @PropertyId
			END
		ELSE
			BEGIN
				DELETE FROM Sync_Log WHERE PropertyId = @PropertyId AND Outlet = @Outlet
			END

		SET @RowNumber = @PropertyId * 100--(SELECT ISNULL(MAX(ID),0) FROM Sync_Log)

		INSERT INTO Sync_Log
			(ID, PropertyId, Outlet, Description, SysDate, IsError)
		SELECT	@RowNumber + ROW_NUMBER() OVER(ORDER BY SyncLog.element.value('@PropertyId','INT')),
				SyncLog.element.value('@PropertyId','INT'), @Outlet, --ISNULL(SyncLog.element.value('@Outlet','VARCHAR(5)'),''),
				SyncLog.element.value('@Description','VARCHAR(MAX)'), GETDATE(), SyncLog.element.value('@IsError','BIT')
		FROM	@tLogxml.nodes('/root/Sync/Log') AS SyncLog(element)

COMMIT TRAN 
END TRY

BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @Msg NVARCHAR(200)
	SET @Msg = ERROR_MESSAGE()
	INSERT INTO POS_DatabaseErrorLog (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)	
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),@Msg)
	RAISERROR(@Msg,16,1)
END CATCH

GO

