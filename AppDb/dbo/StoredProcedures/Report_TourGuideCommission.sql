
CREATE PROCEDURE [dbo].[Report_TourGuideCommission](          
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2),
 @TourGuide VARCHAR(MAX)
)        
AS        
BEGIN         

    SELECT BH.OrderNo,L.description AS Outlet,(BH.Subtotal+BH.ServiceCharge+BH.TaxVal1+BH.TaxVal2+BH.TaxVal3+BH.TaxVal4 ) AS BillAmount,BH.OrderDate,
	CASE WHEN TD.TourGuideTxnHeaderId IS NULL  THEN 'Pending' else 'Paid' END AS Status
	FROM 
	BillHeader BH 
	INNER JOIN TourGuideMaster TG ON TG.Id = BH.TourGuideId	
	INNER JOIN Location_Ref L ON BH.Outlet = L.code AND BH.PropertyId = L.PropertyId
	LEFT JOIN TourGuideTxnDetails TD ON TD.OrderNo = BH.OrderNo AND TD.OrderDate = BH.OrderDate AND TD.Outlet = BH.Outlet AND TD.PropertyId = BH.PropertyId
	WHERE BH.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
	      AND BH.OrderDate <= CONVERT(DATETIME,@ToDate,103) 
	      AND BH.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  
		  AND BH.PropertyId=@PropertyId AND TG.Id in (@TourGuide)

END;

GO

