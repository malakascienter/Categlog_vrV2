
--  exec FilterCommiRequestDetails_NewView @List=N'{"RequestedFromDate":"2025-05-17T00:00:00","RequestedToDate":"2025-05-21T00:00:00","DeliverySchedule":-999,"Category":-999,"Item":-999,"Status":"A","ItemName":"","Location":[5,4,14,6,7,2,12,1,8,19,3,13],"ProductionLocation":8}'

CREATE PROCEDURE [dbo].[FilterCommiRequestDetails_NewView]
	@List VARCHAR(MAX)
AS
BEGIN
   DECLARE @RequestedFromDate DATETIME,
            @RequestedToDate DATETIME,
            @DeliverySchedule INT,
            @Category INT,
            @Item INT,
            @Status VARCHAR(2),
            @ItemName NVARCHAR(200),
			@ProductionLocation INT;

    -- Parse JSON input
    SELECT 
        @RequestedFromDate = RequestedFromDate,
        @RequestedToDate = RequestedToDate,
        @DeliverySchedule = DeliverySchedule,
        @Category = Category,
        @Item = Item,
        @Status = Status,
        @ItemName = ItemName,
		@ProductionLocation = ProductionLocation
    FROM OPENJSON(@List)
    WITH (
        RequestedFromDate DATETIME,
        RequestedToDate DATETIME,
        DeliverySchedule INT,
        Category INT,
        Item INT,
        Status NVARCHAR(10),
        ItemName NVARCHAR(200),
		ProductionLocation INT
    );

    DECLARE @cols NVARCHAR(MAX),
            @selectCols NVARCHAR(MAX),
            @sumCols NVARCHAR(MAX),
            @sql NVARCHAR(MAX);

    -- Get distinct location names for pivoting
    SELECT 
        @cols = STRING_AGG(QUOTENAME(Name), ','),
        @selectCols = STRING_AGG('ISNULL(' + QUOTENAME(Name) + ', 0) AS ' + QUOTENAME(Name), ', '),
        @sumCols = STRING_AGG('ISNULL(' + QUOTENAME(Name) + ', 0)', ' + ')
    FROM (
        SELECT DISTINCT rl.Name
        FROM CommiRequestHeader h
        INNER JOIN Locations rl ON h.RequestedLocationID = rl.Id
        WHERE h.RequestedLocationID IN (
            SELECT LocationId  
            FROM OPENJSON(@List, '$.Location')  
            WITH (LocationId INT '$')
        )
        AND CONVERT(DATE, h.RequestedDate) BETWEEN @RequestedFromDate AND @RequestedToDate
		AND H.Status =@Status
    ) AS LocationList;

	
    -- Construct dynamic SQL
    SET @sql = '
    SELECT 
		Approve,
        StockItemID,
        StockItemCode,
        StockItemName,
        FORMAT(RequestedDate, ''yyyy-MM-dd'') AS RequestedDate,
        QuantityInHand,
        ' + @selectCols + ',
        (' + @sumCols + ') AS TotalQty,
		  (' + @sumCols + ') AS RequestedQTY
		,ProductionLocationID
		,PropertyID
    FROM (
        SELECT 
			0 AS Approve,
            d.StockItemID,
            s.StockItemCode,
            s.Name AS StockItemName,
            d.RequestedDate,
            SD.QuantityInHand,
            rl.Name AS RequestLocation,
			dbo.FN_GetUnitConvertionRate(h.PropertyID,d.UnitID,sd.MasterUnitID) *  ISNULL(d.RequestedQTY, 0) AS RequestedQTY
			,h.ProductionLocationID
			,h.PropertyID
        FROM CommiRequestHeader h
        INNER JOIN CommiRequestDetails d ON d.HeaderID = h.ID
        INNER JOIN StockItemHeaders s ON d.StockItemID = s.Id
        INNER JOIN Locations rl ON h.RequestedLocationID = rl.Id
        INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = s.ID AND SD.LocationID = h.ProductionLocationID
        WHERE d.Status = @Status
          AND d.RequestedDate BETWEEN @RequestedFromDate AND @RequestedToDate
          AND (@DeliverySchedule = -999 OR d.DeliveryScheduleID = @DeliverySchedule)
          AND (@Category = -999 OR s.CategoryID = @Category)
          AND (@Item = -999 OR s.Id = @Item)
          AND (s.Name LIKE ''%'' + @ItemName + ''%'' OR s.StockItemCode LIKE ''%'' + @ItemName + ''%'')
          AND h.RequestedLocationID IN (
              SELECT LocationId  
              FROM OPENJSON(@List, ''$.Location'')  
              WITH (LocationId INT ''$'')
          )
          AND h.ProductionLocationID =@ProductionLocation
    ) AS SourceTable
    PIVOT (
        SUM(RequestedQTY)
        FOR RequestLocation IN (' + @cols + ')
    ) AS PivotTable
    ORDER BY StockItemName;
    ';

    -- Execute the final SQL
    EXEC sp_executesql @sql, 
         N'@RequestedFromDate DATETIME, @RequestedToDate DATETIME, @DeliverySchedule INT, @Category INT, @Item INT, @Status VARCHAR(2), @ItemName VARCHAR(50), @List NVARCHAR(MAX), @ProductionLocation INT',
         @RequestedFromDate = @RequestedFromDate,
         @RequestedToDate = @RequestedToDate,
         @DeliverySchedule = @DeliverySchedule,
         @Category = @Category,
         @Item = @Item,
         @Status = @Status,
         @ItemName = @ItemName,
         @List = @List,
		 @ProductionLocation = @ProductionLocation;
END

GO

