-- =============================================
-- Author:		Nivesh
-- Create date: 2025-09-01
-- Description:	Update Consumption Based Report
-- =============================================
CREATE PROCEDURE [dbo].[SP_UpdateConsumptionBasedReportAsSent] 
	@ReportType NVARCHAR(20),
    @ReportID INT,
    @StringReportDetailID NVARCHAR(MAX)
AS
BEGIN
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
	SET NOCOUNT ON;
    BEGIN TRY
        -- Start transaction
        BEGIN TRANSACTION;

            UPDATE [dbo].[SendReportNotificationDetail]
            SET IsMailSend =1
            WHERE IsMailSend = 0 AND ReportType = @ReportType AND ReportTypeID = @ReportID AND
            Id in (SELECT * FROM STRING_SPLIT(@StringReportDetailID,','))

		COMMIT TRANSACTION;
		
    END TRY
    BEGIN CATCH
        SET @ErrorMessage = ERROR_MESSAGE();
        SET @ErrorSeverity = ERROR_SEVERITY();
        SET @ErrorState = ERROR_STATE();

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;

GO

