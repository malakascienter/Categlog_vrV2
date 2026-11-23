CREATE PROCEDURE [dbo].[SP_Search_StockItemDetails]

@from INT,
	@to INT,
	@search VARCHAR(20),
	@sortType INT,
	@sortColumn INT,
	@totalRecordCount INT OUTPUT,
	@status INT OUTPUT, 
	@message VARCHAR(20) OUTPUT
AS
DECLARE @statusIN[int]
	SET @statusIN = 0;
	SET  @message = ''

BEGIN
BEGIN TRY
BEGIN TRANSACTION

SET @search = LTRIM(RTRIM(@search))

	IF(@sortColumn = 0 AND @sortType = 0)
	BEGIN
		IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM StockItemDetails
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY ID ASC)) AS RowNum FROM dbo.StockItemDetails  WHERE (Id LIKE '%' + @search + '%' OR  MinimumQuantity LIKE '%' + @search + '%' OR MaximumQuantity LIKE '%' + @search + '%' 
			OR ReOrderLevel LIKE '%' + @search + '%' OR ReOrderQuantity LIKE '%' + @search + '%') ) 
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY Id ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM StockItemDetails WHERE (StockItemDetails.Id LIKE '%' + @search + '%' OR StockItemDetails.MinimumQuantity LIKE '%' + @search + '%' OR StockItemDetails.MaximumQuantity LIKE '%' + @search + '%'
		OR StockItemDetails.ReOrderLevel LIKE '%' + @search + '%' OR StockItemDetails.ReOrderQuantity LIKE '%' + @search + '%') 

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Id ASC
		)) AS RowNum FROM StockItemDetails 
				WHERE id LIKE '%' + @search + '%' OR MinimumQuantity LIKE '%' + @search + '%' OR MaximumQuantity LIKE '%' + @search + '%' OR ReOrderLevel LIKE '%' + @search + '%'
				OR ReOrderQuantity LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Id ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM StockItemDetails
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id  END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN MinimumQuantity
					WHEN @sortColumn = 2 AND @sortType = 1 THEN MaximumQuantity
					WHEN @sortColumn = 3 AND @sortType = 1 THEN ReOrderLevel
					WHEN @sortColumn = 4 AND @sortType = 1 THEN ReOrderQuantity END) ASC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN MinimumQuantity
					WHEN @sortColumn = 2 AND @sortType = 0 THEN MaximumQuantity
					WHEN @sortColumn = 3 AND @sortType = 0 THEN ReOrderLevel
					WHEN @sortColumn = 4 AND @sortType = 0 THEN ReOrderQuantity END) DESC

			)) AS RowNum FROM StockItemDetails  WHERE (Id LIKE '%' + @search + '%' OR MinimumQuantity LIKE '%' + @search + '%' OR MaximumQuantity LIKE '%' + @search + '%' 
			OR ReOrderLevel LIKE '%' + @search + '%'  OR ReOrderQuantity LIKE '%' + @search + '%' )) 
			AS InvDets

			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.Id  END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN MinimumQuantity
					WHEN @sortColumn = 2 AND @sortType = 1 THEN MaximumQuantity
					WHEN @sortColumn = 3 AND @sortType = 1 THEN ReOrderLevel
					WHEN @sortColumn = 4 AND @sortType = 1 THEN ReOrderQuantity END) ASC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.Id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN MinimumQuantity
					WHEN @sortColumn = 2 AND @sortType = 0 THEN MaximumQuantity
					WHEN @sortColumn = 3 AND @sortType = 0 THEN ReOrderLevel
					WHEN @sortColumn = 4 AND @sortType = 0 THEN ReOrderQuantity END) DESC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM StockItemDetails WHERE (StockItemDetails.id LIKE '%' + @search + '%' OR StockItemDetails.MinimumQuantity LIKE '%' + @search + '%' OR StockItemDetails.MaximumQuantity LIKE '%' + @search + '%'
		OR StockItemDetails.ReOrderLevel LIKE '%' + @search + '%' OR StockItemDetails.ReOrderQuantity LIKE '%' + @search + '%') 

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id  END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN MinimumQuantity
					WHEN @sortColumn = 2 AND @sortType = 1 THEN MaximumQuantity
					WHEN @sortColumn = 3 AND @sortType = 1 THEN ReOrderLevel
					WHEN @sortColumn = 4 AND @sortType = 1 THEN ReOrderQuantity END) ASC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN MinimumQuantity
					WHEN @sortColumn = 2 AND @sortType = 0 THEN MaximumQuantity
					WHEN @sortColumn = 3 AND @sortType = 0 THEN ReOrderLevel
					WHEN @sortColumn = 4 AND @sortType = 0 THEN ReOrderQuantity END) DESC

		)) AS RowNum FROM StockItemDetails 
				WHERE id LIKE '%' + @search + '%' OR MinimumQuantity LIKE '%' + @search + '%' OR MaximumQuantity LIKE '%' + @search + '%' OR MaximumQuantity LIKE '%' + @search + '%' OR ReOrderQuantity LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.Id  END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN MinimumQuantity
					WHEN @sortColumn = 2 AND @sortType = 1 THEN MaximumQuantity
					WHEN @sortColumn = 3 AND @sortType = 1 THEN ReOrderLevel
					WHEN @sortColumn = 4 AND @sortType = 1 THEN ReOrderQuantity END) ASC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN MinimumQuantity
					WHEN @sortColumn = 2 AND @sortType = 0 THEN MaximumQuantity
					WHEN @sortColumn = 3 AND @sortType = 0 THEN ReOrderLevel
					WHEN @sortColumn = 4 AND @sortType = 0 THEN ReOrderQuantity END) DESC
		END 
		END
		COMMIT TRAN -- Transaction Success!
	SET @status = @statusIN;
END TRY 
BEGIN CATCH
	SET @status = -1;
	SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))	
END CATCH;
END

GO

