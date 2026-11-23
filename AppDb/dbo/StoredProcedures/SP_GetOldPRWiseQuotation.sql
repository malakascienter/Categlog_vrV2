-- =============================================
-- Author:		Nivesh
-- Create date: 2025-07-15
-- Description:	Get OLD PR-wise quotation request
-- =============================================
-- SP_GetOldPRWiseQuotation 6033
CREATE PROCEDURE [dbo].[SP_GetOldPRWiseQuotation] 
	@PRHeaderID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT S.ID AS SupplierID,S.Code, S.BSPCODE, S.Name AS SupplierName, S.Email, QH.filePath AS FilePath ,CASE WHEN QD.MailStatus = 'S' THEN 'Success' WHEN QD.MailStatus = 'F' THEN 'Fail' ELSE 'None' END AS MailStatus
	FROM
	QuotationRequestHeader QH
	INNER JOIN QuotationRequestDetail QD ON QD.QuotationRequestId = QH.Id
	INNER JOIN Suppliers S ON S.ID = QD.SupplierId
	WHERE QH.PurchaseRequestID = @PRHeaderID
END

GO

