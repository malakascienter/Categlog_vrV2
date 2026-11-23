--SP_GetAllIssueNotes 1
CREATE PROCEDURE [dbo].[SP_GetAllIssueNotes]
	@Location INT,
	@Mode INT,
	@HeaderID INT,
	@DeptId INT
AS
BEGIN

IF @Mode=1
Begin
	SELECT STH.id AS RequestHeaderID,STH.DocumentNo FROM dbo.StockTransactionHeaders STH INNER JOIN dbo.StockTransactionDetails STD ON STH.Id=STD.StockTransactionHeaderID 
	WHERE STH.TransactionType='IN' AND STH.LocationID=@Location AND STH.DepartmentID=@DeptId  GROUP BY STH.id,STH.DocumentNo HAVING (SUM(STD.Quantity)-SUM(STD.ReturnQuantity)) > 0 

END 

ELSE 
BEGIN

SELECT sth.DepartmentID,STH.LocationID,0,STH.Id AS RequestHeaderID,STD.Id  AS RequestDetailID,SH.StockItemCode,SH.Name AS ItemName,
U.Name AS UnitCode,STD.UnitPrice,STH.DocumentNo,STD.Quantity-STD.ReturnQuantity AS RequestedQuantity,0,STH.TransactionDate AS RequestDate,STD.Remarks,STH.IsApproved AS DocumentStatus,STD.StockItemID AS StockItemHeaderID,
 U.Id AS UnitID,0,0
 ,ISNULL(SH.IsExpiryDateApplicable,0) IsExpiryDateApplicable

FROM dbo.StockTransactionHeaders STH INNER JOIN dbo.StockTransactionDetails STD ON STH.Id=STD.StockTransactionHeaderID
INNER JOIN dbo.StockItemHeaders SH ON SH.Id = STD.StockItemID INNER JOIN dbo.Units U ON u.Id=STD.MasterUnitID
 WHERE STH.TransactionType='IN' AND STD.StockTransactionHeaderID=@HeaderID AND ((STD.Quantity-STD.ReturnQuantity) > 0)

End


END

GO

