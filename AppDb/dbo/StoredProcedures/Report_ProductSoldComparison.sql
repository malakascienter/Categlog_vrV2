
-- =============================================
-- Author:		Banu
-- ALTER date: 
-- Description:	PRODUCT SOLD COMPARISION REPORT
-- =============================================
------EXEC Report_ProductSoldComparison '01/09/2018','30/11/2018'
 CREATE PROCEDURE [dbo].[Report_ProductSoldComparison]
 (
  @FromDate varchar(10),
  @ToDate varchar(10),
  @PropertyId VARCHAR(2)
 )
 AS
 BEGIN

--SELECT sum(BillTrans.Qty) as Qty, MainMenu.Description, 
--	Location_Ref.description AS Outlet, Category.Description AS Category, Category.Code
--	FROM   PaymentTypes INNER JOIN
--		MainMenu INNER JOIN
--		BillTrans INNER JOIN
--		PayTrans ON BillTrans.OrderNo = PayTrans.OrderNo AND BillTrans.Outlet = PayTrans.Outlet ON MainMenu.ItemCode = BillTrans.MainMenuCode INNER JOIN
--		Location_Ref ON BillTrans.Outlet = Location_Ref.code INNER JOIN
--		Category ON MainMenu.Category = Category.Code ON PaymentTypes.PayCode = PayTrans.PayCode
--		WHERE PaymentTypes.NoValue=0 AND BillTrans.OrderDate >=convert(datetime,@Fromdate,103) and BillTrans.OrderDate <=convert(datetime,@Todate,103)
--	GROUP BY  MainMenu.Description, Location_Ref.description, Category.Description, Category.Code	

	CREATE TABLE #TempBT(
		OrderNo VARCHAR(6),
		OrderDate DATETIME,
		Outlet VARCHAR(3),
		MainMenuCode VARCHAR(4),
		Qty MONEY,
		Rate MONEY
	)

	INSERT INTO #TempBT (OrderNo,OrderDate,Outlet,Qty,MainMenuCode,Rate)
	SELECT OrderNo, OrderDate, Outlet, Qty, MainMenuCode ,BT.Rate
	FROM BillTrans BT
	WHERE  BT.OrderDate >=convert(datetime,@Fromdate,103) 
		AND BT.OrderDate <=convert(datetime,@Todate,103) AND BT.PropertyId=@PropertyId

	SELECT sum(TBT.Qty) as Qty, MM.Description, 
		L.description AS Outlet, C.Description AS Category, C.Code,Rate
	FROM #TempBT TBT 
	INNER JOIN MainMenu MM ON TBT.MainMenuCode = MM.ItemCode AND MM.PropertyId=@PropertyId
	INNER JOIN Location_Ref L ON TBT.Outlet = L.code AND L.PropertyId=@PropertyId
	INNER JOIN Category C ON MM.Category = C.Code 	AND c.PropertyId=@PropertyId
	GROUP BY  MM.Description, L.description, C.Description, C.Code,TBT.Rate

	DROP TABLE #TempBT

END

GO

