-- =============================================
-- Author:		Nivesh
-- Create date: 2025-05-22
-- Description:	Get Quotation Wise PurchaseRequest

--  [dbo].[SP_GetQuotationWisePurchaseRequest] 1,'R'

-- =============================================
CREATE PROCEDURE [dbo].[SP_GetQuotationWisePurchaseRequest] 
@PropertyID INT,
@Mode CHAR(3) = 'R'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@Mode='R')
	BEGIN
   SELECT RH.DocumentNo AS text, RH.Id id , CASE WHEN QRH.ID IS NULL THEN 0 ELSE 1 END AS IsOldPR, QRH.ID AS QuotaionID
   FROM RequestHeaders RH
   LEFT JOIN PoWisePRs PWP ON PWP.RequestHeaderID = RH.Id
   LEFT JOIN QuotationRequestHeader QRH ON QRH.PurchaseRequestID = RH.Id AND QRH.PropertyID = RH.PropertyID
   WHERE PWP.RequestHeaderID IS NULL AND RH.DocumentStatus = 'P' 
   AND RH.QuotationStatus NOT IN ('X') -- Added by Ravindu 2025-12-01
   AND RH.IsApproved =1 AND RH.PropertyID = @PropertyID
   --AND QRH.ID IS NULL
   AND RH.RequestType='RP'
   AND RH.QuotationStatus <>'C' --For modifing Quotation requst that not Approved
   AND (QRH.IsDocUpload <> 1 OR QRH.Id IS NULL)
   ORDER BY RH.Id DESC,RH.SystemDate

   END

   IF(@Mode='U')
   BEGIN

		SELECT RH.DocumentNo AS text, RH.Id id 
		FROM RequestHeaders RH
		INNER JOIN QuotationRequestHeader QU ON RH.Id = QU.PurchaseRequestID
		WHERE QU.Status='P' AND QU.IsDocUpload =0 AND RH.PropertyID = @PropertyID
		 AND RH.RequestType='RP';

   END

   IF(@Mode = 'C')
   BEGIN
		SELECT RH.DocumentNo AS text, RH.Id id 
		FROM RequestHeaders RH
		INNER JOIN QuotationRequestHeader QU ON RH.Id = QU.PurchaseRequestID
		WHERE QU.Status='P' AND QU.IsDocUpload =1 AND RH.PropertyID = @PropertyID
		 AND RH.RequestType='RP';
   END
END

GO

