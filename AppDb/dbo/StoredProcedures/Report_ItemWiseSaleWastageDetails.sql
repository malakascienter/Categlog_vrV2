
CREATE PROCEDURE [dbo].[Report_ItemWiseSaleWastageDetails](          
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2),
 @WastageType VARCHAR(MAX)
)        
AS        
BEGIN         

	SELECT A.Category,A.ItemName,SUM(A.SaleQty) AS SaleQty,SUM(A.WastageQty) AS WastageQty ,Rate,WastageType,ItemCode,DocNo  FROM (
	
		--SELECT C.Description Category, MM.Description AS ItemName,SUM(BT.Qty) AS SaleQty,0 AS WastageQty,BT.Rate
		--FROM BillTrans BT INNER JOIN MainMenu MM ON BT.PropertyId = MM.PropertyId AND BT.MainMenuCode = MM.ItemCode
		--INNER JOIN Category C ON C.Code = MM.Category AND C.PropertyId = MM.PropertyId
		--WHERE  BT.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
		--	   AND BT.OrderDate <= CONVERT(DATETIME,@ToDate,103) 
		--	   AND BT.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  AND BT.PropertyId=@PropertyId   
		-- GROUP BY C.Description,MM.Description,BT.Rate
		--UNION ALL

		SELECT BT.DocNo , C.Description Category, MM.Description AS ItemName,0 AS SaleQty,SUM(BT.Qty) AS WastageQty,BT.Price AS Rate,IW.Name AS WastageType,MM.ItemCode
		FROM POS_ItemWastageDetails BT INNER JOIN MainMenu MM ON BT.PropertyId = MM.PropertyId AND BT.ItemCode = MM.ItemCode
		INNER JOIN Category C ON C.Code = MM.Category AND C.PropertyId = MM.PropertyId
		INNER JOIN ItemWastageType IW ON BT.WastageTypeId = IW.Id
		WHERE  BT.BusinessDate >= CONVERT(DATETIME,@FromDate,103) 
			   AND BT.BusinessDate <= CONVERT(DATETIME,@ToDate,103) 
			   AND BT.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  AND BT.PropertyId=@PropertyId   
			   AND IW.Id IN (SELECT * FROM STRING_SPLIT(@WastageType,','))

	   GROUP BY C.Description,MM.Description,BT.Price,IW.Name,mm.ItemCode,BT.DocNo
	) A
	GROUP BY A.Category,A.ItemName,A.Rate,a.WastageType,ItemCode,DocNo

END;

GO

