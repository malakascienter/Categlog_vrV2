-- =============================================
-- Author:		ISURU PRAMODYA
-- Create date: 2023 SEPTEMBER 04
-- Description:	Issue Note Based on Cost Account
-- [dbo].[SP_Report_IssueNotesBaseOnTheCostAccount] '2024/09/01','2024/09/10',1,-999,-999
-- =============================================
CREATE PROCEDURE [dbo].[SP_Report_IssueNotesBaseOnTheCostAccount] 
	@FromDate DATETIME,
	@ToDate DATETIME,
	@PropertyID INT,
	@DepartmentID INT,
	@SubAccID INT

AS
BEGIN
	SET NOCOUNT ON;

	SELECT SA.SubAccountName  AS COSAcc, SH.DocumentNo,SH.TransactionDate,SIH.StockItemCode,SIH.Name ItemName,SD.Quantity,U.Name Unit,SD.UnitPrice,SD.Quantity*SD.UnitPrice AS Val
	,D.Name DepartmentName,sd.Remarks,RH.DocumentNo RequestNo
	FROM [Categlog_vrV2].DBO.StockTransactionHeaders SH
	INNER JOIN [Categlog_vrV2].DBO.StockTransactionDetails SD ON SH.ID = SD.StockTransactionHeaderID 
	INNER JOIN [Categlog_vrV2].DBO.StockItemHeaders SIH ON SD.StockItemID = SIH.Id 
	INNER JOIN [Categlog_vrV2].DBO.Departments D ON SH.DepartmentID = D.Id
	INNER JOIN [Categlog_vrV2].DBO.Categories C ON SIH.CategoryID = C.ID
	INNER JOIN [Categlog_vrV2].DBO.SubCategories SC ON SIH.SubCategoryID = SC.ID
	INNER JOIN [Categlog_vrV2].DBO.SubCategories02 SC2 ON SIH.SubCategory2ID = SC2.ID
	INNER JOIN [Categlog_vrV2].dbo.StockItemDetails  ID ON SIH.Id = ID.StockItemHeaderID AND  ID.LocationID = SH.LocationID
	INNER JOIN [Categlog_vrV2].dbo.Units AS U ON ID.MasterUnitID = U.Id
	INNER JOIN [eFinancials_Accounting].DBO.accSubAccountRef SA ON SD.CostTransactionAccountID = SA.AccID
	INNER JOIN RequestHeaders RH ON RH.ID = SH.ReferenceID
	WHERE SH.TransactionType = 'IN' 
	AND SH.PropertyID = @PropertyID
	AND ( SH.TransactionDate BETWEEN @FromDate AND @ToDate ) 
	AND SH.DepartmentID = CASE WHEN @DepartmentID = -999 THEN SH.DepartmentID ELSE @DepartmentID END 
	AND SA.AccID = CASE WHEN @SubAccID = -999 THEN SA.AccID ELSE @SubAccID END 


END

GO

