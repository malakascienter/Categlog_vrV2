
CREATE PROCEDURE [dbo].[POS_spInsertReservationPayment]
@ReservationNo INT,
@PayCode VARCHAR(MAX),
@Amount MONEY,
@Remark VARCHAR(MAX),
@Username VARCHAR(20),
@PropertyId INT
AS

BEGIN
BEGIN  TRY
BEGIN TRANSACTION


INSERT INTO [dbo].[ReservationPayment]
           ([ReservationNo]
           ,[PayCode]
           ,[PayType]
           ,[Amount]
           ,[Remark]
           ,[CreateUser]
           ,[CreateDate]
           ,[IsCancel]
           ,[CancelUser]
           ,[CancelDate]
           ,[ShiftID]
           ,[Outlet]
           ,[IsUpload]
           ,[PropertyId])
     VALUES
           (@ReservationNo
           ,@PayCode
           ,''
           ,@Amount
           ,@Remark
           ,@Username
           ,GETDATE()
           ,0
           ,''
           ,GETDATE()
           ,0
           ,isnull((SELECT top(1) Outlet FROM Reservation WHERE ReservationNo = @ReservationNo),'')
           ,0
           ,@PropertyId)


		   UPDATE Reservation
		   SET AdvanceAmount = ISNULL(AdvanceAmount,0) + @Amount,IsUpload = 0
		   WHERE ReservationNo = @ReservationNo


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

