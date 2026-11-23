CREATE PROCEDURE [dbo].[SP_Search_CustomerSignatureAdvanced]

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
			SELECT @totalRecordCount = COUNT(*) FROM dbo.CustomerSignatures
	
			SELECT InvDets.*, c.CustomerName AS CustomerName FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY CustomerPerson ASC)) AS RowNum FROM dbo.CustomerSignatures  WHERE ( ImageFileName LIKE '%' + @search + '%' OR  CustomerPerson LIKE '%' + @search + '%' OR ImageFileFullPath LIKE '%' + @search + '%') ) 
			AS InvDets
			INNER JOIN dbo.Customers AS c ON InvDets.CustomerId = c.Id 
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY InvDets.CustomerPerson ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM dbo.CustomerSignatures WHERE (CustomerId LIKE '%' + @search + '%' OR  CustomerPerson LIKE '%' + @search + '%' OR ImageFileFullPath LIKE '%' + @search + '%') 

		SELECT InvDets.*, c.CustomerName AS CustomerName FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY CustomerPerson ASC
		)) AS RowNum FROM dbo.CustomerSignatures 
				WHERE CustomerPerson LIKE '%' + @search + '%' OR  CustomerId LIKE '%' + @search + '%' OR ImageFileFullPath LIKE '%' + @search + '%') 
				AS InvDets 
					INNER JOIN dbo.Customers AS c ON InvDets.CustomerId = c.Id 
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.CustomerPerson ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM dbo.CustomerSignatures
	
			SELECT  InvDets.*, c.CustomerName AS CustomerName FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN CustomerPerson
					WHEN @sortColumn = 2 AND @sortType = 0 THEN ImageFileFullPath END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN CustomerId END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN CustomerPerson
					WHEN @sortColumn = 2 AND @sortType = 1 THEN ImageFileFullPath END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN CustomerId END) DESC

			)) AS RowNum FROM dbo.CustomerSignatures  WHERE (CustomerPerson LIKE '%' + @search + '%' OR  ImageFileFullPath LIKE '%' + @search + '%' OR CustomerId LIKE '%' + @search + '%' )) 
			AS InvDets
			INNER JOIN dbo.Customers AS c ON InvDets.CustomerId = c.Id 
			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE  
					WHEN @sortColumn = 1 AND @sortType = 0 THEN InvDets.CustomerPerson
					WHEN @sortColumn = 2 AND @sortType = 0 THEN InvDets.ImageFileFullPath END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.CustomerId END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN CustomerPerson
					WHEN @sortColumn = 2 AND @sortType = 1 THEN ImageFileFullPath END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.CustomerId END) DESC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM dbo.CustomerSignatures WHERE (CustomerPerson LIKE '%' + @search + '%' OR  ImageFileFullPath LIKE '%' + @search + '%' OR CustomerId LIKE '%' + @search + '%') 

		SELECT  CustomerName AS CustomerName FROM (  SELECT cs.CustomerId, cs.CustomerPerson, cs.ImageFileFullPath, c.CustomerName, (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN ImageFileFullPath
					WHEN @sortColumn = 2 AND @sortType = 0 THEN CustomerPerson END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN CustomerId END) ASC,
					(CASE  
					WHEN @sortColumn = 1 AND @sortType = 1 THEN ImageFileFullPath
					WHEN @sortColumn = 2 AND @sortType = 1 THEN CustomerPerson END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN CustomerId END) DESC
		
		)) AS RowNum FROM dbo.CustomerSignatures cs
		INNER JOIN dbo.Customers AS c ON cs.CustomerId = c.Id 
				WHERE CustomerPerson LIKE '%' + @search + '%' OR  ImageFileFullPath LIKE '%' + @search + '%' OR c.CustomerName LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE  
					WHEN @sortColumn = 1 AND @sortType = 0 THEN ImageFileFullPath
					WHEN @sortColumn = 2 AND @sortType = 0 THEN CustomerPerson END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.CustomerId END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN ImageFileFullPath
					WHEN @sortColumn = 2 AND @sortType = 1 THEN CustomerPerson END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.CustomerPerson END) DESC
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

