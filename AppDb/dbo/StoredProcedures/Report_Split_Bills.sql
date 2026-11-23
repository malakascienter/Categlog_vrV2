-- =============================================
-- Author:		Chiraj
-- Create date: 2020-8-11
-- Description:	Get Split Bills
-- =============================================
--Report_Split_Bills '30/06/2020','30/06/2020','J01','2'
CREATE PROCEDURE [dbo].[Report_Split_Bills] 
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT 
      [OrderNo]
      ,[OrderDateTime]
	  ,[NewOrderNo]
      ,[WaiterID]     
      ,[OutletID]  
      ,[Quantity]
      ,[Rate]                     
      ,[ChargeAmount]       
      ,[IsBillDiscount]
      ,[DiscountID]      
      ,[BillDisVal]
      ,[DiscountRemark]          
      ,[ServiceCharge]
      ,[TaxAmount1]
      ,[TaxAmount2]
      ,[TaxAmount3]
      ,[TaxAmount4]  
	  ,isnull((select top 1 Code from waiter where id = sp.WaiterID),'NA') AS Waiter
	  ,isnull((select top 1 code from Location_Ref where code = SP.OutletID),'NA') AS Outlet
	  --[10.17.1.10].
  FROM [StandardinventoryRestaurant].[dbo].[POS_BillCombineSplitLog] AS SP
   WHERE CONVERT(date, SP.OrderDateTime) >= CONVERT(DATE,@FromDate,103) 
		AND CONVERT(date, SP.OrderDateTime) <= CONVERT(DATE,@ToDate,103) 
		AND SP.OutletID  IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  --AND IsCombined=0--AND B.PropertyId=@PropertyId     
   
END

GO

