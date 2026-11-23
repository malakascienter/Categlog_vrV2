
CREATE PROCEDURE [dbo].[SP_RET_Update_RetailSalesLastSentOn]
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE  dbo.INV_ReportSendEmail
    SET     RetailSalesLastSentOn = GETDATE()
    WHERE   IsActive          = 1
      AND   IsRetailSalesMail = 1;
END

GO

