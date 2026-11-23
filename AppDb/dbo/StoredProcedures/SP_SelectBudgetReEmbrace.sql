-- =============================================
-- Author:		Isuru Pramodya
-- Create date:2024-08-27
-- Description:	Loading for Budget re-Embrace
-- [dbo].[SP_SelectBudgetReEmbrace] 4
-- =============================================
CREATE PROCEDURE [dbo].[SP_SelectBudgetReEmbrace]
@LocationID INT
	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT distinct SH.ID, SH.DocumentNo,SU.Name SupName,SH.ReferenceNo,CONVERT(VARCHAR,SH.TransactionDate) TransactionDate ,LO.Name LocationName,0 Budget,ISNULL(SH.PaidAmount,0) PaidAmount,[dbo].[FN_GetGRNTotalValue](SH.Id) GRNTotal,([dbo].[FN_GetGRNTotalValue](SH.Id)- ISNULL(SH.PaidAmount,0)) Balance
	,0 IsSelected
	FROM STOCKTRANSACTIONHEADERS SH
	INNER JOIN Suppliers SU ON SH.SupplierID = SU.ID
	INNER JOIN Locations LO ON LO.Id = SH.LocationID
	INNER JOIN BudgetAllocation BU ON BU.LocationID = LO.Id
	WHERE SH.TransactionType = 'GR'
	AND ISNULL(SH.PaidAmount,0) <> [dbo].[FN_GetGRNTotalValue](SH.Id)
	AND SH.LocationID = @LocationID
	AND SH.ReferenceID = 0
	ORDER BY ID DESC


    
END

GO

