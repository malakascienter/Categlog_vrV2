CREATE PROCEDURE [dbo].[SP_GetPropertyWiseUsers]
@from INT,
	@to INT, 
	@search VARCHAR(20),
	@sortType INT,
	@sortColumn INT, 
	@totalRecordCount INT OUTPUT,
	@status INT OUTPUT, 
	@message VARCHAR(20) OUTPUT,
	@CompanyId INT
AS 
DECLARE @statusIN[INT]
	SET @statusIN = 0;
	SET  @message = ''


BEGIN
BEGIN TRY
BEGIN TRANSACTION
	SELECT DISTINCT U.Id AS id, U.UserName AS text INTO #TempUsers
	FROM UserWiseCompanies UC
	INNER JOIN UserMasters U ON U.Id = UC.UserId
	WHERE UC.CompnayId = CASE WHEN @CompanyId = -999 THEN UC.CompnayId ELSE @CompanyId END

	IF(@sortColumn = 0 AND @sortType = 0)
	BEGIN
		IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM #TempUsers 
	
			SELECT * 
			FROM( 
			SELECT H.text, H.Id
			, (ROW_NUMBER() OVER(ORDER BY H.Id ASC)) AS RowNum
			FROM #TempUsers  AS H
				)
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to  
			ORDER BY InvDets.Id ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM #TempUsers AS H 
		WHERE (( H.text LIKE '%' + @search + '%' ) )

		SELECT *
		FROM ( SELECT H.text,H.Id
			,  (ROW_NUMBER() OVER(ORDER BY H.Id ASC
		)) AS RowNum
			FROM #TempUsers  AS H				
				WHERE (((H.text  LIKE 
					(CASE WHEN @Search IS NULL THEN H.text ELSE '%'+ @search +'%' END)
				) )  
			))
			AS InvDets
			WHERE InvDets.RowNum BETWEEN @from AND @to 
			ORDER BY InvDets.Id ASC


		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM #TempUsers AS H 	
	
			SELECT *
		FROM ( SELECT H.text
			, (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN H.id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN H.Name END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN H.id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN H.Name END) ASC

			)) AS RowNum 
			FROM dbo.#TempUsers  AS H					
				WHERE (((H.text  LIKE	
				
				
				 (CASE WHEN @Search IS NULL THEN H.text  ELSE '%'+@search+'%' END)
				
				) )  ))
			AS InvDets
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN text END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN text  END) ASC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM #TempUsers H WHERE ((H.id LIKE '%' + @search + '%' 
	 OR H.text LIKE '%' + @search + '%'  ) )

		SELECT *
		FROM ( SELECT H.text
		 , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN H.id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN H.text  END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN H.id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN H.text END) ASC
		
		)) AS RowNum 
			FROM dbo.#TempUsers  AS H					
				WHERE (((H.text  LIKE 
				
				
				 (CASE WHEN @Search IS NULL THEN H.text  ELSE '%' +@search +'%' END)
				
				
				) )  
				))
			AS InvDets
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN text  END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN text  END) ASC
		END 

		END 
COMMIT TRAN
	SET @status = @statusIN;
END TRY
BEGIN CATCH
	SET @status = -1;
	SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))	
END CATCH
END

GO

