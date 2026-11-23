CREATE PROCEDURE [dbo].[SP_Search_ApprovalTypes]

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
			SELECT @totalRecordCount = COUNT(*) FROM ApprovalTypes
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY ID ASC)) AS RowNum FROM ApprovalTypes  WHERE (ApprovalTypeName LIKE '%' + @search + '%' OR ApprovalTypeCode LIKE '%' + @search + '%') ) 
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY Id ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM ApprovalTypes WHERE (ApprovalTypes.ApprovalTypeCode LIKE '%' + @search + '%' OR ApprovalTypes.ApprovalTypeName LIKE '%' + @search + '%') 

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Id ASC
		)) AS RowNum FROM ApprovalTypes 
				WHERE ApprovalTypeName LIKE '%' + @search + '%' OR ApprovalTypeCode LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Id ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM ApprovalTypes
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN ApprovalTypeName
					WHEN @sortColumn = 1 AND @sortType = 1 THEN ApprovalTypeCode END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN ApprovalTypeName
					WHEN @sortColumn = 1 AND @sortType = 0 THEN ApprovalTypeCode END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC

			)) AS RowNum FROM ApprovalTypes  WHERE (ApprovalTypeName LIKE '%' + @search + '%' OR ApprovalTypeCode LIKE '%' + @search + '%') ) 
			AS InvDets

			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN ApprovalTypeName
					WHEN @sortColumn = 1 AND @sortType = 1 THEN ApprovalTypeCode END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN ApprovalTypeName
					WHEN @sortColumn = 1 AND @sortType = 0 THEN ApprovalTypeCode END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM ApprovalTypes WHERE (ApprovalTypes.ApprovalTypeName LIKE '%' + @search + '%' OR ApprovalTypes.ApprovalTypeCode LIKE '%' + @search + '%') 

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN ApprovalTypeName
					WHEN @sortColumn = 1 AND @sortType = 1 THEN ApprovalTypeCode END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN ApprovalTypeName
					WHEN @sortColumn = 1 AND @sortType = 0 THEN ApprovalTypeCode END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC
		
		)) AS RowNum FROM ApprovalTypes 
				WHERE ApprovalTypeCode LIKE '%' + @search + '%' OR ApprovalTypeName LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
		(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN ApprovalTypeName
					WHEN @sortColumn = 1 AND @sortType = 1 THEN ApprovalTypeCode END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN ApprovalTypeName
					WHEN @sortColumn = 1 AND @sortType = 0 THEN ApprovalTypeCode END) ASC,
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

