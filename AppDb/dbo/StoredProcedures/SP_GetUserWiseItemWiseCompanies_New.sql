-- [dbo].[SP_GetUserWiseItemWiseCompanies_New] 4168,'01443',1
CREATE PROCEDURE [dbo].[SP_GetUserWiseItemWiseCompanies_New]
(
@UserId INT,
@ItemId INT,
@PropertyID INT
)
AS
BEGIN

	declare @IsAllLocation BIT, @ItemCode VARCHAR(MAX)

	SELECT 
	@IsAllLocation =IsCentralLogin 
	FROM Companies
	WHERE CompanyID = @PropertyID

	SELECT @ItemCode = StockItemCode FROM StockItemHeaders WHERE ID = @ItemId

	IF(@IsAllLocation =1)
	BEGIN
		SELECT distinct --Edited by Nivesh 20240110
			CO.CompanyID,
			CO.Name,
			CASE WHEN CO.CompanyID = @PropertyID THEN 1 ELSE 0 END AS IsChecked,
			S.Id as StockItemID, --Edited by Nivesh 20240110
			S.SupplierID
		FROM [dbo].[CentralUserWiseProperties] C
		INNER JOIN StockItemHeaders S ON S.CompanyId = C.PropertyId 
		INNER JOIN Companies CO ON CO.CompanyID = C.PropertyId
		WHERE C.UserId = @UserId 
		AND S.StockItemCode = @ItemCode
	END

	ELSE
	BEGIN
		SELECT distinct --Edited by Nivesh 20240110
			CO.CompanyID,
			CO.Name,
			CASE WHEN CO.CompanyID = @PropertyID THEN 1 ELSE 0 END AS IsChecked,
			S.Id as StockItemID, --Edited by Nivesh 20240110
			S.SupplierID
		FROM 
			[dbo].[CentralUserWiseProperties] C
			INNER JOIN 
			StockItemHeaders S 
		ON  
			S.CompanyId = C.PropertyId 
			INNER JOIN 
			Companies CO 
		ON 
			CO.CompanyID = C.PropertyId
		WHERE 
			C.UserId = @UserId 
		AND 
			S.StockItemCode = @ItemCode
		AND 
			CO.CompanyID=@PropertyID
	END
END

GO

