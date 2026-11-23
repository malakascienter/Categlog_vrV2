-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-04-25
-- Description:	Sales Details by Payment Mode

-- [dbo].[SP_RPT_PaymentMethodWiseSalesReport] 12,'2024/04/25','2024/04/25',1

-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_PaymentMethodWiseSalesReport]
@LocationID VARCHAR(MAX),
@FromDate DATE,
@ToDate DATE,
@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;


			SELECT distinct IVH.InvHeaderID,IVH.InvoiceNo,Lo.Name LocationName,IVH.BusinessDate,INP.ActualAmount NetAmount,PT.Description PayCode,INP.PaymentRemark,CU.UserName
			FROM POS_InvoiceHeader IVH
			INNER JOIN POS_InvoicePayment INP ON INP.InvHeaderID=IVH.InvHeaderID--AND INP.BusinessDate BETWEEN '2024/04/25' and '2024/04/25'
			INNER JOIN PaymentTypes PT ON INP.PayCode = PT.PayCode
			INNER JOIN Locations LO ON INP.LocationID = LO.Id
			INNER JOIN centralUsers CU ON CU.id = INP.UserID
			WHERE IVH.LocationID IN (SELECT * FROM string_split(@LocationID,N','))  AND IVH.BusinessDate BETWEEN @FromDate AND @ToDate AND IVH.CompanyID =@PropertyID
			--and IVH.InvHeaderID=14214







  
END

GO

