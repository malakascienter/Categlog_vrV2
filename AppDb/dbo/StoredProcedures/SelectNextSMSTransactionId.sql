CREATE PROCEDURE [dbo].[SelectNextSMSTransactionId]

AS
BEGIN

BEGIN TRY
BEGIN TRANSACTION InProc

	DECLARE  @NextTransactionId BIGINT
	SET @NextTransactionId = (SELECT NextSMSTransactionId  FROM BackendSettings )
	UPDATE BackendSettings
	SET NextSMSTransactionId = NextSMSTransactionId +1

	SELECT @NextTransactionId

IF @@TRANCOUNT > 0 
    BEGIN
        COMMIT TRANSACTION InProc;
        SELECT  0 AS Result
    END

ELSE
    BEGIN
        SELECT  0 AS Result
END


END TRY
BEGIN CATCH
        IF @@TRANCOUNT > 0 
            BEGIN
                ROLLBACK TRANSACTION
                --SELECT  0 AS Result
				DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
				RAISERROR(@ERRmsg,16,1)
            END
        ELSE 
            BEGIN
                 SELECT  0 AS Result
            END
END CATCH
 

END

GO

