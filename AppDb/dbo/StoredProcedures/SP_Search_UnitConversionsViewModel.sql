CREATE PROCEDURE [dbo].[SP_Search_UnitConversionsViewModel]

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
			SELECT @totalRecordCount = COUNT(*) FROM UnitConversions WHERE LocationId = @filterId
	
			SELECT InvDets.CreatedDate AS CreatedDate, InvDets.Id, InvDets.FromUnitID, uf.Name AS fromUnitName, InvDets.ToUnitID,ut.Name AS ToUnitName, InvDets.Value, InvDets.IsActive FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY ID ASC)) AS RowNum FROM dbo.UnitConversions  WHERE ((Id LIKE '%' + @search + '%' OR Value  LIKE '%' + @search + '%') AND (LocationId = @filterId)) )
			AS InvDets
			INNER JOIN dbo.Units AS uf ON InvDets.FromUnitID = uf.Id
			INNER JOIN dbo.Units AS ut ON InvDets.ToUnitID = ut.Id
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY uf.Id ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM UnitConversions WHERE ((UnitConversions.Id LIKE '%' + @search + '%' OR UnitConversions.Value LIKE '%' + @search + '%') AND (LocationId = @filterId) )

		SELECT InvDets.CreatedDate AS CreatedDate, InvDets.Id, InvDets.FromUnitID, uf.Name AS fromUnitName, InvDets.ToUnitID,ut.Name AS ToUnitName, InvDets.Value, InvDets.IsActive FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Id ASC
		)) AS RowNum FROM UnitConversions 
				WHERE ( id LIKE '%' + @search + '%' OR Value LIKE '%' + @search + '%') AND (LocationId = @filterId) )
				AS InvDets 
				INNER JOIN dbo.Units AS uf ON InvDets.FromUnitID = uf.Id
				INNER JOIN dbo.Units AS ut ON InvDets.ToUnitID = ut.Id	
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Id ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM UnitConversions
	
			SELECT InvDets.CreatedDate AS CreatedDate, InvDets.Id, InvDets.FromUnitID, uf.Name AS fromUnitName, InvDets.ToUnitID,ut.Name AS ToUnitName, InvDets.Value, InvDets.IsActive FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Value END) ASC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Value END) DESC

			)) AS RowNum FROM UnitConversions  WHERE ((Id LIKE '%' + @search + '%' OR Value LIKE '%' + @search + '%') AND (LocationId = @filterId) ) )
			AS InvDets
			INNER JOIN dbo.Units AS uf ON InvDets.FromUnitID = uf.Id
			INNER JOIN dbo.Units AS ut ON InvDets.ToUnitID = ut.Id
			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.Id
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Value END) ASC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.Id
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Value END) DESC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM UnitConversions WHERE ((UnitConversions.id LIKE '%' + @search + '%' OR UnitConversions.Value LIKE '%' + @search + '%') AND (LocationId = @filterId) )

		SELECT InvDets.CreatedDate AS CreatedDate, InvDets.Id, InvDets.FromUnitID, uf.Name AS fromUnitName, InvDets.ToUnitID,ut.Name AS ToUnitName, InvDets.Value, InvDets.IsActive FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Value END) ASC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Value END) DESC
		
		)) AS RowNum FROM UnitConversions 
				WHERE (id LIKE '%' + @search + '%' OR Value LIKE '%' + @search + '%') AND (LocationId = @filterId) )
				AS InvDets 
				INNER JOIN dbo.Units AS uf ON InvDets.FromUnitID = uf.Id
				INNER JOIN dbo.Units AS ut ON InvDets.ToUnitID = ut.Id	
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.Id
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Value END) ASC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.Id
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Value END) DESC
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

