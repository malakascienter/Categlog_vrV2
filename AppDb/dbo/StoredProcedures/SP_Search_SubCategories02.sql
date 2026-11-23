-- [dbo].[SP_Search_SubCategories02] 1,10,'',1,0,0,0,''

CREATE PROCEDURE [dbo].[SP_Search_SubCategories02]

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

DECLARE @IsCategoryLevels BIT

SELECT TOP(1) @IsCategoryLevels= IsCategoryLevels FROM Companies 
ORDER BY IsCategoryLevels DESC


SET @search = LTRIM(RTRIM(@search))

IF(@IsCategoryLevels = 1)

BEGIN
	IF(@sortColumn = 0 AND @sortType = 0)
	BEGIN
		IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) 
			FROM SubCategories02 
		INNER JOIN SubCategories SUB ON SUB.ID = SubCategories02.SubCategoryId

			SELECT InvDets.*, SUB.Name AS SubCategoryName,C.Name CategoryName FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY ID ASC)) AS RowNum FROM dbo.SubCategories02  WHERE (Code LIKE '%' + @search + '%' OR Description LIKE '%' + @search + '%') ) 
			AS InvDets
			INNER JOIN dbo.Categories AS C ON C.Id = InvDets.CategoryId   
		INNER JOIN SubCategories SUB ON SUB.ID = InvDets.SubCategoryId
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY InvDets.Id ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM SubCategories02 WHERE (SubCategories02.Code LIKE '%' + @search + '%' OR SubCategories02.Description LIKE '%' + @search + '%') 

		SELECT InvDets.*, SUB.Name AS SubCategoryName,C.Name CategoryName
		 FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Id ASC
		)) AS RowNum FROM SubCategories02 
				WHERE Description LIKE '%' + @search + '%' OR Code LIKE '%' + @search + '%') 
				AS InvDets 
					INNER JOIN dbo.Categories AS C ON C.Id = InvDets.CategoryId
				INNER JOIN SubCategories SUB ON SUB.ID = InvDets.SubCategoryId
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Id ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM SubCategories02
	
			SELECT InvDets.*,SUB.Name AS SubCategoryName,C.Name CategoryName FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Description 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Description
					WHEN @sortColumn = 1 AND @sortType = 0 THEN code END) ASC

			)) AS RowNum FROM SubCategories02  WHERE (Code LIKE '%' + @search + '%' OR Description LIKE '%' + @search + '%' )) 
			AS InvDets
			INNER JOIN dbo.Categories AS C ON C.Id = InvDets.CategoryId
		INNER JOIN SubCategories SUB ON SUB.ID = InvDets.SubCategoryId
			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN InvDets.Description 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN InvDets.Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN InvDets.Description 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN InvDets.code END) ASC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM SubCategories02 WHERE (SubCategories02.Code LIKE '%' + @search + '%' OR SubCategories02.Description LIKE '%' + @search + '%') 

		SELECT InvDets.*, SUB.Name AS SubCategoryName,C.Name CategoryName FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Description 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Description
					WHEN @sortColumn = 1 AND @sortType = 0 THEN code END) ASC
		
		)) AS RowNum FROM SubCategories02 
				WHERE Code LIKE '%' + @search + '%' OR Description LIKE '%' + @search + '%') 
				AS InvDets 
					INNER JOIN dbo.Categories AS C ON C.Id = InvDets.CategoryId
			INNER JOIN SubCategories SUB ON SUB.ID = InvDets.SubCategoryId
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN InvDets.Description 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN InvDets.Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN InvDets.Description 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN InvDets.code END) ASC
		END 

		END 
END
ELSE
BEGIN
	IF(@sortColumn = 0 AND @sortType = 0)
	BEGIN
		IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) 
			FROM SubCategories02
	
			SELECT InvDets.*, '' AS SubCategoryName FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY ID ASC)) AS RowNum FROM dbo.SubCategories02  WHERE (Code LIKE '%' + @search + '%' OR Description LIKE '%' + @search + '%') ) 
			AS InvDets
		--	INNER JOIN dbo.Categories AS C ON C.Id = InvDets.CategoryId             
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY InvDets.Id ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM SubCategories02 WHERE (SubCategories02.Code LIKE '%' + @search + '%' OR SubCategories02.Description LIKE '%' + @search + '%') 

		SELECT InvDets.*
		 FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Id ASC
		)) AS RowNum FROM SubCategories02 
				WHERE Description LIKE '%' + @search + '%' OR Code LIKE '%' + @search + '%') 
				AS InvDets 
				--	INNER JOIN dbo.Categories AS C ON C.Id = InvDets.CategoryId
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Id ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM SubCategories02
	
			SELECT InvDets.* FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Description 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Description
					WHEN @sortColumn = 1 AND @sortType = 0 THEN code END) ASC

			)) AS RowNum FROM SubCategories02  WHERE (Code LIKE '%' + @search + '%' OR Description LIKE '%' + @search + '%' )) 
			AS InvDets
		--	INNER JOIN dbo.Categories AS C ON C.Id = InvDets.CategoryId
			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN InvDets.Description 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN InvDets.Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN InvDets.Description 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN InvDets.code END) ASC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM SubCategories02 WHERE (SubCategories02.Code LIKE '%' + @search + '%' OR SubCategories02.Description LIKE '%' + @search + '%') 

		SELECT InvDets.*, '' AS SubCategoryName FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Description 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Description
					WHEN @sortColumn = 1 AND @sortType = 0 THEN code END) ASC
		
		)) AS RowNum FROM SubCategories02 
				WHERE Code LIKE '%' + @search + '%' OR Description LIKE '%' + @search + '%') 
				AS InvDets 
			--		INNER JOIN dbo.Categories AS C ON C.Id = InvDets.CategoryId
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN InvDets.Description 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN InvDets.Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN InvDets.Description 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN InvDets.code END) ASC
		END 

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

