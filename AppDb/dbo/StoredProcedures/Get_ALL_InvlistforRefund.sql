
CREATE PROCEDURE [dbo].[Get_ALL_InvlistforRefund]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	SELECT * FROM dbo.InvoiceHeaders WHERE InvoiceMode=1 AND SUBSTRING(InvoiceNo,1,2)='IN'
END

GO

