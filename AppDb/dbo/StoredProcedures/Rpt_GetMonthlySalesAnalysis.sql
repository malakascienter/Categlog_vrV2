-- =============================================
-- Author:		Nivesh
-- Create date: 2025-01-17
-- Description:	Monthly Sales Analysis
-- =============================================
--Rpt_GetMonthlySalesAnalysis 12,'2024-11-01','2025-01-31'
CREATE PROCEDURE [dbo].[Rpt_GetMonthlySalesAnalysis] 
	@LocID INT, 
	@FromDate DATE,
	@ToDate DATE

AS
BEGIN

	SET NOCOUNT ON;

	SELECT  SH.StockItemCode,SH.ERPReferenceCode,SH.Name ItemName,UN.Name Unitname ,pd.Quantity,
		ISNULL(pd.SellingPrice,0)*ISNULL(pd.Quantity,0) Value
		,LO.Name LocationName,
		CONCAT(CONVERT(VARCHAR,DATENAME(MONTH,PH.BusinessDate)),' - ',CONVERT(VARCHAR,DATENAME(YEAR,PH.BusinessDate))	) PERIOD
	FROM POS_InvoiceHeader PH
	INNER JOIN POS_InvoiceDetail PD ON PH.InvHeaderID = PD.InvHeaderID
	INNER JOIN StockItemHeaders SH ON SH.ID = PD.ItemID
	INNER JOIN Locations LO ON LO.Id = PH.LocationID
	INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = SH.Id AND SD.LocationID = PH.LocationID
	INNER JOIN Units UN ON UN.ID = SD.MasterUnitID 
	WHERE PH.LocationID  =@LocID AND CONVERT(DATE, PH.BusinessDate)   BETWEEN @FromDate AND @ToDate
	ORDER BY PH.BusinessDate;

END

GO

