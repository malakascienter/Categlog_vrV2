-- =============================================
-- Author:		Nivesh
-- Create date: 2024-05-30
-- Description:	Insert SMS OTP to log
-- =============================================
--SP_Insert_SMS_OTP_log '<SMS_OTP_Log xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>0</Id><Request>https://richcommunication.dialog.lk/api/sms/inline/send?q=f27793ea33ccf8e&amp;destination=0767089918&amp;message=This is your OTP 456989&amp;from=TestBlueOrb</Request><Response>0</Response><MobileNo>0767089918</MobileNo><IsSent>true</IsSent><IsFail>false</IsFail><SysDate>0001-01-01T00:00:00</SysDate><TextOTP>This is your OTP 456989</TextOTP></SMS_OTP_Log>'

CREATE PROCEDURE [dbo].[SP_Insert_SMS_OTP_log] 
@XMLDetails AS XML
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 
	
	BEGIN TRANSACTION
----------------------------------------------------------------------
    DECLARE @iDocID INT;

	EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

	INSERT INTO Log_SMS_OTP (Request,Response,MobileNo,IsSent,IsFail,TextOTP)
	SELECT Request,Response,MobileNo,IsSent,IsFail,TextOTP
	FROM
		OPENXML(@iDocID, '/SMS_OTP_Log', 2)
		WITH
		(
		Request varchar(MAX),
		Response varchar(MAX),
		MobileNo nchar(20),
		IsSent bit,
		IsFail bit,
		TextOTP varchar(100)
		);
	SELECT 1
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0
		ROLLBACK TRANSACTION
			DECLARE @ErrorMessage NVARCHAR(4000);  
			DECLARE @ErrorSeverity INT;  
			DECLARE @ErrorState INT;  

			SELECT   
			@ErrorMessage = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState = ERROR_STATE(); 
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
			--Insert Error log
			INSERT INTO OnlineTableReservation_ErrorTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
			VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
	END CATCH;
END

GO

