-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-05-17
-- Description:	Loading departmentWIse items for transactions
-- [dbo].[SP_GetALLPRItemOnDepartments] 4,1,16,0 
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetALLPRItemOnDepartments] 
	 @Locationid INT ,
    @Propertyid INT,
	@DeptId INT ,
	 @Categoryid INT  = 0
    WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	IF (@Categoryid =0)
	BEGIN
	SELECT DISTINCT
					dbo.StockItemHeaders.Id ,
					dbo.StockItemHeaders.StockItemCode+ '/'+
					dbo.StockItemHeaders.Name as Name,StockItemHeaders.IsExpiryDateApplicable,QuantityInHand,
					dbo.StockItemDetails.AveragePrice UnitPrice
	FROM    dbo.StockItemDetails
			INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
			INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = dbo.StockItemHeaders.Id
	WHERE   ( dbo.StockItemDetails.LocationID = @Locationid )
			AND ( dbo.StockItemDetails.PropertyID = @Propertyid ) AND (dbo.StockItemDetails.IsActive = 1) 
			AND DI.DepartmentId =  CASE WHEN @DeptId = -999 THEN  DI.DepartmentId ELSE @DeptId END

	ORDER BY Name
	END
	ELSE
	BEGIN
	SELECT  dbo.StockItemHeaders.Id ,
					dbo.StockItemHeaders.Name,
					StockItemHeaders.IsExpiryDateApplicable,QuantityInHand
                
	FROM    dbo.StockItemDetails
			INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
			INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = dbo.StockItemHeaders.Id
	WHERE   ( dbo.StockItemDetails.LocationID = @Locationid )
			AND ( dbo.StockItemDetails.PropertyID = @Propertyid )
			AND ( dbo.StockItemHeaders.CategoryID = @Categoryid ) AND dbo.StockItemDetails.IsActive=1
			AND DI.DepartmentId =  CASE WHEN @DeptId = -999 THEN  DI.DepartmentId ELSE @DeptId END
	ORDER BY dbo.StockItemHeaders.Name
	END



END

GO

