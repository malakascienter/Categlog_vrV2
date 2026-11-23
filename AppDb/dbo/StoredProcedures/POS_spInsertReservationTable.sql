
CREATE PROCEDURE [dbo].[POS_spInsertReservationTable]
@ReservationWiseTableJson VARCHAR(MAX),
@PropertyId INT,
@ResNo INT,
@UserId INT
AS

BEGIN
BEGIN  TRY
BEGIN TRANSACTION

	DELETE FROM ReservationWiseTable  WHERE ReservationNo = @ResNo AND PropertyId = @PropertyId 

	INSERT INTO ReservationWiseTable(ReservationNo,TableID,PropertyId,CreateDate,CreateUserId)
	SELECT @ResNo,TableID,@PropertyId,getdate(),@UserId
	FROM OPENJSON(@ReservationWiseTableJson)  
	WITH 
	(		
		TableID  INT '$.TableID'
	)
    
	UPDATE Reservation
	SET TableID =  ISNULL((SELECT TOP(1) TableID FROM ReservationWiseTable WHERE ReservationNo = @ResNo AND PropertyId = @PropertyId ),0),
		IsUpload = 0
	WHERE ReservationNo = @ResNo  AND PropertyId = @PropertyId 


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

