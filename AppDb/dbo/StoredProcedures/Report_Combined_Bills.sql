-- =============================================
-- Author:		Chiraj
-- Create date: 2020-8-11
-- Description:	Get Combined Bills
-- =============================================
--Report_Combined_Bills '30/06/2020','30/06/2020','J01','2'
CREATE PROCEDURE [dbo].[Report_Combined_Bills] 
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT 
	   SP.OrderNo
      ,SP.OrderDateTime
	  ,SP.NewOrderNo
      ,SP.WaiterID     
      ,SP.OutletID  
      ,SP.Quantity
      ,SP.Rate                     
      ,SP.ChargeAmount       
      ,SP.IsBillDiscount
      ,SP.DiscountID      
      ,SP.BillDisVal
      ,SP.DiscountRemark          
      ,SP.ServiceCharge
      ,SP.TaxAmount1
      ,SP.TaxAmount2
      ,SP.TaxAmount3
      ,SP.TaxAmount4   
	  ,isnull((select top 1 Name from waiter where Code = sp.WaiterID),'NA') AS Waiter
	  ,isnull((select top 1 code from Location_Ref where code = SP.OutletID),'NA') AS Outlet
	  --[10.17.1.10]
  FROM StandardinventoryRestaurant.[dbo].[POS_BillCombineSplitLog] AS SP
   WHERE CONVERT(date, SP.OrderDateTime) >= CONVERT(DATE,@FromDate,103) 
		AND CONVERT(date, SP.OrderDateTime) <= CONVERT(DATE,@ToDate,103) 
		AND SP.OutletID IN (SELECT * FROM STRING_SPLIT(@Outlet,',')) AND SP.IsCombined=1 --AND B.PropertyId=@PropertyId     
   
END

GO

