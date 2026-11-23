-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC Report_VoidBillDetail 'A00049','S01','2021-11-10 00:00:00.000',2
CREATE PROCEDURE [dbo].[Report_VoidBillPaymentDetail]
	@OrderNo VARCHAR(10),
	@Outlet	 VARCHAR(10),
	@OrderDate VARCHAR(20),
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;


	SELECT P.Description,PT.Tendered
	FROM VoidBillHeader BH 
	INNER JOIN VoidPayTrans PT 
	ON BH.OrderNo = PT.OrderNo AND BH.Outlet = PT.Outlet AND BH.OrderDate = PT.OrderDate AND BH.PropertyId = PT.PropertyId
	INNER JOIN PaymentTypes P ON PT.PayCode = P.PayCode
	WHERE BH.OrderNo = @OrderNo AND BH.Outlet = @Outlet AND CONVERT(DATETIME, BH.OrderDate) = CONVERT(DATETIME,@OrderDate) AND BH.PropertyId = @PropertyId
	AND P.PropertyId = @PropertyId


    
END

GO

