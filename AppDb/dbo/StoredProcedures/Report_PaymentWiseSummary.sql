
-- =============================================
-- Author:		BANU
-- ALTER date:  
-- Description:	REPORT PAYMENT WISE SALES SUMMARY 
-- =============================================
-----EXEC  Report_PaymentWiseSummary '001','01/09/2018','01/11/2018'
CREATE PROCEDURE [dbo].[Report_PaymentWiseSummary](  
	@Outlet VARCHAR(MAX),  
	@FromDate VARCHAR(10),  
	@ToDate VARCHAR(10) ,
	 @PropertyId VARCHAR(2)
)  
AS   
BEGIN  
	SELECT     
		PaymentTypes.Description AS PaymentType,   
		SUM(PayTrans.ActualAmt) AS Value   
	FROM PayTrans --ON BillHeader.OrderNo = PayTrans.OrderNo AND BillHeader.OrderDate = PayTrans.OrderDate AND BillHeader.Outlet = PayTrans.Outlet    
	INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode   and PaymentTypes.PropertyId=PayTrans.PropertyId
	INNER JOIN Location_Ref ON PayTrans.Outlet = Location_Ref.code    and Location_Ref.propertyid=PayTrans.PropertyId
	WHERE (PayTrans.OrderDate >= CONVERT(DATETIME,@FromDate,103))   
			AND (PayTrans.OrderDate <= CONVERT(DATETIME,@ToDate,103))   
			AND PayTrans.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  AND  PayTrans.PropertyId=@PropertyId   
	GROUP BY PaymentTypes.Description;  
END;

GO

