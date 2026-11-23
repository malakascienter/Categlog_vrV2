-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC Report_BillPaymentDetail 'S04891','ESB','2025-04-29',1
CREATE PROCEDURE [dbo].[Report_BillPaymentDetail]
	@OrderNo VARCHAR(10),
	@Outlet	 VARCHAR(10),
	@OrderDate VARCHAR(20),
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;


	SELECT P.Description,PT.Tendered
	FROM BillHeader BH 
	INNER JOIN PayTrans PT 
	ON BH.OrderNo = PT.OrderNo AND BH.Outlet = PT.Outlet AND BH.OrderDate = PT.OrderDate AND BH.PropertyId = PT.PropertyId
	INNER JOIN PaymentTypes P ON PT.PayCode = P.PayCode
	WHERE BH.OrderNo = @OrderNo AND BH.Outlet = @Outlet AND CONVERT(DATE, BH.OrderDate) = CONVERT(DATE,@OrderDate) AND BH.PropertyId = @PropertyId
	AND P.PropertyId = @PropertyId


    
END

GO

