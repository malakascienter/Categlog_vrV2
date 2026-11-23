CREATE PROCEDURE [dbo].[SP_Search_Filter_Employee]

@from INT,
	@to INT,
	@search VARCHAR(20),
	@sortType INT,
	@sortColumn INT,
	@totalRecordCount INT OUTPUT,
	@status INT OUTPUT, 
	@message VARCHAR(20) OUTPUT,
	@CompanyID INT
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
			SELECT @totalRecordCount = COUNT(*) FROM dbo.Employees WHERE (CompanyID = @CompanyID)
	
			SELECT InvDets.*, D.Name AS DepartmentName FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY Code ASC)) AS RowNum FROM dbo.Employees  WHERE ((Id LIKE '%' + @search + '%' OR  Code LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%') AND (CompanyID = @CompanyID) )) 
			AS InvDets
			INNER JOIN dbo.Departments AS D ON InvDets.DepartmentID = d.Id             
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY InvDets.Code ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM Employees WHERE ((Employees.Id LIKE '%' + @search + '%' OR Employees.Code LIKE '%' + @search + '%' OR Employees.Name LIKE '%' + @search + '%') AND (CompanyID = @CompanyID) )

		SELECT InvDets.*, D.Name AS DepartmentName FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Code ASC
		)) AS RowNum FROM Employees 
				WHERE (id LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%' OR Code LIKE '%' + @search + '%') AND (CompanyID = @CompanyID) )
				AS InvDets 
					INNER JOIN dbo.Departments AS D ON InvDets.DepartmentID = d.Id     
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Code ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM Employees
	
			SELECT InvDets.*, D.Name AS DepartmentName FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
			
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Code 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Title
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name END
					) DESC,					
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Name
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Name
					WHEN @sortColumn = 2 AND @sortType = 0 THEN code END) ASC

			)) AS RowNum FROM Employees  WHERE ((Id LIKE '%' + @search + '%' OR Code LIKE '%' + @search + '%' OR name LIKE '%' + @search + '%' ) AND (CompanyID = @CompanyID )) )
			AS InvDets
			INNER JOIN dbo.Departments AS D ON InvDets.DepartmentID = d.Id     
			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 					
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.Code 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN InvDets.Title
					WHEN @sortColumn = 2 AND @sortType = 1 THEN InvDets.Name END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.Code 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN InvDets.Title
					WHEN @sortColumn = 2 AND @sortType = 0 THEN InvDets.Name END
					) ASC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM Employees WHERE ((Employees.id LIKE '%' + @search + '%' OR Employees.Code LIKE '%' + @search + '%' OR Employees.Name LIKE '%' + @search + '%') AND (CompanyID = @CompanyID ) )

		SELECT InvDets.*, D.Name AS DepartmentName FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 		
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Code 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Title
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name END
					) DESC,					
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Code 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Title
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name END
					) ASC
		
		)) AS RowNum FROM Employees 
				WHERE ( id LIKE '%' + @search + '%' OR Code LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%') AND (CompanyID = @CompanyID ) )
				AS InvDets 
					INNER JOIN dbo.Departments AS D ON InvDets.DepartmentID = d.Id     
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 					
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.Code 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN InvDets.Title
					WHEN @sortColumn = 2 AND @sortType = 1 THEN InvDets.Name END
					) DESC,					
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.Code 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN InvDets.Title
					WHEN @sortColumn = 2 AND @sortType = 0 THEN InvDets.Name END
					) ASC
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

