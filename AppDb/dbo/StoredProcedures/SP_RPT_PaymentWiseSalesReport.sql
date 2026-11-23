-- =============================================
-- Author:		Isuru PramodyaCompanyID
-- Create date: 2023 Dec 11
-- Description:	Pay mode wise sales summary Report

-- [dbo].[SP_RPT_PaymentWiseSalesReport] '12','2024/03/09','2024/03/09',1
 
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_PaymentWiseSalesReport]
@LocationID VARCHAR(MAX),
@FromDate DATE,
@ToDate DATE,
@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;


			DECLARE @ReturnNotes decimal(18,2)

			
			SELECT @ReturnNotes =SUM(INP.ActualAmount) 
			FROM POS_InvoicePayment INP
			INNER JOIN PaymentTypes PT ON INP.PayCode = PT.PayCode  AND PT.PropertyId = INP.CompanyID
			INNER JOIN Locations LO ON INP.LocationID = LO.Id
			WHERE INP.LocationID IN (SELECT * FROM string_split(@LocationID,N','))  AND INP.BusinessDate BETWEEN @FromDate AND @ToDate AND INP.CompanyID =@PropertyID
			AND  INP.PayCode  IN (SELECT PayCode FROM PaymentTypes WHERE IsReturnCoupon=1)-- commented by Isuru 2024-04-08 for report not tally 
			


			SELECT PT.PayCode,PT.Description,SUM(INP.ActualAmount) ActualAmount,LO.Name LocationName, @ReturnNotes ReturnNotes
			FROM POS_InvoicePayment INP
			INNER JOIN PaymentTypes PT ON INP.PayCode = PT.PayCode AND PT.PropertyId = INP.CompanyID
			INNER JOIN Locations LO ON INP.LocationID = LO.Id
			WHERE INP.LocationID IN (SELECT * FROM string_split(@LocationID,N','))  AND INP.BusinessDate BETWEEN @FromDate AND @ToDate AND INP.CompanyID =@PropertyID
			--AND  INP.PayCode NOT IN (SELECT PayCode FROM PaymentTypes WHERE IsReturnCoupon=1)-- commented by Isuru 2024-04-08 for report not tally 
			GROUP BY  PT.PayCode,PT.Description,LO.Name
			ORDER BY LocationName ASC


  
END

GO

