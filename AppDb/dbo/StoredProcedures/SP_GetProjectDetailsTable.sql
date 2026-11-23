--SP_GetProjectDetailsTable 1,10,'',0,0,0,1,'',0
CREATE PROCEDURE [dbo].[SP_GetProjectDetailsTable] 

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
			SELECT @totalRecordCount = COUNT(*) FROM ProjectDetails p INNER JOIN dbo.Clients c ON  c.Id = p.ClientID WHERE  (p.ClientID LIKE '%' +   CASE WHEN @filterId = 0 THEN '' ELSE CONVERT(varchar(10), @filterId) end + '%'  ) 
	
			SELECT InvDets.Id, InvDets.ClientName,InvDets.ProjectCode,InvDets.ProjectName,CONVERT(VARCHAR(10),InvDets.PlanEndDate,103) AS PlanEndDate, CONVERT(VARCHAR(10),InvDets.ActualEndDate,103) AS ActualEndDate,InvDets.ProjectStatus
			FROM( SELECT p.id, c.CustomerName AS 'ClientName', p.ProjectCode , p.ProjectName, p.PlannedEndingDate AS 'PlanEndDate', p.ActualEndingDate AS 'ActualEndDate', p.Projecstatus AS 'ProjectStatus' , (ROW_NUMBER() OVER(ORDER BY p.Id ASC)) AS RowNum 			
			FROM dbo.ProjectDetails  p
			INNER JOIN dbo.Customers c ON  c.Id = p.ClientID
			WHERE ((p.Id LIKE '%' + @search + '%' OR c.CustomerName LIKE '%' + @search + '%' OR  p.ProjectName LIKE '%' + @search + '%' OR p.ProjectCode LIKE '%' + @search + '%') AND (p.ClientID LIKE '%' +   CASE WHEN @filterId = 0 THEN '' ELSE CONVERT(varchar(10), @filterId) end + '%' ) ) 
			) AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY InvDets.RowNum ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM ProjectDetails p INNER JOIN dbo.Customers c ON  c.Id = p.ClientID WHERE ((p.Id LIKE '%' + @search + '%' OR c.CustomerName LIKE '%' + @search + '%' OR  p.ProjectName LIKE '%' + @search + '%' OR p.ProjectCode LIKE '%' + @search + '%') AND (p.ClientID LIKE '%' +   CASE WHEN @filterId = 0 THEN '' ELSE CONVERT(varchar(10), @filterId) end + '%' ) )  

		SELECT InvDets.Id, InvDets.ClientName,InvDets.ProjectCode,InvDets.ProjectName,InvDets.PlanEndDate, InvDets.ActualEndDate,InvDets.ProjectStatus
			FROM (  SELECT p.id, c.CustomerName AS 'ClientName', p.ProjectCode , p.ProjectName, p.PlannedEndingDate AS 'PlanEndDate', p.ActualEndingDate AS 'ActualEndDate', 
			p.Projecstatus AS 'ProjectStatus' , (ROW_NUMBER() OVER(ORDER BY p.Id ASC)) AS RowNum 
			FROM dbo.ProjectDetails  p
			INNER JOIN dbo.Customers c ON  c.Id = p.ClientID 
				WHERE ((p.Id LIKE '%' + @search + '%' OR c.CustomerName LIKE '%' + @search + '%' OR  p.ProjectName LIKE '%' + @search + '%' OR p.ProjectCode LIKE '%' + @search + '%') AND (p.ClientID LIKE '%' +   CASE WHEN @filterId = 0 THEN '' ELSE CONVERT(varchar(10), @filterId) end + '%' )) 
			) AS InvDets
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.RowNum ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM ProjectDetails p INNER JOIN dbo.Clients c ON  c.Id = p.ClientID WHERE ((p.ClientID LIKE '%' +   CASE WHEN @filterId = 0 THEN '' ELSE CONVERT(varchar(10), @filterId) end + '%' ))
	
			SELECT InvDets.Id, InvDets.ClientName,InvDets.ProjectCode,InvDets.ProjectName,InvDets.PlanEndDate, InvDets.ActualEndDate,InvDets.ProjectStatus 
			FROM( SELECT p.id, c.CustomerName AS 'ClientName', p.ProjectCode , p.ProjectName, p.PlannedEndingDate AS 'PlanEndDate', p.ActualEndingDate AS 'ActualEndDate', 
			p.Projecstatus AS 'ProjectStatus' , (ROW_NUMBER() OVER(ORDER BY 
					(CASE
					WHEN @sortColumn = 0 AND @sortType = 1 THEN c.CustomerName 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN p.ProjectCode
					WHEN @sortColumn = 2 AND @sortType = 1 THEN p.ProjectName
					END
					) DESC,					
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN c.CustomerName
					WHEN @sortColumn = 1 AND @sortType = 0 THEN p.ProjectCode
					WHEN @sortColumn = 2 AND @sortType = 0 THEN p.ProjectName END) ASC

			)) AS RowNum FROM dbo.ProjectDetails  p
			INNER JOIN dbo.Customers c ON  c.Id = p.ClientID
			WHERE ((p.Id LIKE '%' + @search + '%' OR c.CustomerName LIKE '%' + @search + '%' OR  p.ProjectName LIKE '%' + @search + '%' OR p.ProjectCode LIKE '%' + @search + '%') AND (p.ClientID LIKE '%' +   CASE WHEN @filterId = 0 THEN '' ELSE CONVERT(varchar(10), @filterId) end + '%' )) 
			) AS InvDets

			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.ClientName 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN InvDets.ProjectCode
					WHEN @sortColumn = 2 AND @sortType = 1 THEN InvDets.ProjectName
					END
					) DESC,					
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.ClientName 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN InvDets.ProjectCode
					WHEN @sortColumn = 2 AND @sortType = 0 THEN InvDets.ProjectName END) ASC
					end

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM ProjectDetails p INNER JOIN dbo.Customers c ON  c.Id = p.ClientID WHERE ((p.Id LIKE '%' + @search + '%' OR c.CustomerName LIKE '%' + @search + '%' OR  p.ProjectName LIKE '%' + @search + '%' OR p.ProjectCode LIKE '%' + @search + '%') AND (p.ClientID LIKE '%' +   CASE WHEN @filterId = 0 THEN '' ELSE CONVERT(varchar(10), @filterId) end + '%' )) 

		SELECT InvDets.id, InvDets.ClientName,InvDets.ProjectCode,InvDets.ProjectName,InvDets.PlanEndDate, InvDets.ActualEndDate,InvDets.ProjectStatus 
			FROM( SELECT p.id, c.CustomerName AS 'ClientName', p.ProjectCode , p.ProjectName, p.PlannedEndingDate AS 'PlanEndDate', p.ActualEndingDate AS 'ActualEndDate', 
			p.Projecstatus AS 'ProjectStatus' , (ROW_NUMBER() OVER(ORDER BY 
					(CASE
					WHEN @sortColumn = 0 AND @sortType = 1 THEN c.CustomerName 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN p.ProjectCode
					WHEN @sortColumn = 2 AND @sortType = 1 THEN p.ProjectName
					END
					) DESC,					
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN c.CustomerName
					WHEN @sortColumn = 1 AND @sortType = 0 THEN p.ProjectCode
					WHEN @sortColumn = 2 AND @sortType = 0 THEN p.ProjectName END) ASC

			)) AS RowNum FROM dbo.ProjectDetails  p
			INNER JOIN dbo.Customers c ON  c.Id = p.ClientID
			WHERE ((p.Id LIKE '%' + @search + '%' OR c.CustomerName LIKE '%' + @search + '%' OR  p.ProjectName LIKE '%' + @search + '%' OR p.ProjectCode LIKE '%' + @search + '%') AND (p.ClientID LIKE '%' +   CASE WHEN @filterId = 0 THEN '' ELSE CONVERT(varchar(10), @filterId) end + '%' ) ) 
			) AS InvDets

			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.ClientName 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN InvDets.ProjectCode
					WHEN @sortColumn = 2 AND @sortType = 1 THEN InvDets.ProjectName
					END
					) DESC,					
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.ClientName 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN InvDets.ProjectCode
					WHEN @sortColumn = 2 AND @sortType = 0 THEN InvDets.ProjectName END) ASC
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

