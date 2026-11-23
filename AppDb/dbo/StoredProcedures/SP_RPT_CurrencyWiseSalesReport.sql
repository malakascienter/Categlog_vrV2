-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2023-12-13
-- Description:	Fast/Slow Moving Items

--  [dbo].[SP_RPT_CurrencyWiseSalesReport] '12','2024/03/01','2024/03/25',1,1

-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_CurrencyWiseSalesReport]
@LocationID VARCHAR(MAX),
@FromDate DATE,
@ToDate DATE,
@PropertyID INT,
@IsSummaryReport INT

AS
BEGIN

		IF(@IsSummaryReport =0)
		BEGIN
		SELECT IH.InvoiceNo,IVN.BusinessDate,LO.Name LocationName,IVN.CurrencyCode,CU.Name,IVN.ConversionRate,IVN.CurrencyAmount,CAST((IVN.ActualAmount/IVN.ConversionRate) AS DECIMAL(18, 2)) ACTUAL
		FROM POS_InvoicePaymentDetail IVN
		INNER JOIN POS_InvoiceHeader IH ON IVN.InvHeaderID = IH.InvHeaderID AND IH.BusinessDate = IVN.BusinessDate AND IH.LocationID = IVN.LocationID
		INNER JOIN Locations LO ON LO.Id = IVN.LocationID
		INNER JOIN CurrencyMasters CU ON CU.Symbol = IVN.CurrencyCode
		WHERE IVN.LocationID IN (SELECT * FROM string_split(@LocationID,N','))  AND IVN.BusinessDate BETWEEN @FromDate AND @ToDate AND IVN.CompanyID =@PropertyID
		AND IVN.PayType='P'
		END

		IF(@IsSummaryReport=1)
		BEGIN
		SELECT LO.Name LocationName,IVN.CurrencyCode,CU.Name,CONVERT(DECIMAL(18,2), SUM(IVN.CurrencyAmount)) CurrencyAmount,CONVERT(DECIMAL(18,2), SUM((IVN.ActualAmount/IVN.ConversionRate))) ACTUAL
		FROM POS_InvoicePaymentDetail IVN
		INNER JOIN POS_InvoiceHeader IH ON IVN.InvHeaderID = IH.InvHeaderID AND IH.BusinessDate = IVN.BusinessDate AND IH.LocationID = IVN.LocationID
		INNER JOIN Locations LO ON LO.Id = IVN.LocationID
		INNER JOIN CurrencyMasters CU ON CU.Symbol = IVN.CurrencyCode
		WHERE IVN.LocationID IN (SELECT * FROM string_split(@LocationID,N','))  AND IVN.BusinessDate BETWEEN @FromDate AND @ToDate AND IVN.CompanyID =@PropertyID
		AND IVN.PayType='P'
		GROUP BY LO.Name ,IVN.CurrencyCode,CU.Name

		END
		






END

GO

