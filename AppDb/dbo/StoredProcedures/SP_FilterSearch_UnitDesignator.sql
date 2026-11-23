CREATE PROCEDURE [dbo].[SP_FilterSearch_UnitDesignator]

	@from INT,
	@to INT,
	@search VARCHAR(20),
	@sortType INT,
	@sortColumn INT,
	@totalRecordCount INT OUTPUT,
	@status INT OUTPUT, 
	@message VARCHAR(20) OUTPUT,
	@filterId INT
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
			SELECT @totalRecordCount = COUNT(*) FROM UnitDesignators WHERE CompanyID = @filterId 
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY ID ASC)) AS RowNum FROM dbo.UnitDesignators  WHERE (( Name LIKE '%' + @search + '%' OR Rate LIKE '%' + @search + '%'  ) and (CompanyId = @filterId)) )
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY Id ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM UnitDesignators WHERE ((UnitDesignators.Name LIKE '%' + @search + '%' OR UnitDesignators.Rate LIKE '%' + @search + '%' ) AND (CompanyId = @filterId) )

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Id ASC
		)) AS RowNum FROM UnitDesignators 
				WHERE (Name LIKE '%' + @search + '%' OR Rate LIKE '%' + @search + '%' ) AND (CompanyId = @filterId))
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Id ASC
		END 
	END

	ELSE
	BEGIN
	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM UnitDesignators
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
			        (CASE WHEN @sortColumn = 2 AND @sortType = 1 THEN Rate END) DESC,
					(CASE WHEN  @sortColumn = 1 AND @sortType = 1 THEN  Name END)DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id
					WHEN @sortColumn = 3 AND @sortType = 1 THEN UnitID END
					) DESC,
					(CASE WHEN @sortColumn = 2 AND @sortType = 0 THEN Rate END) ASC,
					(CASE WHEN  @sortColumn = 1 AND @sortType = 0 THEN  Name END)ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id
					WHEN @sortColumn = 3 AND @sortType = 0 THEN UnitID END) ASC

			)) AS RowNum FROM UnitDesignators  WHERE ((Name LIKE '%' + @search + '%' OR Rate LIKE '%' + @search + '%' ) AND (CompanyId = @filterId) ) )
			AS InvDets

			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE WHEN @sortColumn = 2 AND @sortType = 1 THEN Rate END) DESC,
				(CASE WHEN  @sortColumn = 1 AND @sortType = 1 THEN  Name END)DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id
					WHEN @sortColumn = 3 AND @sortType = 1 THEN UnitID END
					) DESC,
					(CASE WHEN @sortColumn = 2 AND @sortType = 0 THEN Rate END) ASC,
					(CASE WHEN  @sortColumn = 1 AND @sortType = 0 THEN  Name END)ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id
					WHEN @sortColumn = 3 AND @sortType = 0 THEN UnitID END) ASC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM UnitDesignators WHERE ((UnitDesignators.Name LIKE '%' + @search + '%' OR UnitDesignators.Rate LIKE '%' + @search + '%' ) AND (CompanyId = @filterId) )

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
		            (CASE WHEN @sortColumn = 2 AND @sortType = 1 THEN Rate END) DESC,
					(CASE WHEN  @sortColumn = 1 AND @sortType = 1 THEN  Name END)DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id
					WHEN @sortColumn = 3 AND @sortType = 1 THEN UnitID END
					) DESC,
					(CASE WHEN @sortColumn = 2 AND @sortType = 0 THEN Rate END) ASC,
					(CASE WHEN  @sortColumn = 1 AND @sortType = 0 THEN  Name END)ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id
					WHEN @sortColumn = 3 AND @sortType = 0 THEN UnitID END) ASC
		
		)) AS RowNum FROM UnitDesignators 
				WHERE ( Name LIKE '%' + @search + '%' OR Rate LIKE '%' + @search + '%' ) AND (CompanyId = @filterId) )
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE WHEN @sortColumn = 2 AND @sortType = 1 THEN Rate END) DESC,
					(CASE WHEN  @sortColumn = 1 AND @sortType = 1 THEN  Name END)DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id
					WHEN @sortColumn = 3 AND @sortType = 1 THEN UnitID END
					) DESC,
					(CASE WHEN @sortColumn = 2 AND @sortType = 0 THEN Rate END) ASC,
				    (CASE WHEN  @sortColumn = 1 AND @sortType = 0 THEN  Name END)ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id
					WHEN @sortColumn = 3 AND @sortType = 0 THEN UnitID END) ASC
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

