-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2023 Dec 11
-- Description:	Invoice Sales Report

-- [dbo].[SP_RPT_GetInvoiceSalesReport] '12','2024/04/18','2024/04/18',1
 
-- =============================================
CREATE PROCEDURE[dbo].[SP_RPT_GetDiscountReport]
@LocationID VARCHAR(MAX),
@FromDate DATE,
@ToDate DATE,
@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;

    SELECT IH.InvoiceNo,IH.BusinessDate,IH.InsertDateTime,CONVERT(VARCHAR(8),IH.InsertDateTime,108) OrderTime,SH.StockItemCode,SH.Name,ID.Quantity,ID.SellingPrice
	  ,(ID.Quantity*ID.SellingPrice)- CASE WHEN ID.DiscountValue=0 THEN Id.Quantity * Id.SellingPrice * Id.DiscountPercentage /100 ELSE  ID.DiscountValue END Value
	,LO.Name LocationName
	,SUM(ID.Quantity * ID.AveragePrice) CostValue,(SUM(ID.Quantity * ID.AveragePrice))/SUM(ID.Quantity) AVGCostPrice
	,CASE WHEN ID.DiscountValue=0 THEN Id.Quantity * Id.SellingPrice * Id.DiscountPercentage /100 ELSE  ID.DiscountValue END Discount,
	IH.Discount AS BillDiscount,
	DH.Description AS DiscountType
	FROM POS_InvoiceHeader IH
	INNER JOIN POS_InvoiceDetail ID ON IH.InvHeaderID = ID.InvHeaderID
	INNER JOIN StockItemHeaders SH ON SH.Id = ID.ItemID
	INNER JOIN Locations LO ON LO.Id = IH.LocationID
	LEFT JOIN DiscountHeader DH ON DH.Code = ID.DiscountCode  AND DH.PropertyId = ID.CompanyID
	WHERE IH.LocationID IN (SELECT * FROM string_split(@LocationID,N','))  AND IH.BusinessDate BETWEEN @FromDate AND @ToDate AND IH.CompanyID =@PropertyID and IH.Discount > 0
	GROUP BY IH.InvoiceNo,IH.BusinessDate,IH.InsertDateTime,SH.StockItemCode,SH.Name,ID.Quantity,ID.SellingPrice,LO.Name,IH.Discount,ID.DiscountValue,ID.DiscountPercentage,IH.Discount,ID.DiscountValue,DH.Description 


END

GO

