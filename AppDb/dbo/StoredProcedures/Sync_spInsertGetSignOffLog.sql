



CREATE PROCEDURE [dbo].[Sync_spInsertGetSignOffLog]
@PropertyId INT,
@SignOffXml VARCHAR(MAX)

AS
SET DATEFORMAT DMY
DECLARE @tSignOffXml XML

SET @tSignOffXml = REPLACE(@SignOffXml,'encoding="utf-8"','encoding="ISO-8859-9"') 


BEGIN TRY
	BEGIN TRAN
		--DELETE FROM POS_UserActivityLog WHERE PropertyId = @PropertyId AND ID IN (SELECT ID FROM #ActivityLog)
		INSERT INTO POS_CashireShiftEndLog 
					(PropertyId, ShiftNo, Cashireid, DType, Nos, Value, SysDate, IsCash, Outlet, SystemAmount, ShiftDate, PayTypeCode, IsForeignCurrency)
		SELECT	@PropertyId, SignOff.element.value('@ShiftNo','INT'), 
				SignOff.element.value('@Cashireid','VARCHAR(20)'), 
				SignOff.element.value('@DType','VARCHAR(20)'), 
				SignOff.element.value('@Nos','VARCHAR(5)'),
				SignOff.element.value('@Value','VARCHAR(15)'),
				SignOff.element.value('@SysDate','VARCHAR(15)'),
				SignOff.element.value('@IsCash','VARCHAR(50)'),
				SignOff.element.value('@Outlet','VARCHAR(5)'),
				SignOff.element.value('@SystemAmount','VARCHAR(100)'),
				SignOff.element.value('@ShiftDate','VARCHAR(100)'),
				SignOff.element.value('@PayTypeCode','VARCHAR(250)'),
				SignOff.element.value('@IsForeignCurrency','VARCHAR(30)')
		FROM	@tSignOffXml.nodes('/root/SignOff/SignOffLog') AS SignOff(element)

		

		

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

