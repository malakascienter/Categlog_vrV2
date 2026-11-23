
CREATE PROCEDURE [dbo].[SP_Search_RecipeHeaders]

	@from INT,
	@to INT,
	@search VARCHAR(20),
	@sortType INT,
	@sortColumn INT,
	@totalRecordCount INT OUTPUT,
	@status INT OUTPUT, 
	@message VARCHAR(20) OUTPUT,
	@filterId INT = 0
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
			SELECT @totalRecordCount = COUNT(*) FROM Inv_RecipeHeader 
	
			SELECT * FROM( SELECT IRH.*,U.Name UnitName , (ROW_NUMBER() OVER(ORDER BY IRH.ID ASC)) AS RowNum FROM Inv_RecipeHeader IRH
			LEFT JOIN Units U on U.Id = IRH.UnitId
			WHERE ((RecipeCode LIKE '%' + @search + '%' OR  RecipeName LIKE '%' + @search + '%' )) )
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY Id DESC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM Inv_RecipeHeader WHERE ((RecipeCode LIKE '%' + @search + '%' OR  RecipeName LIKE '%' + @search + '%' ) )

		SELECT * FROM ( SELECT IRH.*,U.Name UnitName , (ROW_NUMBER() OVER(ORDER BY IRH.Id ASC
		)) AS RowNum FROM Inv_RecipeHeader IRH
			LEFT JOIN Units U on U.Id = IRH.UnitId
				WHERE (RecipeCode LIKE '%' + @search + '%' OR  RecipeName LIKE '%' + @search + '%' ))
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Id DESC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			--SELECT @totalRecordCount = COUNT(*) FROM Locations
			SELECT @totalRecordCount = COUNT(*) FROM Inv_RecipeHeader 
	
			SELECT * FROM( SELECT IRH.*,U.Name UnitName , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN RecipeName END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN RecipeCode  END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN RecipeName END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN RecipeCode END) ASC

			)) AS RowNum FROM Inv_RecipeHeader IRH
			LEFT JOIN Units U on U.Id = IRH.UnitId  WHERE ((RecipeCode LIKE '%' + @search + '%' OR  RecipeName LIKE '%' + @search + '%' ) ))
			AS InvDets

			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY InvDets.Id DESC
					--(CASE 
					--WHEN @sortColumn = 0 AND @sortType = 1 THEN RecipeName END) DESC,
					--(CASE 
					--WHEN @sortColumn = 1 AND @sortType = 1 THEN RecipeCode  END
					--) DESC,
					--(CASE 
					--WHEN @sortColumn = 0 AND @sortType = 0 THEN RecipeName END) ASC,
					--(CASE 
					--WHEN @sortColumn = 1 AND @sortType = 0 THEN RecipeCode  END) ASC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM Inv_RecipeHeader WHERE ((RecipeCode LIKE '%' + @search + '%' OR  RecipeName LIKE '%' + @search + '%' ) )

		SELECT * FROM ( SELECT IRH.*,U.Name UnitName , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN RecipeName END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN RecipeCode END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN RecipeName END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN RecipeCode END) ASC
		
		)) AS RowNum FROM Inv_RecipeHeader IRH
			LEFT JOIN Units U on U.Id = IRH.UnitId
				WHERE ( RecipeCode LIKE '%' + @search + '%' OR  RecipeName LIKE '%' + @search + '%' ) )
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN RecipeName END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN RecipeCode  END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN RecipeName END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN RecipeCode  END) ASC
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

