CREATE PROCEDURE [dbo].[SP_Search_CategoriesWithoutFilter]

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
			SELECT @totalRecordCount = COUNT(*) FROM Categories 
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY ID ASC)) AS RowNum FROM dbo.Categories  WHERE ((Code LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%')  )) 
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY Id ASC 
		END

	ELSE
        BEGIN
		SELECT @totalRecordCount = COUNT(*) FROM Categories WHERE ((Categories.Code LIKE '%' + @search + '%' OR Categories.Name LIKE '%' + @search + '%')) 

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Id ASC
		)) AS RowNum FROM Categories 
				WHERE Name LIKE '%' + @search + '%' OR Code LIKE '%' + @search + '%' ) 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Id ASC

		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM Categories 
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id  END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN code END) ASC

			)) AS RowNum FROM Categories  WHERE ((Code LIKE '%' + @search + '%' OR name LIKE '%' + @search + '%' ) ))
			AS InvDets

			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id  END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN code END) ASC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM Categories WHERE ((Categories.Code LIKE '%' + @search + '%' OR Categories.Name LIKE '%' + @search + '%')) 

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id  END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN code END) ASC
		
		)) AS RowNum FROM Categories 
				WHERE (Code LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%') )
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN id  END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN code END) ASC
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

--DECLARE @fromSIH INT, @ToSIH INT,@supname VARCHAR(255),@Search1 VARCHAR(255)
--SET @fromSIH = NULL
--SET @ToSIH = 4
--SET @supname =NULL
--SET @Search1=NULL

--SELECT InvDets.Name, InvDets.StockItemCode, InvDets.SupplyName, InvDets.CostPrice, InvDets.AveragePrice, InvDets.SIH
--		FROM ( SELECT  S.Name AS SupplyName , H.CategoryID, H.SubCategoryID, H.Name, H.StockItemCode, H.SupplierID, D.CostPrice, D.AveragePrice, D.SIH, D.LocationID, D.CompanyID, H.Id 
--			,  (ROW_NUMBER() OVER(ORDER BY H.Id ASC
--		)) AS RowNum FROM dbo.StockItemHeaders  AS H
--				INNER JOIN dbo.StockItemDetails AS D ON H.Id = D.StockItemHeaderID 		
--				INNER JOIN dbo.Suppliers AS S ON H.SupplierID = S.ID		
--				WHERE (((H.Name =
				
				
--				 (CASE WHEN @Search1 IS NULL THEN H.Name ELSE @Search1 END)
				
				
--				) )  
--				AND (H.CategoryID = 1) AND (H.SubCategoryID = 1) AND ((S.Name=
				
				
--				 (CASE WHEN @supname IS NULL THEN S.Name ELSE @supname END)
				
				
--				) ) AND (
--				D.SIH BETWEEN (CASE WHEN @fromSIH IS NULL THEN D.SIH ELSE @fromSIH END) AND (CASE WHEN @ToSIH IS NULL THEN D.SIH ELSE @ToSIH END)   				
--				)))
--			AS InvDets
					
--					WHERE InvDets.RowNum BETWEEN 1 AND 3 
--					ORDER BY InvDets.Id ASC

GO

