create PROCEDURE [dbo].[SP_GetUserWiseItemWiseCompanies](@UserId INT, @ItemCode NVARCHAR(250))
AS
BEGIN
	SELECT CO.CompanyID,CO.Name,0 AS IsChecked
	FROM [dbo].[CentralUserWiseProperties] C
	INNER JOIN StockItemHeaders S ON  S.CompanyId = C.PropertyId 
	INNER JOIN Companies CO ON CO.CompanyID = C.PropertyId
	WHERE C.UserId = @UserId AND S.StockItemCode = @ItemCode
END

GO

