-- =============================================
-- Author:		Chiraj
-- Create date: 2019-10-16
-- Description:	Food Cost Stock I records
-- =============================================
--[Report_FoodCosting_IssueNotes] 2,1003
Create PROCEDURE [dbo].[Report_FoodCosting_IssueNotes] 
	@FromDate VARCHAR(20),
	@PropertyId INT,
	@CostingId INT
AS
BEGIN	
	SET NOCOUNT ON;	
	SET DATEFORMAT DMY
	DECLARE @CurrMonthFirstDate DATETIME
	DECLARE @ReportDate DATETIME
	DECLARE @CurrYearFirstDate DATETIME
	
	SET @CurrMonthFirstDate=(SELECT DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0))
	--SET @ReportDate =(select GETDATE()-1) removed by request aruna 2020-11-12
	SET  @ReportDate =CONVERT(DATETIME,@FromDate,103)-1
	SET @CurrYearFirstDate= (select convert (date,DATEADD(YEAR,DATEDIFF(YEAR,0,GETDATE()),0)))


	CREATE TABLE #TempIssuNote(
	CreatedDate DATETIME,
	Qty DECIMAL(18,4),
	Price DECIMAL(18,4),
	Name VARCHAR(250),
	TxnType VARCHAR(1),
	CategoryName VARCHAR(150),
	StockCategoryCode VARCHAR(4),
	LocationID INT,
	Department INT
	
	)
	INSERT INTO #TempIssuNote(CreatedDate,Qty,Price,Name,TxnType,CategoryName,StockCategoryCode,LocationID,Department)
		SELECT 
	--SD.Id,
	--SD.StockTransactionHeaderID,
	--,SD.StockItemID,
	CONVERT(date,SD.CreatedDate,103)AS CreatedDate,
	SD.Quantity
	,SD.NewAveragePrice,
	SH.Name,
	SD.TxnType,
	C.Code AS CategoryCode,
	SH.CategoryID,
	STH.LocationID,
	STH.DepartmentID
	--C.Name AS Category
	from StockTransactionDetails AS SD
	INNER JOIN StockTransactionHeaders AS STH ON SD.StockTransactionHeaderID=STH.Id
	INNER JOIN StockItemHeaders AS SH ON SH.Id=SD.StockItemID
	INNER JOIN Categories AS C ON  C.Id=SH.CategoryID
	INNER JOIN CostingTypeWiseDepartmentsWiseItemCategory AS X ON X.Code=STH.DepartmentID AND X.ItemCategoryId=SH.CategoryID
	WHERE X.CostingId=@CostingId AND SH.CompanyId=@PropertyId AND SD.TxnType='p' 


	 CREATE TABLE #TempIssuNoteToDate(Department INT,LocationID INT,CategoryId INT,TodaySale DECIMAL(18,4))
	 CREATE TABLE #TempIssuNoteMTD	(Department INT,LocationID INT,CategoryId INT,MTDSale DECIMAL(18,4))
	 CREATE TABLE #TempIssuNoteYTD	(Department INT,LocationID INT,CategoryId INT,YTDSale DECIMAL(18,4))
	

	INSERT INTO #TempIssuNoteToDate(Department,LocationID,CategoryId,TodaySale)
	SELECT  Department,LocationID,StockCategoryCode,SUM(Qty*Price)AS ToTal from #TempIssuNote 
	where CreatedDate= CONVERT(DATE,@ReportDate,103) 
	group by Department,LocationID,StockCategoryCode 
	ORDER BY LocationID ASC
	
	INSERT INTO #TempIssuNoteMTD(Department,LocationID,CategoryId,MTDSale)
	SELECT Department,LocationID,StockCategoryCode,SUM(Qty*Price)AS ToTalMTD 
	from #TempIssuNote where CreatedDate between CONVERT(DATE,@CurrMonthFirstDate,103)  and CONVERT(DATE,@ReportDate,103) 
	group by Department,LocationID,StockCategoryCode 
	ORDER BY LocationID ASC
	
	INSERT INTO #TempIssuNoteYTD(Department,LocationID,CategoryId,YTDSale)
	SELECT Department,LocationID,StockCategoryCode,SUM(Qty*Price) AS ToTalYTD 
	from #TempIssuNote where CreatedDate between CONVERT(DATE,@CurrYearFirstDate,103)  and CONVERT(DATE,@ReportDate,103) 
	group by Department,LocationID,StockCategoryCode 
	ORDER BY LocationID ASC


	--SELECT * FROM #TempIssuNoteToDate
	--SELECT * FROM #TempIssuNoteMTD
	--SELECT * FROM #TempIssuNoteYTD

	SELECT Y.Department,
	D.Name AS DepartmentName--,Y.LocationID,Y.CategoryId
	,ISNULL(T.TodaySale,0.00)AS ToDateSale,IsNULL(M.MTDSale,0.00) MTD,IsNull(Y.YTDSale,0.00)YTD
	FROM  #TempIssuNoteYTD AS Y 
	LEFT JOIN #TempIssuNoteMTD AS M ON Y.Department=M.Department
	LEFT JOIN #TempIssuNoteToDate AS T ON T.Department=Y.Department
	INNER JOIN Departments AS D ON D.Id=Y.Department
 
 
END

GO

