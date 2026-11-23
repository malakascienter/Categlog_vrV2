-- =============================================
-- Author:		Banu
-- ALTER date: 05/12/2018
-- Description:	Generate Invoice Wise Sales Report
-- =============================================
--- ReportType Parameter Void -> Void invoice reports,Sale -> Sale invoice reports, All -> All invoice reports
---EXEC Report_InvoiceWiseSales 'S01','01/07/2020','07/07/2020','All',2
CREATE PROCEDURE [dbo].[Report_InvoiceWiseSales]
	@Outlet VARCHAR(3),
	@FromDate VARCHAR(10),
	@ToDate VARCHAR(10),
	@ReportType VARCHAR(10),
	@PropertyId VARCHAR(2)
AS
BEGIN
	SET DATEFORMAT DMY
	DECLARE @SalesSQL NVARCHAR(MAX)
	DECLARE @VoidSQL NVARCHAR(MAX)

	CREATE TABLE #OutPut (
		PropertyId INT,
		OrderNo VARCHAR(20),
		OrderDate DATETIME, 
		OrderTime DATETIME,
		OrderType VARCHAR(100),
		NetAmount NUMERIC(18,2), 
		Discount NUMERIC(18,2), 
		MainMenuCode VARCHAR(20), 
		Description VARCHAR(100),
		Qty NUMERIC(18,2),
		Rate NUMERIC(18,2),
		Amount NUMERIC(18,2),
		ServiceCharge NUMERIC(18,2),
		TaxVal1 NUMERIC(18,2),
		TaxVal2 NUMERIC(18,2),
		TaxVal3 NUMERIC(18,2),
		TaxVal4 NUMERIC(18,2),
		Status VARCHAR(20),
		ItemSeq INT, 
		SortSeq INT
		
	)


	SET @SalesSQL = 'SELECT	H.PropertyId,H.OrderNo, H.OrderDate, H.OrderTime, H.OrderType, H.NetAmount, H.Discount,D.MainMenuCode, I.Description, D.Qty,D.Rate, D.Qty * D.Rate AS Amount,H.ServiceCharge,H.TaxVal1,H.TaxVal2,H.TaxVal3,H.TaxVal4,'''' AS Status, D.ItemSeq, D.SortSeq
	FROM(SELECT	PropertyId,OrderNo, OrderDate, OrderTime, Subtotal + TaxVal1 + TaxVal2 + TaxVal3 + TaxVal4+ServiceCharge AS NetAmount, Discount,ServiceCharge,TaxVal1,TaxVal2,TaxVal3,TaxVal4,
		CASE WHEN OrderType = ''R'' THEN ''Dine In'' ELSE CASE WHEN OrderType = ''D'' THEN ''Drive Thru'' ELSE  CASE WHEN OrderType = ''I'' THEN ''Driving'' ELSE CASE WHEN OrderType = ''P'' THEN ''Reservation'' ELSE CASE WHEN OrderType = ''Y'' THEN ''Delivery'' ELSE ''Take Away'' END END END END END AS OrderType
	FROM	BillHeader WHERE Subtotal>0 and PropertyId='''+@PropertyId+''' AND OrderDate BETWEEN ''' + @FromDate  + ''' AND ''' + @ToDate  + ''' AND Outlet = ''' + @Outlet + '''
	)AS H INNER JOIN BillTrans AS D ON H.OrderNo = D.OrderNo AND H.PropertyId=D.PropertyId AND H.OrderDate = D.OrderDate INNER JOIN MainMenu AS I ON D.MainMenuCode = I.ItemCode AND  I.PropertyId=D.PropertyId AND D.Outlet = ''' + @Outlet + ''''

	SET @VoidSQL = 'SELECT	H.PropertyId,H.OrderNo, H.OrderDate, H.OrderTime, H.OrderType, H.NetAmount, H.Discount,D.MainMenuCode, I.Description, D.Qty,D.Rate, D.Qty * D.Rate AS Amount,H.ServiceCharge,H.TaxVal1,H.TaxVal2,H.TaxVal3,H.TaxVal4,''Void Bill'' AS Status, D.ItemSeq, D.SortSeq
	FROM(SELECT	PropertyId,OrderNo, OrderDate, OrderTime, Subtotal + TaxVal1 + TaxVal2 + TaxVal3 + TaxVal4+ServiceCharge AS NetAmount, Discount,ServiceCharge,TaxVal1,TaxVal2,TaxVal3,TaxVal4,
		CASE WHEN OrderType = ''R'' THEN ''Dine In'' ELSE CASE WHEN OrderType = ''D'' THEN ''Drive Thru'' ELSE  CASE WHEN OrderType = ''I'' THEN ''Driving'' ELSE CASE WHEN OrderType = ''P'' THEN ''Reservation'' ELSE CASE WHEN OrderType = ''Y'' THEN ''Delivery'' ELSE ''Take Away'' END END END END END AS OrderType
	FROM	VoidBillHeader WHERE Subtotal>0 and PropertyId='''+@PropertyId+''' AND OrderDate BETWEEN ''' + @FromDate  + ''' AND ''' + @ToDate  + ''' AND Outlet = ''' + @Outlet + '''
	)AS H INNER JOIN VoidBillTrans AS D ON H.OrderNo = D.OrderNo AND  H.PropertyId=D.PropertyId AND H.OrderDate = D.OrderDate INNER JOIN MainMenu AS I ON D.MainMenuCode = I.ItemCode AND I.PropertyId=D.PropertyId AND D.Outlet = ''' + @Outlet + ''''



	IF @ReportType = 'Void'
		BEGIN
			SET @SalesSQL = @VoidSQL
		END

	IF @ReportType = 'Sale'
		BEGIN
			SET @SalesSQL = @SalesSQL
		END

	IF @ReportType = 'All'
		BEGIN
			SET @SalesSQL = @SalesSQL + ' UNION ALL ' + @VoidSQL
		END
		SET	@SalesSQL = 'INSERT INTO #OutPut (PropertyId,OrderNo, OrderDate, OrderTime, OrderType, NetAmount, Discount,MainMenuCode, Description, Qty, Rate,Amount,ServiceCharge,TaxVal1,TaxVal2,TaxVal3,TaxVal4,Status, ItemSeq, SortSeq) ' + @SalesSQL
		EXEC SP_EXECUTESQL @SalesSQL

	SELECT * FROM #OutPut
	ORDER BY OrderNo, OrderDate, OrderTime, OrderType
END

GO

