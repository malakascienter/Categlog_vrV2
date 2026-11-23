CREATE PROCEDURE [dbo].[SP_Search_Banks]

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
			SELECT @totalRecordCount = COUNT(*) FROM dbo.Banks
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY ID ASC)) AS RowNum FROM Banks  WHERE (id LIKE '%' + @search + '%' OR Bank_Name LIKE '%' + @search + '%' OR Bank_Code LIKE '%' + @search + '%') ) 
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY Id ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM dbo.Banks WHERE (dbo.Banks.id LIKE '%' + @search + '%' OR Bank_Code LIKE '%' + @search + '%' OR Bank_Name LIKE '%' + @search + '%') 

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Id ASC
		)) AS RowNum FROM dbo.Banks 
				WHERE Id LIKE '%' + @search + '%' OR Bank_Name LIKE '%' + @search + '%' OR Bank_Code LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Id ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM dbo.Banks
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Bank_Name
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Bank_Code END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Bank_Name
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Bank_Code END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC

			)) AS RowNum FROM dbo.Banks  WHERE (id LIKE '%' + @search + '%' OR Bank_Name LIKE '%' + @search + '%' OR Bank_Code LIKE '%' + @search + '%') ) 
			AS InvDets

			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN InvDets.Bank_Name
					WHEN @sortColumn = 1 AND @sortType = 1 THEN InvDets.Bank_Code END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN InvDets.Bank_Name
					WHEN @sortColumn = 1 AND @sortType = 0 THEN InvDets.Bank_Code END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM dbo.Banks WHERE (dbo.Banks.Id LIKE '%' + @search + '%' OR Bank_Name LIKE '%' + @search + '%' OR Bank_Code LIKE '%' + @search + '%') 

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Bank_Name
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Bank_Code END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Bank_Name
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Bank_Code END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC
		
		)) AS RowNum FROM dbo.Banks 
				WHERE id LIKE '%' + @search + '%' OR Bank_Code LIKE '%' + @search + '%' OR Bank_Name LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
		(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN InvDets.Bank_Name
					WHEN @sortColumn = 1 AND @sortType = 1 THEN InvDets.Bank_Code END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN InvDets.Bank_Name
					WHEN @sortColumn = 1 AND @sortType = 0 THEN InvDets.Bank_Code END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC
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

