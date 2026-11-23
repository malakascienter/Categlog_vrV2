--SP_GetOnlineReservationTimeSlot
CREATE PROCEDURE [dbo].[SP_GetOnlineReservationTimeSlot]

AS
BEGIN TRY 
	SELECT	TimeSlotID, Description + ' - ' + LEFT(CONVERT(TIME, FromTime),5) + ' to ' + LEFT(CONVERT(TIME, ToTime),5) AS Description,
	CAST(FromTime AS TIME) FromTime, CAST(ToTime AS TIME) ToTime
	FROM	POS_ReservationTimeSlot
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

GO

