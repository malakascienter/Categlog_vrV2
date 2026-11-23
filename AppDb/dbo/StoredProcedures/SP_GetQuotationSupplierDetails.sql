-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-05-23
-- Description:	lOADING Quotation wise supplier details

-- [dbo].[SP_GetQuotationSupplierDetails] 1,'U',1

-- =============================================
CREATE PROCEDURE [dbo].[SP_GetQuotationSupplierDetails] 
	@ID INT,
	@Mode CHAR(3),
	@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;

	IF(@Mode = 'U')
	BEGIN

	SELECT RH.DocumentNo , RH.Id RequestHeaderID,QU.ID QuotationRequestId,QU.DocNo, SU.ID SupplierId,SU.Name SupplierName,SU.BSPCODE
	,LO.Name Location,RH.LocationID,ISNULL(QD.IsQuotationUploaded,0) IsQuotationUploaded,QD.QuotationFilePath,CASE WHEN QD.MailStatus = 'S' THEN 'Success' WHEN QD.MailStatus = 'F' THEN 'Fail' ELSE 'None' END AS MailStatus, (SELECT TG.TaxTypeId,ChargeRate AS Rate,TD.Name FROM TaxGroupDetails  TG
		INNER JOIN TaxDetails TD ON TD.TaxTypeId = TG.TaxTypeId FOR JSON PATH) AS TaxDetailJson
	FROM RequestHeaders RH
	INNER JOIN QuotationRequestHeader QU ON RH.Id = QU.PurchaseRequestID
	INNER JOIN QuotationRequestdetail QD ON QD.QuotationRequestId = QU.ID
	INNER JOIN Suppliers SU ON SU.ID = QD.SupplierId
	INNER JOIN Locations LO ON LO.ID = RH.LocationID
	WHERE QU.Status='P'
	AND RH.ID = @ID AND RH.RequestType='RP'
	AND QU.IsDocUpload=0
	END

	IF(@Mode = 'I')
	BEGIN
	SELECT RH.Id RequestHeaderID,SIH.Id ItemID,SIH.Name ItemName,SIH.StockItemCode,UN.Id UnitID, UN.Name UnitName
	FROM RequestHeaders RH
	INNER JOIN RequestDetails RD ON RH.Id = RD.RequestHeaderID
	INNER JOIN StockItemHeaders SIH ON SIH.Id = RD.StockItemID
	INNER JOIN Units UN ON UN.Id = RD.UnitID
	WHERE RH.ID = @ID
	AND RH.IsApproved=1
	AND RH.RequestType='RP'

	END
END

GO

