
CREATE PROCEDURE [dbo].[Sync_spInsertSignOn]
@PropertyID INT,
@SignOnXml VARCHAR(MAX)

AS
SET DATEFORMAT DMY
DECLARE @tSignOnXml XML

SET @tSignOnXml = REPLACE(@SignOnXml,'encoding="utf-8"','encoding="ISO-8859-9"') 


BEGIN TRY
	BEGIN TRAN
		DECLARE @ShiftNo INT, @ShiftDate DATE, @Outlet VARCHAR(10)

		SELECT	SignOn.element.value('@ShiftNo','INT') AS ShiftNo,
				CONVERT(DATETIME,SignOn.element.value('@ShiftDate','VARCHAR(30)'),103) AS ShiftDate,
				SignOn.element.value('@Outlet','VARCHAR(5)') AS Outlet INTO #SignOn
		FROM	@tSignOnXml.nodes('/root/SignOn/SignOnDetail') AS SignOn(element)

		WHILE EXISTS (SELECT ShiftNo FROM #SignOn)
			BEGIN
				SELECT	TOP 1 @ShiftNo = ShiftNo, @ShiftDate = ShiftDate, @Outlet = Outlet FROM	#SignOn
				DELETE	FROM POS_CashierShift WHERE ShiftNo = @ShiftNo AND ShiftDate = @ShiftDate AND Outlet = @Outlet AND PropertyID = @PropertyID
				DELETE	FROM #SignOn WHERE ShiftNo = @ShiftNo AND ShiftDate = @ShiftDate AND Outlet = @Outlet
			END
		
		INSERT INTO POS_CashierShift 
					(PropertyId, ShiftNo, ShiftDate, WaiterCode, IsSignOff, CashFloat, SignOffDate, StationID, Outlet, IsManagerSignOff, SignOnDate, 
					SignOnAuthorizedUser, SignOffTime)
		SELECT	@PropertyId, SignOn.element.value('@ShiftNo','VARCHAR(10)'),
				CONVERT(VARCHAR(50),SignOn.element.value('@ShiftDate','VARCHAR(30)'),103),
				SignOn.element.value('@WaiterCode','VARCHAR(20)'), 
				SignOn.element.value('@IsSignOff','BIT'),
				SignOn.element.value('@CashFloat','NUMERIC(18,4)'),
				CONVERT(VARCHAR(50),SignOn.element.value('@SignOffDate','VARCHAR(30)'),103),
				SignOn.element.value('@StationID','VARCHAR(100)'),
				SignOn.element.value('@Outlet','VARCHAR(5)'),
				SignOn.element.value('@IsManagerSignOff','BIT'),
				CONVERT(VARCHAR(50),SignOn.element.value('@SingOnDate','VARCHAR(30)'),103),
				SignOn.element.value('@SignOffAuthorizedUser','VARCHAR(100)'),
				CONVERT(VARCHAR(50),SignOn.element.value('@SignOffTime','VARCHAR(30)'),103)
		FROM	@tSignOnXml.nodes('/root/SignOn/SignOnDetail') AS SignOn(element)

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

