CREATE PROCEDURE [dbo].[SP_Search_CurrencyMasters]

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
			SELECT @totalRecordCount = COUNT(*) FROM CurrencyMasters
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY ID ASC)) AS RowNum FROM dbo.CurrencyMasters  WHERE (Name LIKE '%' + @search + '%' OR ExchangeRate LIKE '%' + @search + '%' OR Symbol LIKE '%'+ @search +'%') ) 
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY Id ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM CurrencyMasters WHERE (CurrencyMasters.ExchangeRate LIKE '%' + @search + '%' OR CurrencyMasters.Name LIKE '%' + @search + '%' OR Symbol LIKE '%'+ @search +'%') 

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Id ASC
		)) AS RowNum FROM CurrencyMasters 
				WHERE Name LIKE '%' + @search + '%' OR ExchangeRate LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Id ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM CurrencyMasters
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN ExchangeRate END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name
					WHEN @sortColumn = 3 AND @sortType = 1 THEN Symbol
					 END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id
					WHEN @sortColumn = 1 AND @sortType = 0 THEN ExchangeRate END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name
					WHEN @sortColumn = 3 AND @sortType = 0 THEN Symbol
					 END) ASC

			)) AS RowNum FROM CurrencyMasters  WHERE (ExchangeRate LIKE '%' + @search + '%' OR name LIKE '%' + @search + '%' OR Symbol LIKE '%'+ @search +'%' )) 
			AS InvDets

			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN ExchangeRate END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name
					WHEN @sortColumn = 3 AND @sortType = 1 THEN Symbol
					 END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id
					WHEN @sortColumn = 1 AND @sortType = 0 THEN ExchangeRate END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name 
					WHEN @sortColumn = 3 AND @sortType = 0 THEN Symbol
					
					END) ASC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM CurrencyMasters WHERE (CurrencyMasters.ExchangeRate LIKE '%' + @search + '%' OR CurrencyMasters.Name LIKE '%' + @search + '%' OR Symbol LIKE '%'+ @search +'%') 

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN ExchangeRate END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name
					WHEN @sortColumn = 3 AND @sortType = 1 THEN Symbol
					 END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id
					WHEN @sortColumn = 1 AND @sortType = 0 THEN ExchangeRate END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name 
					WHEN @sortColumn = 3 AND @sortType = 0 THEN Symbol
					END) ASC
		
		)) AS RowNum FROM CurrencyMasters 
				WHERE ExchangeRate LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%' OR Symbol LIKE '%'+ @search +'%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN ExchangeRate END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name 
					WHEN @sortColumn = 3 AND @sortType = 1 THEN Symbol
					END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id
					WHEN @sortColumn = 1 AND @sortType = 0 THEN ExchangeRate END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name
					WHEN @sortColumn = 3 AND @sortType = 0 THEN Symbol
					 END) ASC
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

