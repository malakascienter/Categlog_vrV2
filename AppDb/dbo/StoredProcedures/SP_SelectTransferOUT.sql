-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 20 September 2023
-- Description:	Loading Documents for Transfer Out

 -- [dbo].[SP_SelectTransferOUT] 1,'RT',0,'T',8,'2026-07-17'

-- =============================================
CREATE PROCEDURE [dbo].[SP_SelectTransferOUT]
(
@LocationID int,
@RequestType char(2),
@RequestHeaderID int,
@Operation char(1),
@ToLocation INT = -999,
@DeliveryDate DATE = GETDATE
)
AS
BEGIN
	SET NOCOUNT ON;

	
DECLARE @propertyID INT 
DECLARE @IsDeliverydateforRequest BIT

SELECT @propertyID = CompanyID FROM Locations 
WHERE Id= @LocationID

SELECT @IsDeliverydateforRequest =IsDeliverydateforRequest FROM Companies
WHERE CompanyID =@propertyID

DECLARE @IsGetProductionFalseOnly BIT = 0
IF EXISTS( SELECT  *FROM Location_Ref WHERE StockLocationID = @LocationID )
BEGIN

 SET @IsGetProductionFalseOnly = 1

END



 
 if	(@Operation='T') -- show only Pick note prepaird requests
 begin
/*I(NV_RequestHeader.RequestDate = @RequestDate) AND (INV_RequestHeader.DocumentStatus = 'P')*/

IF(@IsDeliverydateforRequest = 1)
BEGIN

    SELECT *
	FROM
	(

		SELECT DISTINCT RequestHeaders.Id,
		--RequestHeaders.DocumentNo,
		RequestHeaders.RequestDate,
		--dbo.RequestHeaders.DocumentNo +' '+' | '+ CONVERT(VARCHAR,DeliveryDate,31)  + CASE WHEN RequestHeaders.Remarks <>'' THEN ' | ' + RequestHeaders.Remarks ELSE '' END  as DocumentNo
		CONCAT(dbo.RequestHeaders.DocumentNo,' | ',CONVERT(VARCHAR,RequestHeaders.DeliveryDate,31),' | ',RequestHeaders.Remarks,' | ', ISNULL(SPO.InvoiceNo,''))  AS DocumentNo
		,0 IsProduction,
		RequestHeaders.Remarks AS Remarks
		FROM         RequestHeaders 
		INNER JOIN RequestDetails ON RequestHeaders.Id= RequestDetails.RequestHeaderID
		LEFT JOIN SPO_OrderHeader SPO ON SPO.OrderId = RequestHeaders.SPOId AND RequestHeaders.IsSPOBased =1
		WHERE      (RequestHeaders.LocationID = @LocationID) 
		AND		  (RequestHeaders.TransferLocation = CASE WHEN @ToLocation = -999 THEN RequestHeaders.TransferLocation ELSE @ToLocation END)
		AND		  (RequestHeaders.RequestType = @RequestType) 
		AND		   (RequestHeaders.IsApproved = 1)  
		AND (RequestHeaders.DocumentStatus = 'P' )
		AND (RequestDetails.ApprovedQuantity - RequestDetails.IssuedQuantity ) >= 0
		AND RequestHeaders.DeliveryDate = @DeliveryDate
	

		UNION ALL

		SELECT DISTINCT PH.Id,PH.RequestedDate RequestDate,
		--PH.DocumentNo +' '+' | '+ CONVERT(VARCHAR,PH.RequestedDate,31)+' | Production' + ' | '+ PH.Remarks as DocumentNo
		CONCAT(PH.DocumentNo,' | ',CONVERT(VARCHAR,PH.RequestedDate,31),' | Production | ',PH.Remarks) AS DocumentNo
		,1 IsProduction,
		PH.Remarks AS Remarks
		FROM ProductionConsolidateHeader PH
		INNER JOIN ProductionConsolidateRecipeSummary PS ON PH.ID = PS.ProductionConsolidateHeaderID
		WHERE PH.Status='P'
		AND (PS.Quantity - ISNULL(PS.RecievedQuantity,0) ) >= 0
		AND PH.LocationID = @ToLocation
		AND PH.RequestedDate = @DeliveryDate

	) A
	WHERE A.IsProduction = CASE WHEN @IsGetProductionFalseOnly = 1 THEN 0 ELSE A.IsProduction END 
    ORDER BY A.RequestDate DESC ,A.Id DESC


END
ELSE
BEGIN
	SELECT *
	FROM
	(
	SELECT DISTINCT RequestHeaders.Id,
	--RequestHeaders.DocumentNo,
	RequestHeaders.RequestDate,
	dbo.RequestHeaders.DocumentNo +' '+' | '+ CONVERT(VARCHAR,DeliveryDate,31)  + CASE WHEN RequestHeaders.Remarks <>'' THEN ' | ' + RequestHeaders.Remarks ELSE '' END  as DocumentNo
	,0 IsProduction
	FROM         RequestHeaders INNER JOIN RequestDetails ON RequestHeaders.Id= RequestDetails.RequestHeaderID
	WHERE      (RequestHeaders.LocationID = @LocationID) 
	AND		  (RequestHeaders.TransferLocation = CASE WHEN @ToLocation = -999 THEN RequestHeaders.TransferLocation ELSE @ToLocation END)
	AND		  (RequestHeaders.RequestType = @RequestType) 
	AND		   (RequestHeaders.IsApproved = 1)  
	AND (RequestHeaders.DocumentStatus = 'P' )
	AND (RequestDetails.ApprovedQuantity - RequestDetails.IssuedQuantity ) >= 0
	UNION ALL
	SELECT DISTINCT PH.Id,PH.RequestedDate RequestDate,
	PH.DocumentNo +' '+' | '+ CONVERT(VARCHAR,PH.RequestedDate,31)+' | Production' as DocumentNo
	,1 IsProduction
	FROM ProductionConsolidateHeader PH
	INNER JOIN ProductionConsolidateRecipeSummary PS ON PH.ID = PS.ProductionConsolidateHeaderID
	WHERE PH.Status='P'
	AND (PS.Quantity - ISNULL(PS.RecievedQuantity,0) ) >= 0
	AND PH.LocationID = @ToLocation
	AND IsTransferComplete=0
	)

	AS A
	WHERE A.IsProduction = CASE WHEN @IsGetProductionFalseOnly = 1 THEN 0 ELSE A.IsProduction END 
	ORDER BY A.RequestDate DESC ,A.Id DESC

END

end
END

GO

