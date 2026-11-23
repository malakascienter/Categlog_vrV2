-- =============================================
-- Author:		Tharuka Sachintha 
-- Create date: 2026-05-26
-- Description:	get franchise invoice report data

-- SP_RPT_FranchiseIssueInvoice 11750


-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_FranchiseIssueInvoice] 
	@StockTxnID INT
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT SIH.Name AS ItemName, SIH.StockItemCode AS StockItemCode, SD.Remarks AS ItemRemark, U.Name AS Unit, SD.SellingPrice AS UnitPrice, SD.Quantity, SD.Quantity * SD.SellingPrice AS Total,
	SH.Remarks, SH.DocumentNo, L.Name AS LocationName, D.Name AS Franchise, SH.ReferenceNo, SH.TransactionDate, SH.Remarks AS HeaderRemark, C.Name AS Company
	FROM StockTransactionHeaders SH
	INNER JOIN StockTransactionDetails SD ON SH.ID = SD.StockTransactionHeaderID
	INNER JOIN StockItemHeaders SIH ON SIH.Id = SD.StockItemID
	INNER JOIN Units U ON U.Id = SD.TxnUnitID
	INNER JOIN Locations L ON L.Id = SH.LocationID
	INNER JOIN Departments D ON D.Id = SH.DepartmentID
	INNER JOIN Companies C ON C.CompanyID = SH.PropertyID
	WHERE SH.Id = @StockTxnID
	
   
END

GO

