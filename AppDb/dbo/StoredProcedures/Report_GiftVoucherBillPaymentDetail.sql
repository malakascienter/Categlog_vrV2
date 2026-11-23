-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC Report_BillDetail 'B00285','OLV','2021-11-10 00:00:00.000',2
CREATE PROCEDURE [dbo].[Report_GiftVoucherBillPaymentDetail]
	@OrderNo VARCHAR(10),
	@Outlet	 VARCHAR(10),
	@OrderDate VARCHAR(20),
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;


	SELECT P.Description,PT.Tendered
	FROM POS_GiftVoucherHeader BH 
	INNER JOIN POS_GiftVoucherPayTrans PT 
	ON BH.DocNo = PT.DocNo AND BH.Outlet = PT.Outlet AND BH.DocDate = PT.DocDate AND BH.PropertyId = PT.PropertyId
	INNER JOIN PaymentTypes P ON PT.PayCode = P.PayCode
	WHERE BH.DocNo = @OrderNo AND BH.Outlet = @Outlet AND CONVERT(DATE, BH.DocDate) = CONVERT(DATE,@OrderDate) AND BH.PropertyId = @PropertyId
	AND P.PropertyId = @PropertyId


    
END

GO

