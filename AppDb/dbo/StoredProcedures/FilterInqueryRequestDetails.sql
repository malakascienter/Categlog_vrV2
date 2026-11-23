-- FilterInqueryRequestDetails '{"FromDate":"2024-09-04T00:00:00","ToDate":"3000-01-01T00:00:00","Category":-999,"Item":-999,"SubCategory":-999,"SubCategory2":-999,"Outlet":[2,15,20,19,22,17,6,4,12,21]}'
CREATE PROCEDURE [dbo].[FilterInqueryRequestDetails]
@List VARCHAR(MAX)
AS
BEGIN
	DECLARE @FromDate DATETIME,@ToDate DATETIME,@Category INT
		,@Item INT,@SubCategory INT,@SubCategory2 INT
	SELECT @FromDate = FromDate,@ToDate = ToDate,
	@Category=Category,@Item=Item,@SubCategory=SubCategory,@SubCategory2=SubCategory2
		FROM OPENJSON(@List)
		WITH (
		FromDate DATETIME,
		ToDate DATETIME,
		Category INT,
		Item INT,
		SubCategory INT,
		SubCategory2 INT
		);

		SELECT sh.StockItemCode,sh.Name,cd.RequestedQTY,cd.ApprovedQTY,0 TransferredQTY,sd.QuantityInHand
		FROM CommiRequestHeader ch
		INNER JOIN CommiRequestDetails cd ON ch.ID=cd.HeaderID	
		INNER JOIN  StockItemHeaders sh  ON sh.Id=cd.StockItemID
		INNER JOIN  StockItemDetails sd ON sd.StockItemHeaderID=sh.Id
		INNER JOIN Locations rl ON ch.RequestedLocationID=rl.Id
		where cd.RequestedDate BETWEEN @FromDate AND @ToDate
		AND sh.CategoryID = CASE WHEN @Category = -999 THEN sh.CategoryID ELSE @Category END
		AND sh.SubCategoryID = CASE WHEN @SubCategory = -999 THEN sh.SubCategoryID ELSE @SubCategory END
		AND sh.SubCategory2ID = CASE WHEN @SubCategory2 = -999 THEN sh.SubCategory2ID ELSE @SubCategory2 END
		AND sh.Id = CASE WHEN @Item = -999 THEN sh.Id ELSE @Item END
		AND ch.RequestedLocationID IN (
			SELECT LocationId 
			FROM OPENJSON(@List, '$.Outlet') 
			WITH (LocationId INT '$')
		)
	 
END

GO

