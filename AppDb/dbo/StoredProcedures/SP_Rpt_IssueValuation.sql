-- =============================================
-- Author:		Nivesh 
-- Create date: 2026-06-02
-- Description:	Issue Valuation
-- [dbo].[SP_Rpt_IssueValuation] '2023/01/01','2024/11/01',1,-999
-- =============================================
CREATE     PROCEDURE [dbo].[SP_Rpt_IssueValuation] 
	@FromDate DATETIME,
	@ToDate DATETIME,
	@PropertyID INT,
	@DepartmentID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		SH.TransactionDate,
		SIH.StockItemCode,
		SIH.Name ItemName,
		(SD.Quantity* SD.MasterUnitConversion) AS Quantity,
		U.Name Unit,
		(SD.UnitPrice / SD.MasterUnitConversion) AS UnitPrice,
		SD.Quantity*SD.UnitPrice AS Val
		,D.Name DepartmentName,
		RH.DocumentNo as IRNo,
		SD.Remarks as ItemRemarks,
		C.Name AS CategoryName,
		SC.Name AS SubCategoryName,
		SC2.Description AS Sub2CategoryName
	FROM [Categlog_vrV2].DBO.StockTransactionHeaders SH WITH (NOLOCK)
	INNER JOIN [Categlog_vrV2].DBO.StockTransactionDetails SD WITH (NOLOCK) ON SH.ID = SD.StockTransactionHeaderID 
	INNER JOIN [Categlog_vrV2].DBO.StockItemHeaders SIH WITH (NOLOCK) ON SD.StockItemID = SIH.Id 
	INNER JOIN [Categlog_vrV2].DBO.Departments D WITH (NOLOCK) ON SH.DepartmentID = D.Id
	INNER JOIN [Categlog_vrV2].DBO.Categories C WITH (NOLOCK) ON SIH.CategoryID = C.ID
	INNER JOIN [Categlog_vrV2].DBO.SubCategories SC WITH (NOLOCK) ON SIH.SubCategoryID = SC.ID
	INNER JOIN [Categlog_vrV2].DBO.SubCategories02 SC2 WITH (NOLOCK) ON SIH.SubCategory2ID = SC2.ID
	INNER JOIN [Categlog_vrV2].dbo.StockItemDetails  ID WITH (NOLOCK) ON SIH.Id = ID.StockItemHeaderID AND  ID.LocationID = SH.LocationID
	INNER JOIN [Categlog_vrV2].dbo.Units AS U WITH (NOLOCK) ON ID.MasterUnitID = U.Id
	INNER join [Categlog_vrV2].dbo.RequestHeaders As RH WITH (NOLOCK) on RH.Id = SH.ReferenceID
	WHERE SH.TransactionType = 'IN' 
	AND SH.PropertyID = @PropertyID
	AND ( SH.TransactionDate BETWEEN @FromDate AND @ToDate ) 
	AND (@DepartmentID = -999 OR SH.DepartmentID = @DepartmentID)
	Order by SH.DepartmentID, SIH.CategoryID, SIH.SubCategoryID, SIH.SubCategory2ID,SH.TransactionDate, SIH.StockItemCode
END

GO

