
CREATE PROCEDURE [dbo].[SP_RET_Select_RetailSalesLastSentOnEmail]
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
      AND   IsRetailSalesMail = 1
      AND   CONVERT(VARCHAR(10), RetailSalesLastSentOn, 111)
          = CONVERT(VARCHAR(10), GETDATE(), 111);
END

GO

