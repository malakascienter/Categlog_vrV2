create PROCEDURE [dbo].[SP_GetItemLevelAccountName](@CompanyId INT, @LocationId INT, @StockItemId INT)
	
AS
BEGIN	


	DECLARE @LocationCode NVARCHAR(20), @CategoryCode NVARCHAR(20),@AccName NVARCHAR(250) = null

	SELECT @LocationCode = Code FROM Locations WHERE Id = @LocationId

	SELECT @CategoryCode = C.Code 
	FROM StockItemDetails  D
	INNER JOIN StockItemHeaders H ON H.Id = D.StockItemHeaderID
	INNER JOIN Categories C ON C.Id = H.CategoryID
	WHERE D.StockItemHeaderID = @StockItemId AND D.LocationID = @LocationId AND H.CompanyId = @CompanyId
	--select  @BlockCode , @LocationCode ,@CategoryCode
	SELECT @AccName =R.SubAccountName
	FROM [dbo].[Destinity_GLIntegrationAccountMapping] M
	INNER JOIN [dbo].[accSubAccountRef] R ON M.AccCode = R.AccCode
	WHERE M.BlockCode = 'GRN' AND M.Level1 = @LocationCode AND M.Level2 = @CategoryCode

	SELECT @AccName

END

GO

