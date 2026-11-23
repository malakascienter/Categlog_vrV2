
create PROCEDURE [dbo].[Sp_GetDepartmentWiseStockItems] (@DeptId INT)

AS
BEGIN
	SELECt SH.Id , SH.Name AS text FROM 
	[dbo].[DepartmentWiseItems] DI
	INNER JOIN StockItemHeaders SH
	ON SH.Id = DI.StockItemId
	WHERE DI.DepartmentId = @DeptId


END

GO

