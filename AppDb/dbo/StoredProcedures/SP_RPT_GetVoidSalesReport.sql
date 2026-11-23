-- =============================================
-- Author	  :	Isuru Pramodya
-- Create date: 2024-03-12
-- Description:	Void Sales Report

-- [dbo].[SP_RPT_GetVoidSalesReport] '12','2023/11/01','2024/12/30',1
 
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_GetVoidSalesReport]
@LocationID VARCHAR(MAX),
@FromDate DATE,
@ToDate DATE,
@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;

    SELECT IH.InvoiceNo,IH.BusinessDate,IH.InsertDateTime,CONVERT(VARCHAR(8),IH.InsertDateTime,108) OrderTime,SH.StockItemCode,SH.Name,ID.Quantity,ID.SellingPrice,(ID.Quantity*ID.SellingPrice) Value,LO.Name LocationName,
	VoidReason
	FROM POS_VoidInvoiceHeader IH
	INNER JOIN POS_VoidInvoiceDetail ID ON IH.InvHeaderID = ID.InvHeaderID
	INNER JOIN StockItemHeaders SH ON SH.Id = ID.ItemID
	INNER JOIN Locations LO ON LO.Id = IH.LocationID
	WHERE IH.LocationID IN (SELECT * FROM string_split(@LocationID,N','))  AND IH.BusinessDate BETWEEN @FromDate AND @ToDate AND IH.CompanyID =@PropertyID


END

GO

