-- =============================================
-- Author:		Nivesh
-- Create date: 2025-01-21
-- Description:	Get Commissary Invoice Report
-- =============================================
--Rpt_CommissaryInvoiceReport '1','2023-01-01', '2025-01-31'

CREATE PROCEDURE Rpt_CommissaryInvoiceReport
	@LocationID VARCHAR(MAX),@FromDate DATE,@ToDate DATE ,@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SH.StockItemCode ,SH.Name ,PID.Quantity ,PID.Quantity*PID.SellingPrice TotalRevenue,ISNULL(TRY_CONVERT(DECIMAL(10, 2), SIWA.Remarks) ,0) Commission,PID.Quantity*PID.SellingPrice*ISNULL(TRY_CONVERT(DECIMAL(10, 2), SIWA.Remarks) ,0)/100 CommissionToZam
	FROM StockItemHeaders SH
	INNER JOIN POS_InvoiceDetail PID ON PID.ItemID = SH.Id
	INNER JOIN POS_InvoiceHeader PIH ON PIH.InvHeaderID = PID.InvHeaderID
	LEFT JOIN StockItemWiseAttributes SIWA ON SIWA.StockItemHeaderID = SH.Id AND  SIWA.StockItemAttributeID =20
	WHERE PID.LocationID IN (SELECT * FROM string_split(@LocationID,N','))  AND 
	PID.BusinessDate BETWEEN @FromDate AND @ToDate AND SH.CompanyId=@PropertyID;

END

GO

