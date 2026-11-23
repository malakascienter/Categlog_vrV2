CREATE PROCEDURE [dbo].[POS_spUpdateOrderReturn]
@PropertyId INT,
@ReturnNo VARCHAR(20),
@RedeemOrderNo VARCHAR(20),
@RedeemOrderDate DATE,
@RedeemOutlet VARCHAR(5)

AS
SET DATEFORMAT DMY 
SET NOCOUNT ON

BEGIN TRY
	BEGIN TRAN

		UPDATE  POS_OrderReturnHeader SET RedeemOrderNo = @RedeemOrderNo,  RedeemOrderDate = @RedeemOrderDate, RedeemOutlet = @RedeemOutlet
		WHERE	PropertyId = @PropertyId AND ReturnNo = @ReturnNo

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

