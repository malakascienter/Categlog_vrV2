CREATE PROCEDURE [dbo].[SP_Filter_Categories]

	@from INT,
	@to INT,
	@search VARCHAR(20),
	@sortType INT,
	@sortColumn INT,
	@filtersearch VARCHAR(20),
	@FilterColumnId INT,
	@FilterColumn VARCHAR(20) OUTPUT,
	@totalRecordCount INT OUTPUT,
	@status INT OUTPUT, 
	@message VARCHAR(20) OUTPUT,
	@executesql NVARCHAR(MAX) OUTPUT
AS
DECLARE @statusIN[int]
	SET @statusIN = 0;
	SET  @message = '';
	IF (@FilterColumnId = 1)
		SET @FilterColumn =  'DepartmentId';



BEGIN
BEGIN TRY
BEGIN TRANSACTION
	SET @search = LTRIM(RTRIM(@search))
		
	IF(@sortColumn = 0 AND @sortType = 0)
	BEGIN
		IF(@search IS NULL OR @search = '')
		BEGIN 
			--SELECT @totalRecordCount = COUNT(*) FROM Categories WHERE DepartmentId= @filtersearch

			SET @totalRecordCount = N'SELECT COUNT(*) FROM Categories WHERE ' + @FilterColumn + ' = ' + @filtersearch
			EXEC sp_executesql  @totalRecordCount
	
			--SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY ID ASC)) AS RowNum FROM dbo.Categories  WHERE ((Id LIKE '%' + @search + '%' OR  Code LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%') AND (DepartmentId = @filtersearch))) 
			--AS InvDets
			--WHERE RowNum BETWEEN @from AND @to 
			--ORDER BY Id ASC 

			SET @executesql =  N'SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY ID ASC)) AS RowNum FROM dbo.Categories
    		WHERE ((Id LIKE ' + '''%' + @search + '%''' + 'OR  Code LIKE ' + '''%' + @search + '%''' + ' OR Name LIKE ' + '''%' + @search + '%''' + ' AND ' +
    		'('+ @FilterColumn + '='+  @filtersearch + ' )))) AS InvDets WHERE RowNum BETWEEN '+ CONVERT(varchar(20),@from) +'  AND ' + CONVERT(varchar(20), @to) + ' ORDER BY Id ASC';

			EXEC (@executesql)

		END

	ELSE
        BEGIN

		SET @totalRecordCount = N'COUNT(*) FROM Categories WHERE ((Categories.Id LIKE ' + '''%' + @search + '%''' + ' OR Categories.Code LIKE ' + '''%' + @search + '%''' + ' OR Categories.Name LIKE ' + '''%' + @search + '%''' + ') AND (DepartmentId= @filtersearch))'
		EXEC sp_executesql  @totalRecordCount

		--SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Id ASC
		--)) AS RowNum FROM Categories 
		--		WHERE ((id LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%' OR Code LIKE '%' + @search + '%') AND (DepartmentId= @filtersearch))) 
		--		AS InvDets 
					
		--			WHERE InvDets.RowNum BETWEEN @from AND @to 
		--			ORDER BY InvDets.Id ASC

		SET @executesql = N'SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Id ASC
		)) AS RowNum FROM Categories 
				WHERE ((id LIKE ' + '''%' + @search + '%''' + ' OR Name LIKE ' + '''%' + @search + '%''' + ' OR Code LIKE ' + '''%' + @search + '%''' + ') AND ( ' + @FilterColumn + ' = ' + @filtersearch  +'))) 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN '+ CONVERT(varchar(20),@from) +'  AND ' + CONVERT(varchar(20), @to) + ' 
					ORDER BY InvDets.Id ASC';

		EXEC sp_executesql  @executesql

		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			--SELECT @totalRecordCount = COUNT(*) FROM Categories
			SET @totalRecordCount = N'SELECT COUNT(*) FROM Categories ' + @FilterColumn + ' = ' + @filtersearch
			EXEC sp_executesql  @totalRecordCount
	
			SET @executesql = N'SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN ' + @sortColumn + ' = 0 AND @sortType = 1 THEN id  END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN code END) ASC
		
		)) AS RowNum FROM Categories 
				WHERE ( DepartmentId= @filtersearch))
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id  END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN code END) ASC'

					EXECUTE(@executesql)
			
		END

ELSE
        BEGIN

		--SELECT @totalRecordCount = COUNT(*) FROM Categories WHERE ((Categories.id LIKE '%' + @search + '%' OR Categories.Code LIKE '%' + @search + '%' OR Categories.Name LIKE '%' + @search + '%') AND (DepartmentId= @filtersearch) )
		SET @totalRecordCount = N'COUNT(*) FROM Categories WHERE ((Categories.Id LIKE ' + '''%' + @search + '%''' + ' OR Categories.Code LIKE ' + '''%' + @search + '%''' + ' OR Categories.Name LIKE ' + '''%' + @search + '%''' + ') AND (DepartmentId= @filtersearch))'
		EXEC sp_executesql  @totalRecordCount

		SET @executesql = N'SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id  END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN code END) ASC
		
		)) AS RowNum FROM Categories 
				WHERE ( id LIKE ' + '''%' + @search + '%''' + ' OR Code LIKE ' + '''%' + @search + '%''' + ' OR Name LIKE ' + '''%' + @search + '%''' + ') AND (DepartmentId= @filtersearch))
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id  END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN code END) ASC'

					EXECUTE(@executesql)
			
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




--SP_Search_Filter_GetStockItemHeaders
--SP_Seach_GetReferenceWithStockItemHeaders
--SP_Search_GetAttributesWithStockItemHeaders
--SP_Search_GetSuppliersWithStockItemHeaders
--SP_Search_GetLocationWithStockItemHeaders
--SP_Search_GetAllAttributes
--SP_Search_GetAllReference

GO

