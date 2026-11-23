


CREATE PROCEDURE [dbo].[Sync_spInsertSpotCheckLog]
@PropertyId INT,
@SpotCheckXml VARCHAR(MAX)

AS
SET DATEFORMAT DMY
DECLARE @tSpotCheckfXml XML

SET @tSpotCheckfXml = REPLACE(@SpotCheckXml,'encoding="utf-8"','encoding="ISO-8859-9"') 


BEGIN TRY
	BEGIN TRAN
		
		INSERT INTO POS_SpotCheckLog 
					(PropertyId, SpotCheckNo, Outlet, ShiftNo, ShiftDate, StationID, CashireID, PayTypeCode, IsCash, SystemAmount, NoteType, Nos, Value, AuthorizedUser, SysDate, IsForeignCurrency)
		SELECT	@PropertyId, SpotCheck.element.value('@SpotCheckNo','INT'),
				SpotCheck.element.value('@Outlet','VARCHAR(5)'),
				SpotCheck.element.value('@ShiftNo','INT'),
				CONVERT(VARCHAR(50),SpotCheck.element.value('@ShiftDate','VARCHAR(30)'),103),
				SpotCheck.element.value('@StationID','VARCHAR(250)'),
				SpotCheck.element.value('@CashireID','VARCHAR(20)'), 
				SpotCheck.element.value('@PayTypeCode','VARCHAR(10)'),
				SpotCheck.element.value('@IsCash','BIT'),
				SpotCheck.element.value('@SystemAmount','NUMERIC(18,4)'),
				SpotCheck.element.value('@NoteType','VARCHAR(50)'),
				SpotCheck.element.value('@Nos','INT'),
				SpotCheck.element.value('@Value','NUMERIC(18,4)'),
				SpotCheck.element.value('@AuthorizedUser','VARCHAR(50)'), 
				CONVERT(VARCHAR(50),SpotCheck.element.value('@SysDate','VARCHAR(30)'),103),
				SpotCheck.element.value('@IsForeignCurrency','BIT')
		FROM	@tSpotCheckfXml.nodes('/root/SpotCheck/SpotCheckLog') AS SpotCheck(element)

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

