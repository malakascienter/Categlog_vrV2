
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_CancelOrder
	-- Add the parameters for the stored procedure here
	@OrderHeaderID INT,
	@User INT,
	@ID INT OUTPUT
AS
BEGIN
BEGIN TRY
BEGIN TRANSACTION
	UPDATE dbo.OrderHeaders SET IsCancel=1,CancelDate=GETDATE(),CanceledUser=@User WHERE Id=@OrderHeaderID
    SET @ID=1
COMMIT TRAN
END TRY
 BEGIN CATCH
            RETURN CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
            IF @@TRANCOUNT > 0
                ROLLBACK TRAN 
				SET @ID=-1
				
        END CATCH

END

GO

