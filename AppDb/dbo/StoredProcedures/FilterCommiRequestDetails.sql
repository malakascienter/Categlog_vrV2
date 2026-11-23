-- FilterCommiRequestDetails '{"RequestedFromDate":"2024-08-10T00:00:00","RequestedToDate":"3000-01-01T00:00:00","DeliverySchedule":-999,"Category":-999,"Item":-999,"Status":"P","Location":[15,20,19,22,17,6,4,12,21],"ProductionLocation":[1,20]}'
create PROCEDURE [dbo].[FilterCommiRequestDetails]
	@List VARCHAR(MAX)
AS
BEGIN
		DECLARE @RequestedFromDate DATETIME,@RequestedToDate DATETIME,@DeliverySchedule INT,@Category INT
		,@Item INT,@Status VARCHAR(2),@ItemName VARCHAR(50)

		SELECT @RequestedFromDate = RequestedFromDate,@RequestedToDate = RequestedToDate,
		@DeliverySchedule = DeliverySchedule,@Category = Category,@Item = Item,@Status = Status,@ItemName = ItemName
		FROM OPENJSON(@List)
		WITH (
			RequestedFromDate DATETIME,
			RequestedToDate DATETIME,
			DeliverySchedule INT ,
			Category INT,
			Item INT,
			Status NVARCHAR(10),
			ItemName VARCHAR(50)
		);

		SELECT d.ID, d.HeaderID, d.StockItemID,s.StockItemCode,s.Name AS StockItemName, d.UnitID, d.Remarks, d.RequestedQTY,
		d.RequestedDate,d.DeliveryScheduleID, d.AdjustedQty, d.ApprovedQTY, d.Status ,rl.Name RequestLocation,pl.Name ProductLocation 
		FROM CommiRequestHeader h
		INNER JOIN CommiRequestDetails d ON d.HeaderID = h.ID
		INNER JOIN StockItemHeaders s ON d.StockItemID= s.Id
		INNER JOIN Locations rl ON h.RequestedLocationID=rl.Id
		INNER JOIN Locations pl ON h.ProductionLocationID=pl.Id
		WHERE d.Status = @Status
		AND d.RequestedDate BETWEEN @RequestedFromDate AND @RequestedToDate
		AND d.DeliveryScheduleID = CASE WHEN @DeliverySchedule = -999 THEN d.DeliveryScheduleID ELSE @DeliverySchedule END
		AND s.CategoryID = CASE WHEN @Category = -999 THEN s.CategoryID ELSE @Category END
		AND s.Id = CASE WHEN @Item = -999 THEN s.Id ELSE @Item END
		AND s.Name LIKE '%' + @ItemName + '%'
		AND h.RequestedLocationID IN (
			SELECT LocationId 
			FROM OPENJSON(@List, '$.Location') 
			WITH (LocationId INT '$')
		)
		AND h.ProductionLocationID IN (
			SELECT ProductionLocationId 
			FROM OPENJSON(@List, '$.ProductionLocation') 
			WITH (ProductionLocationId INT '$')
		);

END

GO

