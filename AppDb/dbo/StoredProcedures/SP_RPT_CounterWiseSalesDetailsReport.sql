-- =============================================
-- Author:		Isuru PramodyaCompanyID
-- Create date: 2023 Dec 11
-- Description:	Pay mode wise sales summary Report

-- [dbo].[SP_RPT_CounterWiseSalesDetailsReport] '10,11,12,13,14,15','2024-01-01','2024-12-02',1
 
-- =============================================
create PROCEDURE [dbo].[SP_RPT_CounterWiseSalesDetailsReport]
@LocationID VARCHAR(MAX),
@FromDate DATE,
@ToDate DATE,
@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReturnNotes decimal(18,2)

	SELECT SUM(INP.ActualAmount) ActualAmount,WRK.ID
	INTO #TEMP
	FROM POS_InvoicePayment INP
	INNER JOIN PaymentTypes PT ON INP.PayCode = PT.PayCode
	INNER JOIN Locations LO ON INP.LocationID = LO.Id
	INNER JOIN POS_WorkStation WRK ON WRK.ID = INP.StationID
	WHERE INP.LocationID IN (SELECT * FROM string_split(@LocationID,N','))  AND INP.BusinessDate BETWEEN @FromDate AND @ToDate AND INP.CompanyID =@PropertyID
	AND  INP.PayCode  IN (SELECT PayCode FROM PaymentTypes WHERE IsReturnCoupon=1)-- ADDED by Isuru 2024-04-08 for report not tally 
	GROUP BY WRK.ID

	SELECT WRK.Counter,LO.Name LocationName,INP.BusinessDate,PT.PayCode,PT.Description,INP.InvoiceNo,SUM(INP.ActualAmount) ActualAmount, 0 ReturnNotes
	FROM POS_InvoicePayment INP
	INNER JOIN PaymentTypes PT ON INP.PayCode = PT.PayCode
	INNER JOIN Locations LO ON INP.LocationID = LO.Id
	INNER JOIN POS_WorkStation WRK ON WRK.ID = INP.StationID
	LEFT JOIN #TEMP TP ON TP.ID = WRK.ID
	WHERE INP.LocationID IN (SELECT * FROM string_split(@LocationID,N','))  AND INP.BusinessDate BETWEEN @FromDate AND @ToDate AND INP.CompanyID =@PropertyID
	--AND  INP.PayCode NOT IN (SELECT PayCode FROM PaymentTypes WHERE IsReturnCoupon=1)-- commented by Isuru 2024-04-08 for report not tally 
	GROUP BY  PT.PayCode,PT.Description,LO.Name,WRK.Counter,INP.InvoiceNo,INP.BusinessDate
	ORDER BY WRK.Counter,LocationName ASC,INP.BusinessDate,PT.PayCode,INP.InvoiceNo

END

GO

