
-- =============================================
-- Author:		Banu
-- ALTER date: 06/12/2018
-- Description:	Discount Report
-- =============================================
----EXEC Report_Discount_WithItemDiscount 'WDS','02/05/2022','02/05/2022',20
CREATE PROCEDURE [dbo].[Report_Discount_WithItemDiscount]
	 @Outlet VARCHAR(MAX),
	 @FromDate VARCHAR(50),      
	 @ToDate VARCHAR(50),
	 @PropertyId VARCHAR(2)
AS
BEGIN
	

	IF OBJECT_ID(N'tempdb..#TempSelectDiscount') IS NOT NULL
	BEGIN
	DROP TABLE #TempSelectDiscount
	END
	IF OBJECT_ID(N'tempdb..#TempDiscount') IS NOT NULL
	BEGIN
	DROP TABLE #TempDiscount
	END

	 CREATE TABLE #TempSelectDiscount(
			Outlet [varchar](5) NULL,
			SubTotal money,
			Tax money,
			Pax money,
			ServiceCharge money,
			Discount money,
			OrderNo char(6),
			OrderDate datetime null,
			OrderTime datetime null,
			Reason [varchar](200) null,
			Remark [varchar](200) null,
			PropertyId INT,
			DiscountAuthUser [varchar](MAX) null,
		);

		 CREATE TABLE #TempDiscount(
			Outlet [varchar](5) NULL,
			SubTotal money,
			Tax money,
			Pax money,
			ServiceCharge money,
			Discount money,
			OrderNo char(6),
			OrderDate datetime null,
			OrderTime datetime null,
			Reason [varchar](200) null,
			Remark [varchar](200) null,
			PropertyId INT
		);


	INSERT INTO #TempDiscount (Outlet,SubTotal,Tax,OrderNo,OrderDate,Pax,Discount,ServiceCharge,Reason,Remark)
	
	SELECT L.code AS Outlet, (BH.Subtotal) AS SubTotal, (BH.TaxVal1+BH.TaxVal2+BH.TaxVal3+BH.TaxVal4) AS Tax,      
	BH.OrderNo, BH.OrderDate, BH.pax AS 'Pax', ((Qty * Rate) * BillDisPer /100) + ((Qty * Rate) * ItemDisPer/100) + BillDisVal + ItemDisVal AS Discount, (BH.ServiceCharge) AS ServiceCharge ,DH.Description AS Reason  ,
	BH.DiscRemarks AS Remark

	FROM BillHeader BH    
	INNER JOIN BillTrans PT ON BH.OrderNo = PT.OrderNo AND BH.OrderDate = PT.OrderDate AND BH.Outlet = PT.Outlet    AND PT.PropertyId=BH.PropertyId        
	INNER JOIN DiscountHeader AS DH ON PT.DisCode=DH.Code --AND DH.PropertyId=BH.PropertyId
	INNER JOIN Location_Ref L ON BH.Outlet = L.code   AND   L.PropertyId=BH.PropertyId	    
	WHERE  
	BH.PropertyId=@PropertyId
	AND (BH.OrderDate >= CONVERT(DATETIME,@FromDate,103)) 
	AND (BH.OrderDate <= CONVERT(DATETIME,@ToDate,103))     
	AND BH.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,',')) 
	--AND (BH.DisCode = '' OR BH.DisCode IS NULL)
	--GROUP BY BH.OrderNo,BH.OrderDate, L.code,DH.Description ,BH.pax      
	--HAVING SUM(BH.Discount) > 0 
	--ORDER BY L.description , BH.OrderNo

	
	  DECLARE @OrderNoT CHAR(6)
	  DECLARE @OrderDateT DateTime
	  DECLARE @OutletT char(3)
	  DECLARE @DiscountAuthUser VARCHAR(MAX)

	 WHILE EXISTS  (SELECT * FROM #TempDiscount)
	 BEGIN
	 
	 SELECT TOP 1  @OrderNoT = OrderNo,@OrderDateT = OrderDate,@OutletT = Outlet FROM #TempDiscount
		
		IF EXISTS( SELECT * FROM #TempSelectDiscount WHERE OrderNo = @OrderNoT AND OrderDate = @OrderDateT AND Outlet = @OutletT )
		BEGIN

		IF OBJECT_ID(N'tempdb..#TempDiscountAuthUser') IS NOT NULL
		BEGIN
		DROP TABLE #TempDiscountAuthUser
		END

		 select BT.DiscountAuthUser INTO #TempDiscountAuthUser  
		 from BillTrans BT 
		 WHERE BT.OrderNo =@OrderNoT and bt.OrderDate = @OrderDateT and BT.Outlet = @OutletT
		 GROUP BY BT.DiscountAuthUser


		 SELECT @DiscountAuthUser = STRING_AGG(DiscountAuthUser, ', ') FROM #TempDiscountAuthUser

		IF OBJECT_ID(N'tempdb..#TempDiscountAuthUser') IS NOT NULL
		BEGIN
		DROP TABLE #TempDiscountAuthUser
		END
		
		 INSERT INTO #TempSelectDiscount (Outlet,SubTotal,Tax,ServiceCharge,Discount,OrderNo,OrderDate,PropertyId,Pax,Reason,Remark,DiscountAuthUser)
		 SELECT TOP 1  Outlet,0+Discount,0,0,Discount,OrderNo,OrderDate,@PropertyId,0,Reason,Remark,@DiscountAuthUser FROM #TempDiscount
		
		END
		ELSE
		BEGIN
		
		 INSERT INTO #TempSelectDiscount (Outlet,SubTotal,Tax,ServiceCharge,Discount,OrderNo,OrderDate,PropertyId,Pax,Reason,Remark,DiscountAuthUser)
		 SELECT TOP 1  Outlet,SubTotal+Discount,Tax,ServiceCharge,Discount,OrderNo,OrderDate,@PropertyId,Pax,Reason,Remark,@DiscountAuthUser FROM #TempDiscount
		
		END




		DELETE TOP (1) FROM   #TempDiscount

	 END 

	 SELECT L.description  AS description,T.SubTotal,T.Tax,T.ServiceCharge,T.Discount,T.OrderNo,T.OrderDate,T.Pax,T.Reason,Remark,DiscountAuthUser
	 FROM #TempSelectDiscount T INNER JOIN Location_Ref L ON T.Outlet = L.Code AND T.PropertyId = L.PropertyId



	

	IF OBJECT_ID(N'tempdb..#TempSelectDiscount') IS NOT NULL
	BEGIN
	DROP TABLE #TempSelectDiscount
	END
	IF OBJECT_ID(N'tempdb..#TempDiscount') IS NOT NULL
	BEGIN
	DROP TABLE #TempDiscount
	END

END

GO

