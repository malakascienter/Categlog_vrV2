 --[dbo].[SP_Search_SelectPropertyWiseItems_New] 1,10,'',0,0,0,-999,-999,-999,1
  --[dbo].[SP_Search_SelectPropertyWiseItems_New] 1,10,'',0,0,0,-999,-999,-999,2
   --[dbo].[SP_Search_SelectPropertyWiseItems_New] 1,10,'BEV/ACB/WNE/00217',0,0,0,-999,-999,-999,5
   --[dbo].[SP_Search_SelectPropertyWiseItems_New] 1,10,'FOD/NFF/OIL/00033',0,0,0,-999,-999,-999,5
   --[dbo].[SP_Search_SelectPropertyWiseItems_New] 1,10,'',0,0,0,-999,-999,-999,5
 --go
CREATE PROCEDURE [dbo].[SP_Search_SelectPropertyWiseItems_New] 
	(@from INT,
	@to INT,
	@search VARCHAR(20),
	@sortType INT,
	@sortColumn INT,
	@totalRecordCount INT OUTPUT,
	@CatergoryID INT,
	@SubcatergoryID INT,
	@SubCategory2ID INT,
	@CompanyId INT)
AS 
BEGIN
SET NOCOUNT ON;

SET @search = LTRIM(RTRIM(@search))

		IF(@search IS NULL OR @search = '')
		BEGIN 
				
			DECLARE @AllItemDetails TABLE (
				NAME VARCHAR(1000),
				Id int,
				StockItemCode VARCHAR(300),
				IsHave BIT,
				Disable BIT,
				IsChecked BIT
			)

			SELECT DISTINCT
					H.Name, 
					H.Id, 
					H.StockItemCode,
					1 AS IsHave,
					1 AS disable,
					1 AS IsChecked INTO #TempCompanyItems

			FROM StockItemHeaders AS H 	
			inner join StockItemDetails D on D.StockItemHeaderID= H.Id
			WHERE H.CategoryID = (CASE WHEN (@catergoryID = -999) THEN H.CategoryID ELSE @catergoryID END) 
				AND H.SubCategoryID = (CASE WHEN (@subcatergoryID = -999) THEN H.SubCategoryID ELSE @subcatergoryID END) 
				AND H.SubCategory2ID = (CASE WHEN (@SubCategory2ID = -999) THEN H.SubCategory2ID ELSE @SubCategory2ID END)
				AND H.CompanyId = @CompanyId
				AND D.IsActive =1

			SELECT DISTINCT  
					H.Name,
					H.Id,
					H.StockItemCode,
					0 AS IsHave,
					0 AS disable,
					0 AS IsChecked INTO #TempAllItems  
				 
				FROM StockItemHeaders AS H 	
				inner join StockItemDetails D on D.StockItemHeaderID= H.Id
				WHERE H.CategoryID = (CASE WHEN(@catergoryID = -999) THEN H.CategoryID ELSE @catergoryID END)  AND 
					H.SubCategoryID = (CASE WHEN(@subcatergoryID = -999) THEN H.SubCategoryID ELSE @subcatergoryID END) 
					AND H.SubCategory2ID = (CASE WHEN(@SubCategory2ID = -999) THEN H.SubCategory2ID ELSE @SubCategory2ID END)
					AND D.IsActive =1

			INSERT INTO @AllItemDetails (Name,Id,StockItemCode,IsHave,disable,IsChecked)
				SELECT 
					tc.Name,
					tc.Id,
					tc.StockItemCode,
					tc.IsHave,
					tc.disable,
					tc.IsChecked
				FROM #TempCompanyItems as tc 
			UNION
				SELECT 
					ta.Name,
					ta.Id,
					ta.StockItemCode,
					ta.IsHave,
					ta.disable,
					ta.IsChecked
					FROM #TempAllItems as ta
					WHERE ta.StockItemCode NOT IN (SELECT StockItemCode FROM  #TempCompanyItems);

			
				SELECT 
					Name,
					Id,
					StockItemCode,
					IsHave,
					disable,
					IsChecked,
					--ROW_NUMBER() OVER (ORDER BY Id ASC) AS RowNum
					ROW_NUMBER() OVER (PARTITION BY StockItemCode ORDER BY Id ASC) AS RowNumTemp 
					INTO #TEMPTABLE
				FROM @AllItemDetails

			SELECT 
				Name,
				Id,
				RowNumTemp,
				StockItemCode,
				IsHave,
				disable,
				IsChecked,
				ROW_NUMBER() OVER (ORDER BY disable,Id ASC) AS RowNum
				into #TEMPTABLE2
			FROM #TEMPTABLE
			WHERE 
			--RowNumTemp BETWEEN @from AND @to and
			RowNumTemp =1
			ORDER BY Id ASC;

			select * from
			#TEMPTABLE2 where RowNum BETWEEN @from AND @to  order by disable,RowNum

			SELECT @totalRecordCount = COUNT(*)FROM #TEMPTABLE2

			DROP TABLE #TempCompanyItems;
			DROP TABLE #TempAllItems;
			DROP TABLE #TEMPTABLE;
			Delete from @AllItemDetails
			drop table #TEMPTABLE2

		END
	ELSE
		BEGIN
			--start--

				DECLARE @AllItemDetails2 TABLE (
					NAME VARCHAR(1000),
					Id int, 
					StockItemCode VARCHAR(300),
					IsHave BIT,
					Disable BIT,
					IsChecked BIT
				)

				SELECT DISTINCT H.Name, 
						H.Id, 
						H.StockItemCode,
						1 AS IsHave,
						1 AS disable,
						1 AS IsChecked INTO #TempCompanyItems2
				FROM StockItemHeaders AS H 	
				inner join StockItemDetails D on D.StockItemHeaderID= H.Id
				WHERE ((H.Name + H.StockItemCode LIKE 
					(CASE WHEN @Search IS NULL THEN H.Name + H.StockItemCode ELSE '%'+ @search +'%' END)
				) )  	AND
				H.CategoryID = (CASE WHEN (@catergoryID = -999) THEN H.CategoryID ELSE @catergoryID END) 
					AND H.SubCategoryID = (CASE WHEN (@subcatergoryID = -999) THEN H.SubCategoryID ELSE @subcatergoryID END) 
					AND H.SubCategory2ID = (CASE WHEN (@SubCategory2ID = -999) THEN H.SubCategory2ID ELSE @SubCategory2ID END)
					AND H.CompanyId = @CompanyId
					AND D.IsActive =1
				
				SELECT DISTINCT H.Name,
						H.Id, 
						H.StockItemCode,
						0 AS IsHave,
						0 AS disable,
						0 AS IsChecked INTO #TempAllItems2
				FROM StockItemHeaders AS H 	
				inner join StockItemDetails D on D.StockItemHeaderID= H.Id
				WHERE ((H.Name + H.StockItemCode LIKE 
					(CASE WHEN @Search IS NULL THEN H.Name + H.StockItemCode ELSE '%'+ @search +'%' END)
				)) 
					AND H.CategoryID = (CASE WHEN (@catergoryID = -999) THEN H.CategoryID ELSE @catergoryID END) 
					AND H.SubCategoryID = (CASE WHEN (@subcatergoryID = -999) THEN H.SubCategoryID ELSE @subcatergoryID END) 
					AND H.SubCategory2ID = (CASE WHEN (@SubCategory2ID = -999) THEN H.SubCategory2ID ELSE @SubCategory2ID END)
					AND D.IsActive =1

				INSERT INTO @AllItemDetails2 (Name,Id,StockItemCode,IsHave,disable,IsChecked)
				SELECT 
					tc2.Name,
					tc2.Id,
					tc2.StockItemCode,
					tc2.IsHave,
					tc2.disable,
					tc2.IsChecked
				FROM #TempCompanyItems2 as tc2
				UNION
				SELECT 
					ta2.Name,
					ta2.Id,
					ta2.StockItemCode,
					ta2.IsHave,
					ta2.disable,
					ta2.IsChecked
				FROM #TempAllItems2 as ta2
				WHERE StockItemCode NOT IN (SELECT StockItemCode FROM  #TempCompanyItems2);


				
					SELECT 
						Name,
						Id,
						StockItemCode,
						IsHave,
						disable,
						IsChecked,
						ROW_NUMBER() OVER (PARTITION BY StockItemCode ORDER BY Id ASC) AS RowNumTemp 
						into #TEMPTABLE3
					FROM @AllItemDetails2

				SELECT 
					Name,
					Id,
					RowNumTemp,
					StockItemCode,
					IsHave,
					disable,
					IsChecked,
					ROW_NUMBER() OVER (ORDER BY disable,Id ASC) AS RowNum
					into #TEMPTABLE33
				FROM #TEMPTABLE3
				WHERE RowNumTemp =1
				ORDER BY Id ASC;

				select * from
			#TEMPTABLE33 where RowNum BETWEEN @from AND @to  order by disable,RowNum

				SELECT @totalRecordCount = COUNT(*)FROM #TEMPTABLE33

				DROP TABLE #TempCompanyItems2;
				DROP TABLE #TempAllItems2;
				DELETE FROM @AllItemDetails2;
				DROP TABLE #TEMPTABLE3;
				DROP TABLE #TEMPTABLE33;
			--end--
		END
END

GO

