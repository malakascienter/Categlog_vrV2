
CREATE PROCEDURE [dbo].[AggregatorsWiseMenu_M_Select] 
@PropertyId INT,
@AggType INT,
@Outlet VARCHAR(5)
AS
BEGIN
	 
	SET NOCOUNT OFF;

	SELECT AM.Id,AM.MenuCode,MM.Description AS MenuName,AM.AggregatorId,a.Aggregator AS AggregatorName,AM.Outlet,MM.IsUploadToUberEat
	FROM AggregatorWiseMenuItem AM INNER JOIN POS_Aggregators A ON AM.AggregatorId = A.Id AND AM.PropertyId = a.PropertyId
	INNER JOIN  MainMenu MM ON MM.ItemCode = AM.MenuCode  AND MM.PropertyId = AM.PropertyId
	WHERE AM.PropertyId = @PropertyId AND AM.AggregatorId = @AggType AND AM.Outlet = @Outlet

END

GO

