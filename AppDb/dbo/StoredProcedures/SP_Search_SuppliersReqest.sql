CREATE  PROCEDURE [dbo].[SP_Search_SuppliersReqest]

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


			SELECT @totalRecordCount = COUNT(*) FROM SuppliersRequest WHERE PropertyID = @filterId
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY ID ASC)) AS RowNum FROM dbo.SuppliersRequest  WHERE ((Address1 LIKE '%' + @search + '%'  OR Name LIKE '%' + @search + '%' OR Email LIKE '%' + @search + '%' OR Telephone1 LIKE '%' + @search + '%' OR VatNo LIKE '%' + @search + '%') AND (PropertyID = @filterId)  )) 
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to  and IsApprove = 0
			ORDER BY Id ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM SuppliersRequest WHERE ((SuppliersRequest.Address1 LIKE '%' + @search + '%'  OR SuppliersRequest.Name LIKE '%' + @search + '%' OR SuppliersRequest.Email LIKE '%' + @search + '%' OR SuppliersRequest.Telephone1 LIKE '%' + @search + '%' OR SuppliersRequest.VatNo LIKE '%' + @search + '%') AND (PropertyID = @filterId) )

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Id ASC
		)) AS RowNum FROM SuppliersRequest 
				WHERE (Address1 LIKE '%' + @search + '%'  OR Name LIKE '%' + @search + '%' OR Email LIKE '%' + @search + '%' OR Telephone1 LIKE '%' + @search + '%' OR VatNo LIKE '%' + @search + '%' ) AND (PropertyID = @filterId)  )
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to  and IsApprove = 0
					ORDER BY InvDets.Id ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM SuppliersRequest

	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Name  END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Name END) ASC

			)) AS RowNum FROM SuppliersRequest  WHERE ((Address1 LIKE '%' + @search + '%'  OR Name LIKE '%' + @search + '%' OR Email LIKE '%' + @search + '%' OR Telephone1 LIKE '%' + @search + '%' OR VatNo LIKE '%' + @search + '%' ) AND (PropertyID = @filterId) AND   IsApprove = 0 ) )
			AS InvDets

			WHERE RowNum BETWEEN @from AND @to  and IsApprove = 0  AND (PropertyID = @filterId)
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Name END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Name  END) ASC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM SuppliersRequest WHERE ((SuppliersRequest.Address1 LIKE '%' + @search + '%'  OR SuppliersRequest.Name LIKE '%' + @search + '%' OR SuppliersRequest.Email LIKE '%' + @search + '%' OR SuppliersRequest.Telephone1 LIKE '%' + @search + '%' OR SuppliersRequest.VatNo LIKE '%' + @search + '%') AND (PropertyID = @filterId) )
		
		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Name  END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Name  END) ASC
		
		)) AS RowNum FROM SuppliersRequest 
				WHERE ( Address1 LIKE '%' + @search + '%'  OR Name LIKE '%' + @search + '%' OR Email LIKE '%' + @search + '%' OR Telephone1 LIKE '%' + @search + '%' OR VatNo LIKE '%' + @search + '%') AND (PropertyID = @filterId)  and IsApprove = 0)  
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to  AND (PropertyID = @filterId)  and IsApprove = 0
					ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Name END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Name  END) ASC
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

