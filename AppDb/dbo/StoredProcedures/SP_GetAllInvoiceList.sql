
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_GetAllInvoiceList
	-- Add the parameters for the stored procedure here
	@Operation INT 
AS
BEGIN
	SELECT TI.* FROM dbo.Temp_InvoiceHeader TI FULL JOIN dbo.Temp_InvoicePaymentsDetails IP ON TI.ID=IP.InvoiceHeaderID WHERE IP.ID IS NULL AND TI.ID IS NOT NULL
END

GO

