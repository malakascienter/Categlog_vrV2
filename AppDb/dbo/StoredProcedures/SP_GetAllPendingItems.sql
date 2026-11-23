
CREATE PROCEDURE [dbo].[SP_GetAllPendingItems]
@from INT,
	@to INT,
	@search VARCHAR(20),
	@sortType INT,
	@sortColumn INT,
	@totalRecordCount INT OUTPUT ,
	@status INT OUTPUT, 
	@message VARCHAR(20) OUTPUT,
	@filterId INT

AS
BEGIN
set @to = 500
DROP TABLE mydata
SELECT @from F ,@to TOX ,
	@search search,
	@sortType sortType ,
	@sortColumn sortColumn,
	@totalRecordCount totalRecordCount,
	@status status, 
	@message message,
	@filterId filterId INTO mydata 
	


	SELECT TSI.Id, TSI.CategoryID,sc.Name AS SubCatergoryName,TSI.SubCategoryId, TSI.SubCategory2Id,
	c.Name AS CategoryName,sc2.Description AS SubCatergory2Name,  TSI.Itemdescription AS Name,
	TSI.Remarks, TSI.ItemUnit AS MasterUnitID,U.Name AS UnitName, TSI.ItemCode AS StockItemCode, TSI.PropertyId, co.Name AS CompanyName 
	INTO #TempPendingItems
	FROM  [dbo].[TempStockItemRequest] TSI
	INNER  JOIN dbo.Categories c ON c.Id = TSI.CategoryId
	INNER JOIN dbo.SubCategories sc ON TSI.SubCategoryId = sc.Id
	INNER JOIN dbo.SubCategories02 sc2 ON sc2.Id = TSI.SubCategory2Id
	INNER JOIN dbo.Units U ON U.Id = TSI.ItemUnit
	INNER JOIN dbo.Companies co ON co.CompanyID = TSI.PropertyId
	WHERE TSI.Approved = 0 

	
	SET @search = LTRIM(RTRIM(@search))

	IF(@sortColumn = 0 AND @sortType = 0)

	BEGIN

		IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM #TempPendingItems 
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY ID ASC)) AS RowNum FROM #TempPendingItems 
			 WHERE ((Id LIKE '%' + @search + '%'  OR CategoryName LIKE '%' + @search + '%')  )
			 ) 
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to  
			ORDER BY Id ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM #TempPendingItems WHERE ((#TempPendingItems.Id LIKE '%' + @search + '%'  
		OR #TempPendingItems.CategoryName LIKE '%' + @search + '%') )

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Id ASC
		)) AS RowNum FROM #TempPendingItems 
				WHERE (id LIKE '%' + @search + '%' OR CategoryName LIKE '%' + @search + '%' )  )
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to  
					ORDER BY InvDets.Id ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM #TempPendingItems
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN CategoryName  END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN CategoryName END) ASC

			)) AS RowNum FROM #TempPendingItems  WHERE ((Id LIKE '%' + @search + '%'  OR Categoryname LIKE '%' + @search + '%' )  ) )
			AS InvDets

			WHERE RowNum BETWEEN @from AND @to  
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN CategoryName END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN CategoryName  END) ASC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM #TempPendingItems WHERE ((#TempPendingItems.id LIKE '%' + @search + '%' 
		 OR #TempPendingItems.categoryname LIKE '%' + @search + '%')  )

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name  END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name  END) ASC
		
		)) AS RowNum FROM #TempPendingItems 
				WHERE ( id LIKE '%' + @search + '%'  OR Name LIKE '%' + @search + '%') )  
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN CategoryName END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN CategoryName  END) ASC
		END 

		END 
		
		SET @status=1
END

GO

