CREATE PROCEDURE [dbo].[SP_Search_BrokerMasters]
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
			SELECT @totalRecordCount = COUNT(*) FROM BrokerMasters
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY ID ASC)) AS RowNum FROM dbo.BrokerMasters  WHERE (Id LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%' OR AddLine1 LIKE '%' + @search + '%' OR Email1 LIKE '%' + @search + '%') ) 
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY Id ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM BrokerMasters WHERE (BrokerMasters.Id LIKE '%' + @search + '%' OR BrokerMasters.Name LIKE '%' + @search + '%' OR BrokerMasters.AddLine1 LIKE '%' + @search + '%' OR BrokerMasters.Email1 LIKE '%' + @search + '%') 

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Id ASC
		)) AS RowNum FROM BrokerMasters 
				WHERE id LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%' OR Email1 LIKE '%' + @search + '%' OR AddLine1 LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Id ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM BrokerMasters
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(
			ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Name
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Email1
					WHEN @sortColumn = 3 AND @sortType = 1 THEN  AddLine1 END) ASC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Name
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Email1
					WHEN @sortColumn = 3 AND @sortType = 0 THEN AddLine1 END) DESC

			)) AS RowNum FROM BrokerMasters  WHERE (Id LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%' OR AddLine1 LIKE '%' + @search + '%' OR Email1 LIKE '%' + @search + '%' )) 
			AS InvDets

			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Name
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Email1
					WHEN @sortColumn = 3 AND @sortType = 1 THEN  AddLine1 END) ASC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Name
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Email1
					WHEN @sortColumn = 3 AND @sortType = 0 THEN AddLine1 END) DESC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM BrokerMasters WHERE (BrokerMasters.id LIKE '%' + @search + '%' OR BrokerMasters.Email1 LIKE '%' + @search + '%' OR BrokerMasters.Name LIKE '%' + @search + '%' OR BrokerMasters.AddLine1 LIKE '%' + @search + '%') 

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Name
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Email1
					WHEN @sortColumn = 3 AND @sortType = 1 THEN  AddLine1 END) ASC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Name
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Email1
					WHEN @sortColumn = 3 AND @sortType = 0 THEN AddLine1 END) DESC
		
		)) AS RowNum FROM BrokerMasters 
				WHERE (id LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%' OR AddLine1 LIKE '%' + @search + '%'  OR Email1 LIKE '%' + @search + '%') )
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Name
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Email1
					WHEN @sortColumn = 3 AND @sortType = 1 THEN AddLine1 END) ASC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Name
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Email1
					WHEN @sortColumn = 3 AND @sortType = 0 THEN AddLine1 END) DESC
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

