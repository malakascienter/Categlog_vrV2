
CREATE PROCEDURE [dbo].[SP_RET_Select_RetailSalesRecipients]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  ID,
            HotelCode,
            EMailAddress,
            IsActive,
            EmailTo,
            EmailCC,
            EmailBCC,
            IsRetailSalesMail,
            RetailSalesLastSentOn
    FROM    dbo.INV_ReportSendEmail
    WHERE   IsActive          = 1
      AND   IsRetailSalesMail = 1;
END

GO

