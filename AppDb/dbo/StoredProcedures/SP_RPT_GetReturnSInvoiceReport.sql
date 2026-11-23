-- =============================================
-- Author	  :	Isuru Pramodya
-- Create date: 2024-03-12
-- Description:	Void Sales Report

-- [dbo].[SP_RPT_GetReturnSInvoiceReport] '8,30,2,13,16,21,12,5,1,29,4,18,23,28,27,10,11,9,7,31,24,6,15,20,26,17,22,3,14,19','2023/11/01','2024/12/30',1
 
-- =============================================
create PROCEDURE [dbo].[SP_RPT_GetReturnSInvoiceReport]
@LocationID VARCHAR(MAX),
@FromDate DATE,
@ToDate DATE,
@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;

    SELECT IH.InvoiceNo,IH.BusinessDate,IH.InsertDateTime,CONVERT(VARCHAR(8),IH.InsertDateTime,108) OrderTime,SH.StockItemCode,SH.Name,ID.Quantity,ID.ReturnPrice SellingPrice,(ID.Quantity*ID.ReturnPrice) Value,LO.Name LocationName
	FROM POS_SalesReturnHeader IH
	INNER JOIN POS_SalesReturnDetail ID ON IH.ReturnHeaderID = ID.ReturnHeaderID
	INNER JOIN StockItemHeaders SH ON SH.Id = ID.ItemID
	INNER JOIN Locations LO ON LO.Id = IH.LocationID
	WHERE IH.LocationID IN (SELECT * FROM string_split(@LocationID,N','))  AND IH.BusinessDate BETWEEN @FromDate AND @ToDate AND IH.CompanyID =@PropertyID


END

GO

