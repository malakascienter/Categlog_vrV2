
CREATE PROCEDURE [dbo].[POS_spDeleteReservationPayment]
@Id INT,
@PropertyId INT,
@Username VARCHAR(MAX)
AS

BEGIN
BEGIN  TRY
BEGIN TRANSACTION

	DECLARE @Amount MONEY
	DECLARE @ReservationNo INT

	SELECT @Amount = Amount,@ReservationNo =ReservationNo  FROM ReservationPayment WHERE Id = @Id  AND PropertyId = @PropertyId  


	DECLARE @CurrentDate DATE
	DECLARE @ReservationDate DATE
	
	SELECT @CurrentDate = CurrentDate FROM Companies WHERE CompanyID = @PropertyId
	SELECT @ReservationDate = ReservationDate  FROM Reservation WHERE ReservationNo = @ReservationNo AND PropertyId = @PropertyId 


IF( @CurrentDate <= @ReservationDate  )
BEGIN

	UPDATE ReservationPayment
	SET IsCancel = 1,CancelDate = GETDATE(),CancelUser = @Username
	WHERE Id = @Id  AND PropertyId = @PropertyId 


	UPDATE Reservation
	SET AdvanceAmount = AdvanceAmount - @Amount,
	IsUpload = 0
	WHERE ReservationNo = @ReservationNo AND PropertyId = @PropertyId 

END
ELSE
BEGIN

RAISERROR ('Reservation payment cannot be canceled.!',16,1)    

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

