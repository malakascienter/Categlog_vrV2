
CREATE PROCEDURE [dbo].[POS_spDeleteReservation]
@ReservationNo INT,
@PropertyId INT,
@UserId INT,
@Username VARCHAR(MAX)
AS

BEGIN
BEGIN  TRY
BEGIN TRANSACTION

DECLARE @CurrentDate DATE
DECLARE @ReservationDate DATE
	
SELECT @CurrentDate = CurrentDate FROM Companies WHERE CompanyID = @PropertyId
SELECT @ReservationDate = ReservationDate  FROM Reservation WHERE ReservationNo = @ReservationNo AND PropertyId = @PropertyId 

	

IF NOT EXISTS( SELECT * FROM ReservationPayment WHERE ReservationNo = @ReservationNo AND PropertyId = @PropertyId )
BEGIN

	IF( @CurrentDate <= @ReservationDate  )
	BEGIN

		UPDATE Reservation
		SET IsCancel = 1,
		IsUpload = 0,
		CancelDate = GETDATE(),
		CancelUser = @Username
		WHERE ReservationNo = @ReservationNo AND PropertyId = @PropertyId 

	END
	ELSE
	BEGIN

		RAISERROR ('Reservation cannot be canceled.!',16,1)  

	END

END
ELSE
BEGIN

RAISERROR ('Reservation cannot be canceled because the payment related to the reservation is exist.!',16,1)  

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
END

GO

