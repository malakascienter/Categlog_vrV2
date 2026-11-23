CREATE PROCEDURE [dbo].[SP_FilterSearch_Companies]

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
			SELECT @totalRecordCount = COUNT(*) FROM Companies WHERE GroupofcompanyID = @filterId
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY CompanyID ASC)) AS RowNum FROM dbo.Companies  WHERE (( CompanyID LIKE '%' + @search + '%' OR  Code LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%') AND (GroupofcompanyID = @filterId) ) )
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY CompanyID ASC 
		END
		
	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM Companies WHERE ( (Companies.CompanyID LIKE '%' + @search + '%' OR Companies.Code LIKE '%' + @search + '%' OR Companies.Name LIKE '%' + @search + '%') AND (GroupofcompanyID = @filterId))

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY CompanyID ASC
		)) AS RowNum FROM Companies 
				WHERE (CompanyID LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%' OR Code LIKE '%' + @search + '%') AND (GroupofcompanyID = @filterId))
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.CompanyID ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM Companies WHERE GroupofcompanyID = @filterId
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN CompanyID END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN CompanyID END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name
					WHEN @sortColumn = 1 AND @sortType = 0 THEN code END) ASC

			)) AS RowNum FROM Companies  WHERE ((CompanyID LIKE '%' + @search + '%' OR Code LIKE '%' + @search + '%' OR name LIKE '%' + @search + '%' ) AND (GroupofcompanyID = @filterId)) )
			AS InvDets

			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN CompanyID END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN CompanyID END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN code END) ASC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM Companies WHERE ((Companies.CompanyID LIKE '%' + @search + '%' OR Companies.Code LIKE '%' + @search + '%' OR Companies.Name LIKE '%' + @search + '%') AND (GroupofcompanyID = @filterId))

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN CompanyID END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN CompanyID END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name
					WHEN @sortColumn = 1 AND @sortType = 0 THEN code END) ASC
		
		)) AS RowNum FROM Companies 
				WHERE (CompanyID LIKE '%' + @search + '%' OR Code LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%') AND (GroupofcompanyID = @filterId))
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN CompanyID END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN CompanyID END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN code END) ASC
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

