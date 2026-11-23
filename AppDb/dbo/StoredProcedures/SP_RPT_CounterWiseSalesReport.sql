-- =============================================
-- Author:		Isuru PramodyaCompanyID
-- Create date: 2023 Dec 11
-- Description:	Pay mode wise sales summary Report

-- [dbo].[SP_RPT_CounterWiseSalesReport] '12','2024/01/01','2024/09/2',1
 
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_CounterWiseSalesReport]
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

			

			SELECT PT.PayCode,PT.Description,SUM(INP.ActualAmount) ActualAmount,LO.Name LocationName, 0 ReturnNotes,WRK.Counter
			FROM POS_InvoicePayment INP
			INNER JOIN PaymentTypes PT ON INP.PayCode = PT.PayCode
			INNER JOIN Locations LO ON INP.LocationID = LO.Id
			INNER JOIN POS_WorkStation WRK ON WRK.ID = INP.StationID
			LEFT JOIN #TEMP TP ON TP.ID = WRK.ID
			WHERE INP.LocationID IN (SELECT * FROM string_split(@LocationID,N','))  AND INP.BusinessDate BETWEEN @FromDate AND @ToDate AND INP.CompanyID =@PropertyID
			--AND  INP.PayCode NOT IN (SELECT PayCode FROM PaymentTypes WHERE IsReturnCoupon=1)-- commented by Isuru 2024-04-08 for report not tally 
			GROUP BY  PT.PayCode,PT.Description,LO.Name,WRK.Counter,TP.ActualAmount
			ORDER BY LocationName ASC



  
END

GO

