CREATE PROCEDURE [dbo].[Sync_spInsertCashSkim]
@PropertyID INT,
@CashSkimXml VARCHAR(MAX)

AS
SET DATEFORMAT DMY
DECLARE @tCashSkimXml XML

SET @tCashSkimXml = REPLACE(@CashSkimXml,'encoding="utf-8"','encoding="ISO-8859-9"') 


BEGIN TRY
	BEGIN TRAN
		DECLARE @SkimNo BIGINT, @ShiftNo INT, @ShiftDate DATE

		SELECT	CashSkim.element.value('@SkimNo','BIGINT') AS SkimNo,
				CashSkim.element.value('@ShiftNo','INT') AS ShiftNo,
				CONVERT(DATETIME,CashSkim.element.value('@ShiftDate','VARCHAR(30)'),103) AS ShiftDate INTO #CashSkim
		FROM	@tCashSkimXml.nodes('/root/CashSkim/CashSkimDetail') AS CashSkim(element)

		WHILE EXISTS (SELECT SkimNo FROM #CashSkim)
			BEGIN
				SELECT	@SkimNo = SkimNo, @ShiftNo = ShiftNo, @ShiftDate = ShiftDate FROM	#CashSkim
				DELETE	FROM POS_CashSkim WHERE SkimNo = @SkimNo AND ShiftNo = @ShiftNo AND ShiftDate = @ShiftDate
				DELETE	FROM #CashSkim WHERE SkimNo = @SkimNo AND ShiftNo = @ShiftNo AND ShiftDate = @ShiftDate
			END
		
		INSERT INTO POS_CashSkim 
					(PropertyId, ID, SkimNo, ShiftNo, ShiftDate, CashireId, Outlet, StationID, CurrencyType, Nos, Value,  SysDate)
		SELECT	@PropertyId, CashSkim.element.value('@ID','INT'),
				CashSkim.element.value('@SkimNo','BIGINT'),
				CashSkim.element.value('@ShiftNo','VARCHAR(10)'),
				CONVERT(VARCHAR(50),CashSkim.element.value('@ShiftDate','VARCHAR(30)'),103),
				CashSkim.element.value('@CashireId','VARCHAR(20)'), 
				CashSkim.element.value('@Outlet','VARCHAR(5)'),
				CashSkim.element.value('@StationID','VARCHAR(100)'),
				CashSkim.element.value('@CurrencyType','VARCHAR(50)'),
				CashSkim.element.value('@Nos','INT'),
				CashSkim.element.value('@Value','NUMERIC(18,4)'),
				CONVERT(VARCHAR(50),CashSkim.element.value('@SysDate','VARCHAR(30)'),103)
		FROM	@tCashSkimXml.nodes('/root/CashSkim/CashSkimDetail') AS CashSkim(element)

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

