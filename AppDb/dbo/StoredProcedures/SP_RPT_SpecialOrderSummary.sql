-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-05-28
-- Description:	get special order details for report 

--	SP_RPT_SpecialOrderSummary -999, '2026-06-10','2026-06-11'

-- =============================================
CREATE   PROCEDURE [dbo].[SP_RPT_SpecialOrderSummary]
	@LocationID INT,
	@FromDate DATETIME,
	@ToDate DATETIME

AS
BEGIN
	SET NOCOUNT ON;

    SELECT  SOH.CreatedDate, L.Name AS OrderLocation, RH.DocumentNo AS TranserReqNo, C.CustomerName, SOH.InvoiceNo AS SPOInvoiceNo, SOH.DeliveryDate, CONVERT(VARCHAR(5), SOH.DeliveryTime, 108) AS DeliveryTime, ODM.OrderDeliveryModeName AS DeliveryMode, SOD.ItemName, SOD.Qty, SOD.ItemRemark
	FROM SPO_OrderHeader SOH
	INNER JOIN SPO_OrderDetails SOD ON SOH.OrderId = SOD.OrderId
	INNER JOIN RequestHeaders RH ON RH.SPOId = SOH.OrderId
	INNER JOIN SPO_OrderDeliveryMode ODM ON ODM.Id = SOH.DeliveryMode
	INNER JOIN Locations L ON L.Id = RH.TransferLocation
	INNER JOIN SPO_Customer C ON C.ID = SOH.CustomerId
	WHERE (@LocationID = -999 OR RH.LocationID = @LocationID)
	AND SOH.DeliveryDate BETWEEN CONVERT(VARCHAR, @FromDate, 23) AND  CONVERT(VARCHAR, @ToDate, 23)
	--AND SOH.DeliveryDate >= CONVERT(VARCHAR, GETDATE(), 23)
	AND RH.IsSPOBased = 1
	
END

GO

