
--[Report_Costing_IssueNotes] '04/05/2022' ,15,'60'
CREATE PROCEDURE [dbo].[Report_Costing_IssueNotes] 
	@FromDate VARCHAR(20),
	@PropertyId INT,
	@CostingId INT
AS
BEGIN	
	SET NOCOUNT ON;	
	SET DATEFORMAT DMY
	DECLARE @CurrMonthFirstDate DATETIME
	DECLARE @ReportDate DATETIME
	
	SET @CurrMonthFirstDate=(SELECT DATEADD(m, DATEDIFF(m, 0, CONVERT(datetime,@FromDate,103)), 0))
	SET  @ReportDate =CONVERT(DATETIME,@FromDate,103)

	print CONVERT(DATE,@ReportDate,103)
	IF OBJECT_ID(N'tempdb..#Temp') IS NOT NULL
	BEGIN
	DROP TABLE #Temp
	END
	IF OBJECT_ID(N'tempdb..#TempIssuNoteToDate') IS NOT NULL
	BEGIN
	DROP TABLE #TempIssuNoteToDate
	END
	IF OBJECT_ID(N'tempdb..#TempIssuNoteMTD') IS NOT NULL
	BEGIN
	DROP TABLE #TempIssuNoteMTD
	END
	IF OBJECT_ID(N'tempdb..#TempIssuNote') IS NOT NULL
	BEGIN
	DROP TABLE #TempIssuNote
	END



	CREATE TABLE #TempIssuNote(
	TransactionDate DATE,
	Qty DECIMAL(18,6),
	Price DECIMAL(18,6),
	Name VARCHAR(250),
	TxnType VARCHAR(1),
	CategoryName VARCHAR(150),
	StockCategoryCode VARCHAR(4),
	LocationID INT,
	Department INT
	
	)
	INSERT INTO #TempIssuNote(TransactionDate,Qty,Price,Name,TxnType,CategoryName,StockCategoryCode,LocationID,Department)
	SELECT 
	CONVERT(date,STH.TransactionDate,103)AS TransactionDate,
	SD.Quantity
	,SD.UnitPrice,
	SH.Name,
	SD.TxnType,
	C.Code AS CategoryCode,
	SH.CategoryID,
	STH.LocationID,
	STH.DepartmentID
	from StockTransactionDetails AS SD
	INNER JOIN StockTransactionHeaders AS STH ON SD.StockTransactionHeaderID=STH.Id
	INNER JOIN StockItemHeaders AS SH ON SH.Id=SD.StockItemID
	INNER JOIN Categories AS C ON  C.Id=SH.CategoryID
	LEFT JOIN Departments D ON  D.ID=STH.DepartmentID 
	INNER JOIN CostingTypeWiseDepartmentsWiseItemCategory AS X ON X.Code=D.Code AND X.ItemCategoryId=SH.CategoryID
	--INNER JOIN Locations D ON  D.ID=STH.Locationid 
	--INNER JOIN CostingTypeWiseStockLocationWiseItemCategory AS X ON X.Code=D.Code AND X.ItemCategoryId=SH.CategoryID
	WHERE SH.CompanyId=@PropertyId --AND STH.TransactionType='IN' 
	AND X.CostingId=@CostingId AND X.PropertyId = @PropertyId
	and CONVERT(DATE,STH.TransactionDate,103)  >= CONVERT(DATE,@CurrMonthFirstDate,103) AND  CONVERT(DATE,STH.TransactionDate,103)   <= CONVERT(DATE,@ReportDate,103)

	 CREATE TABLE #TempIssuNoteToDate(Department INT,TDS DECIMAL(18,6))
	 CREATE TABLE #TempIssuNoteMTD	(Department INT,MTD DECIMAL(18,6))
	 CREATE TABLE #Temp	(DepartmentName VARCHAR(200),TDS DECIMAL(18,6),MTD DECIMAL(18,6))

	INSERT INTO #TempIssuNoteToDate(Department,TDS)
	SELECT  Department,SUM(Qty*Price)AS ToTal from #TempIssuNote 
	where TransactionDate = CONVERT(DATE,@ReportDate,103) 
	group by Department,LocationID,StockCategoryCode 
	ORDER BY LocationID ASC
	
	INSERT INTO #TempIssuNoteMTD(Department,MTD)
	SELECT Department,SUM(Qty*Price)AS ToTalMTD 
	from #TempIssuNote where TransactionDate between CONVERT(DATE,@CurrMonthFirstDate,103)  and CONVERT(DATE,@ReportDate,103) 
	group by Department,LocationID,StockCategoryCode 
	ORDER BY LocationID ASC
	

	INSERT INTO #Temp(DepartmentName,TDS,MTD)
	SELECT 
	D.Name,
	0,
	Y.MTD
	FROM #TempIssuNoteMTD AS Y 
	INNER JOIN Departments AS D ON D.Id=Y.Department
	

	INSERT INTO #Temp(DepartmentName,TDS,MTD)
	SELECT 
	D.Name,
	Y.TDS,
	0
	FROM #TempIssuNoteToDate AS Y 
	INNER JOIN Departments AS D ON D.Id=Y.Department

	SELECT DepartmentName,IsNULL(SUM(MTD),0.00) MTD,IsNULL(SUM(TDS),0.00) TDS
	FROM #Temp
	GROUP BY DepartmentName


	--SELECT * FROM #TempIssuNote
	
 IF OBJECT_ID(N'tempdb..#Temp') IS NOT NULL
	BEGIN
	DROP TABLE #Temp
	END
	IF OBJECT_ID(N'tempdb..#TempIssuNoteToDate') IS NOT NULL
	BEGIN
	DROP TABLE #TempIssuNoteToDate
	END
	IF OBJECT_ID(N'tempdb..#TempIssuNoteMTD') IS NOT NULL
	BEGIN
	DROP TABLE #TempIssuNoteMTD
	END
	IF OBJECT_ID(N'tempdb..#TempIssuNote') IS NOT NULL
	BEGIN
	DROP TABLE #TempIssuNote
	END

 
END

GO

