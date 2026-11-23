
CREATE PROCEDURE [dbo].[Report_CurrencyWiseSales](          
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
)        
AS        
BEGIN         


	 SELECT L.description AS Outlet,OK.OrderDate,OK.CurrCode,SUM(OK.ActualAmount * ok.ConversionRate) AS CurrAmount ,SUM(OK.ActualAmount) AS ActualAmount,SUM(OK.ActualAmount * OK.LocalCurrRate) AS LKRAmt
	 FROM PayTransCurrency OK	
	 INNER JOIN Location_Ref L ON OK.Outlet = L.code AND OK.PropertyID = L.PropertyId	 
	 WHERE  OK.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
			AND OK.OrderDate <= CONVERT(DATETIME,@ToDate,103) 
			AND OK.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  AND OK.PropertyId=@PropertyId
			AND OK.PayType = 'P' and OK.ActualAmount > 0
	 GROUP BY L.description,OK.OrderDate,OK.CurrCode
	

END;

GO

