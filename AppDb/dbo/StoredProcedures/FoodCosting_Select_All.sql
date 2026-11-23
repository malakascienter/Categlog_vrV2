
-- =============================================
-- Author:		Chiraj
-- Create date: 2020-10-5
-- Description:	Select 
-- =============================================
--FoodCosting_Select_All 2,2
CREATE PROCEDURE [dbo].[FoodCosting_Select_All] 
	@Id INT,
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT
	S.*,
	(SELECT * FROM [dbo].[CostingTypeWiseChargeCodes] WHERE PropertyId=@PropertyId  AND CostingId=@Id FOR JSON AUTO) AS PostingTypejson,
	(SELECT * FROM [dbo].[CostingTypeWiseDepartmentsWiseItemCategory] WHERE PropertyId=@PropertyId AND CostingId=@Id FOR JSON AUTO) AS Departmentjson,
	(SELECT * FROM [dbo].[CostingTypeWiseItemCategories] WHERE PropertyId=@PropertyId AND CostingId=@Id FOR JSON AUTO) AS ItemCategoryjson,
	(SELECT * FROM [dbo].[CostingTypeWiseOutletWiseItemCategory] WHERE PropertyId=@PropertyId AND CostingId=@Id FOR JSON AUTO) AS outletjson,
	(SELECT * FROM [dbo].[CostingTypeWisePaymentTypes] WHERE PropertyId=@PropertyId AND CostingId=@Id FOR JSON AUTO) AS PaymentTypejson,
	(SELECT * FROM [dbo].[CostingTypeWiseStockLocationWiseItemCategory] WHERE PropertyId=@PropertyId AND CostingId=@Id FOR JSON AUTO) AS Locationjson	
	FROM [dbo].[CostingSetting] AS S 
	WHERE PropertyId=@PropertyId AND Id=@Id

   
END

GO

