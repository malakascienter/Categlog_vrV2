



CREATE PROCEDURE [dbo].[Sync_spInsertUserActivityLog]
@PropertyId INT,
@ActivityLogXml VARCHAR(MAX)

AS
SET DATEFORMAT DMY
DECLARE @tActivityLogXml XML

SET @tActivityLogXml = REPLACE(@ActivityLogXml,'encoding="utf-8"','encoding="ISO-8859-9"') 

CREATE TABLE #ActivityLog (ID BIGINT, UserId VARCHAR(20), WaiterCode VARCHAR(20), Outlet VARCHAR(5), OrderNo VARCHAR(15), TempOrderNo VARCHAR(15),
							OrderDate VARCHAR (100), POSNo VARCHAR(5), ComputerName VARCHAR (100), AccessCode VARCHAR(100), Remark VARCHAR(250), 
							SysDate VARCHAR (100), ProductVersion VARCHAR(50) )
BEGIN TRY
	BEGIN TRAN

		INSERT INTO #ActivityLog 
					(ID, UserId, WaiterCode, Outlet, OrderNo, TempOrderNo, OrderDate, POSNo, ComputerName, AccessCode, Remark, SysDate, ProductVersion)
		SELECT	ActivityLog.element.value('@ID','INT'), 
				ActivityLog.element.value('@UserId','VARCHAR(20)'), 
				ActivityLog.element.value('@WaiterCode','VARCHAR(20)'), 
				ActivityLog.element.value('@Outlet','VARCHAR(5)'),
				ActivityLog.element.value('@OrderNo','VARCHAR(15)'),
				ActivityLog.element.value('@TempOrderNo','VARCHAR(15)'),
				ActivityLog.element.value('@OrderDate','VARCHAR(50)'),
				ActivityLog.element.value('@POSNo','VARCHAR(5)'),
				ActivityLog.element.value('@ComputerName','VARCHAR(100)'),
				ActivityLog.element.value('@AccessCode','VARCHAR(100)'),
				ActivityLog.element.value('@Remark','VARCHAR(250)'),
				ActivityLog.element.value('@SysDate','VARCHAR(30)'),
				ActivityLog.element.value('@ProductVersion','VARCHAR(50)')
		FROM	@tActivityLogXml.nodes('/root/User/ActivityLog') AS ActivityLog(element)

		DELETE FROM POS_UserActivityLog WHERE PropertyId = @PropertyId AND ID IN (SELECT ID FROM #ActivityLog)

		INSERT INTO POS_UserActivityLog 
				(PropertyId, ID, UserId, WaiterCode, Outlet, OrderNo, TempOrderNo, OrderDate, POSNo, ComputerName, AccessCode, Remark, SysDate, ProductVersion)
		SELECT	@PropertyId, ID, UserId, WaiterCode, Outlet, OrderNo, TempOrderNo, CONVERT(DATETIME,OrderDate , 102), 
		POSNo, ComputerName, AccessCode, Remark, 
				CONVERT(DATETIME, SysDate, 102), ProductVersion
		FROM	#ActivityLog

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

