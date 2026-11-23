-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2023 Dec 11
-- Description:	Invoice Sales Report

-- [dbo].[SP_RPT_GetInvoiceSalesReport] '12','2025/10/25','2025/10/25',1
 
-- =============================================
CREATE PROCEDURE[dbo].[SP_RPT_GetInvoiceSalesReport]
@LocationID VARCHAR(MAX),
@FromDate DATE,
@ToDate DATE,
@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TotalTrans INT

	 SELECT @TotalTrans= sum(ordercount)
	 from (SELECT count(distinct ih.InvoiceNo) ordercount
	FROM POS_InvoiceHeader IH
	INNER JOIN POS_InvoiceDetail ID ON IH.InvHeaderID = ID.InvHeaderID
	INNER JOIN StockItemHeaders SH ON SH.Id = ID.ItemID
	INNER JOIN Locations LO ON LO.Id = IH.LocationID
	WHERE IH.LocationID IN (SELECT * FROM string_split(@LocationID,N','))  AND IH.BusinessDate BETWEEN @FromDate AND @ToDate AND IH.CompanyID =@PropertyID
	GROUP BY IH.InvoiceNo--,IH.BusinessDate,IH.InsertDateTime,SH.StockItemCode,SH.Name,ID.Quantity,ID.SellingPrice,LO.Name,IH.Discount,ID.DiscountValue,ID.DiscountPercentage,IH.Discount,ID.DiscountValue
	) as order_counts

    SELECT IH.InvoiceNo,IH.BusinessDate,IH.InsertDateTime,CONVERT(VARCHAR(8),IH.InsertDateTime,108) OrderTime,SH.StockItemCode,SH.Name, SUM(ID.Quantity)Quantity,ID.SellingPrice
	  ,( SUM(ID.Quantity)*ID.SellingPrice)- CASE WHEN ID.DiscountValue=0 THEN  SUM(ID.Quantity) * Id.SellingPrice * Id.DiscountPercentage /100 ELSE  ID.DiscountValue END Value
	,LO.Name LocationName
	,SUM(ID.Quantity * ID.AveragePrice) CostValue,(SUM(ID.Quantity * ID.AveragePrice))/SUM(ID.Quantity) AVGCostPrice
	--,IH.Discount,
	,CASE WHEN ID.DiscountValue=0 THEN  SUM(ID.Quantity) * Id.SellingPrice * Id.DiscountPercentage /100 ELSE  ID.DiscountValue END Discount,
	
	@TotalTrans TotalTransactions
	FROM POS_InvoiceHeader IH
	INNER JOIN POS_InvoiceDetail ID ON IH.InvHeaderID = ID.InvHeaderID
	INNER JOIN StockItemHeaders SH ON SH.Id = ID.ItemID
	INNER JOIN Locations LO ON LO.Id = IH.LocationID
	WHERE IH.LocationID IN (SELECT * FROM string_split(@LocationID,N','))  AND IH.BusinessDate BETWEEN @FromDate AND @ToDate AND IH.CompanyID =@PropertyID
	GROUP BY IH.InvoiceNo,IH.BusinessDate,IH.InsertDateTime,SH.StockItemCode,SH.Name,ID.SellingPrice,LO.Name,IH.Discount,ID.DiscountValue,ID.DiscountPercentage,IH.Discount,ID.DiscountValue


END

GO

