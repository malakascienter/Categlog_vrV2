-- =============================================
-- Author:		BANU
-- ALTER date: 12/11/2018
-- Description:	REPORT HOURLY SALES OUTLET WISE COMPARISION 
-- =============================================
-----EXEC  Report_TimeBaseItemWiseSalesAnalisys 'B01,B02,B03,B04,T01,T02,T03','01/01/2024','11/11/2024','R,T,Y,D,I,P',7,1,1,'7,39,57,31,26,44,11,53,46,56,60,48,23,32,42,52,30,36,22,59,10,16,17,28,1,4,51,14,40,37,38,61,5,15,6,49,24,54,25,55,47,50,27,43,12,8,9,13,18,20,21,45,29,33,35,34,19'
CREATE PROCEDURE [dbo].[Report_TimeBaseItemWiseSalesAnalisys](  
	@Outlet VARCHAR(MAX),    
	@FromDate VARCHAR(10),    
	@ToDate VARCHAR(10),
	@OrderType VARCHAR(MAX),
	@TimeInterval INT  ,
	@PropertyId VARCHAR(2),
	@ValueType VARCHAR(5),
	@Category VARCHAR(max)
)    
AS     
BEGIN   
	CREATE TABLE #TempBillDetails(
	    CategoryName VARCHAR(50),
		MenuCode VARCHAR(200),
		MenuName VARCHAR(200),
		OutletName VARCHAR(50),
		Value MONEY,
		Qty MONEY,
		Outlet VARCHAR(5),
		TempTimeInterval VARCHAR(20),
		TempPeriod VARCHAR(50)
	) 

	SELECT * 
	INTO #TempLocation
	FROM Location_Ref 
	where Code IN (SELECT * FROM STRING_SPLIT(@Outlet,',')) AND PropertyId=@PropertyId


	SELECT * 
	INTO #TempCategory
	FROM Category
	WHERE Category.CatgId  IN (SELECT * FROM STRING_SPLIT(@Category,',')) AND PropertyId = @PropertyId

	SELECT SUM(BH.ChargeAmount) AS ChargeAmount,BH.OrderNo,BH.OrderDate,BH.Outlet,BH.MenuItemID,BH.RefItemID,BH.ItemSequence,BH.SortSeq,BH.PropertyId
	INTO #TempBillChargeDetail
	FROM POS_BillChargeDetail BH WITH(NOLOCK)
	INNER JOIN BillHeader B ON BH.OrderNo = B.OrderNo AND BH.OrderDate = B.OrderDate AND BH.Outlet = B.Outlet AND BH.PropertyId = B.PropertyId
	INNER JOIN #TempLocation L ON BH.Outlet = L.CODE AND BH.PropertyId = L.PropertyId
	WHERE BH.PropertyId=@PropertyId AND BH.OrderDate BETWEEN  CONVERT(DATETIME,@FromDate,103)   AND  CONVERT(DATETIME,@ToDate,103)
	GROUP BY BH.OrderNo,BH.OrderDate,BH.Outlet,BH.MenuItemID,BH.RefItemID,BH.ItemSequence,BH.SortSeq,BH.PropertyId
	
	  
	INSERT INTO #TempBillDetails(CategoryName,MenuCode,MenuName,OutletName,Value,Qty,Outlet,TempTimeInterval,TempPeriod)
	SELECT  #TempCategory.Description,MainMenu.ItemCode,MainMenu.Description, L.description,
	CASE  
	WHEN @ValueType = '1' THEN Sum(BillTrans.Rate * BillTrans.Qty) +ISNULL( SUM(BC.ChargeAmount)  ,0) - SUM(((((BillTrans.[Qty]*BillTrans.[Rate])*BillTrans.[DisPerc])/(100))+BillTrans.[BillDisVal]))
	WHEN @ValueType = '2' THEN Sum(BillTrans.Rate * BillTrans.Qty) +ISNULL( SUM(BC.ChargeAmount)  ,0)
	WHEN @ValueType = '3' THEN Sum(BillTrans.Qty)
	WHEN @ValueType = '4' THEN  
	
	                      ISNULL( (
									select SUM((S_OK.AveragePrice *   [dbo].[FN_GetUnitConvertionRate](S_OK.PropertyID,S_OK.TxnUnitID, S_SD.MasterUnitID))*S_OK.Quantity)
									from OutletKitchenIssues S_OK WITH(NOLOCK)
									INNER JOIN MainMenu S_MM ON S_MM.ItemCode = S_OK.MenuCode AND S_MM.PropertyId = S_OK.PropertyID
									INNER JOIN #TempCategory S_CC ON S_MM.Category = S_CC.Code AND S_MM.PropertyId = S_CC.PropertyId
									INNER JOIN StockItemHeaders AS S_SH WITH(NOLOCK) ON S_SH.Id=S_OK.StockItemID AND S_SH.CompanyId=S_OK.PropertyID
									INNER JOIN StockItemDetails AS S_SD WITH(NOLOCK)  ON S_SD.StockItemHeaderID=S_SH.Id AND S_SH.CompanyId=S_SD.CompanyID AND S_OK.LocationID = S_SD.LocationID
									WHERE S_MM.Category = #TempCategory.Code AND TxnDate = BillTrans.OrderDate AND S_OK.OutletCode = BillTrans.Outlet AND S_OK.PropertyId =  BillTrans.PropertyId 
								),0)--/Sum(BillTrans.Qty)

	END
	,sum(BillTrans.Qty),BillTrans.Outlet,
	RIGHT('0' + CONVERT(VARCHAR,DATEPART(HOUR,BillTrans.OrderTime)),2) + ':00'  AS 'TIME_PERIOD',
	CASE @TimeInterval  ------TIME INTERVAL
		WHEN 6 THEN CONVERT(VARCHAR, BillTrans.OrderDate, 103)
		WHEN 7 THEN CONCAT(CONVERT(VARCHAR,DATENAME(WEEK,BillTrans.OrderDate)),' WEEK ',CONVERT(VARCHAR,DATENAME(YEAR,BillTrans.OrderDate)) 	,' ', [dbo].[FN_GetWeekStartEndDateStr](BillTrans.OrderDate,CONVERT(DATETIME,@FromDate,103),CONVERT(DATETIME,@ToDate,103))	)
		WHEN 8 THEN CONCAT(CONVERT(VARCHAR,DATENAME(MONTH,BillTrans.OrderDate)),' - ',CONVERT(VARCHAR,DATENAME(YEAR,BillTrans.OrderDate))	)
		WHEN 9 THEN CONVERT(VARCHAR,DATENAME(YEAR,BillTrans.OrderDate))		
	END AS 'PERIOD'
	FROM BillTrans WITH(NOLOCK) INNER JOIN MainMenu WITH(NOLOCK) ON  BillTrans.MainMenuCode  = MainMenu.ItemCode AND BillTrans.PropertyId = MainMenu.PropertyId
	INNER JOIN BillHeader WITH(NOLOCK) ON BillTrans.OrderNo = BillHeader.OrderNo AND BillTrans.OrderDate = BillHeader.OrderDate AND BillTrans.Outlet = BillHeader.Outlet AND 
	BillTrans.PropertyId = BillHeader.PropertyId
	INNER JOIN #TempLocation L ON BillTrans.Outlet = L.CODE AND BillTrans.PropertyId = L.PropertyId
	INNER JOIN #TempCategory ON MainMenu.Category = #TempCategory.Code AND MainMenu.PropertyId = #TempCategory.PropertyId
	LEFT JOIN #TempBillChargeDetail  BC ON BillTrans.OrderNo = BC.OrderNo AND BillTrans.OrderDate = BC.OrderDate AND BillTrans.Outlet = BC.Outlet AND BillTrans.MainMenuCode = BC.MenuItemID AND BillTrans.RefItemCode = BC.RefItemID AND BillTrans.ItemSeq = BC.ItemSequence AND BillTrans.SortSeq = BC.SortSeq AND BillTrans.PropertyId = BC.PropertyId
	WHERE BillTrans.PropertyId=@PropertyId AND(BillTrans.OrderDate >= CONVERT(DATETIME,@FromDate,103))     
		AND (BillTrans.OrderDate <= CONVERT(DATETIME,@ToDate,103))     
		AND BillTrans.OrderType IN (SELECT * FROM STRING_SPLIT(@OrderType,','))
		AND (BillHeader.Id NOT IN (

				SELECT	NBH.Id
				FROM	PayTrans NPT
				INNER JOIN BillHeader NBH WITH(NOLOCK) ON NPT.OrderNo = NBH.OrderNo AND NPT.OrderDate = NBH.OrderDate AND NPT.Outlet = NBH.Outlet AND 
	            NPT.PropertyId = NBH.PropertyId
				INNER JOIN #TempLocation L ON NBH.Outlet = L.CODE AND NBH.PropertyId = L.PropertyId
				INNER JOIN PaymentTypes ON NPT.PayCode = PaymentTypes.PayCode
				WHERE	((NoValue = 1) AND NPT.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
				    AND  NPT.OrderDate <= CONVERT(DATETIME,@ToDate,103) )
					AND (NPT.PayCode <> 'BR')  
					AND NBH.OrderType IN (SELECT * FROM STRING_SPLIT(@OrderType,','))
					AND NPT.PropertyId = @PropertyId)
					
				)

	GROUP BY  #TempCategory.Code,#TempCategory.Description,MainMenu.ItemCode,MainMenu.Description, L.description,BillTrans.OrderDate,BillTrans.Outlet,BillTrans.Qty , BillTrans.BillDisVal , BillTrans.DisPerc  , BillTrans.Rate,BillTrans.OrderTime,BillTrans.PropertyId 
	 

	SELECT L.description AS Outlet,
	       #TempBillDetails.CategoryName,
		   #TempBillDetails.MenuCode,
		   #TempBillDetails.MenuName,
		   SUM(#TempBillDetails.Value) AS Sales,
		   SUM(#TempBillDetails.Qty) AS Qty,
		   #TempBillDetails.TempPeriod  AS 'Period',
		   #TempBillDetails.TempTimeInterval AS 'SortForPeriod',
		   FORMAT(CONVERT(DATETIME,#TempBillDetails.TempTimeInterval),'hh:mm tt') +' - '+ FORMAT(DATEADD("HOUR",1,CONVERT(DATETIME,#TempBillDetails.TempTimeInterval)),'hh:mm tt') as TimeInterval
	FROM #TempBillDetails       
	INNER JOIN #TempLocation L ON #TempBillDetails.Outlet = L.code AND L.PropertyId=@PropertyId     
	GROUP BY L.description, #TempBillDetails.CategoryName,#TempBillDetails.MenuCode,#TempBillDetails.MenuName,#TempBillDetails.TempTimeInterval,#TempBillDetails.TempPeriod 
	ORDER BY #TempBillDetails.TempTimeInterval  , L.description,#TempBillDetails.CategoryName,#TempBillDetails.MenuName

	DROP TABLE #TempBillDetails  
	DROP TABLE #TempBillChargeDetail
	DROP TABLE #TempLocation
	DROP TABLE #TempCategory

END;

GO

