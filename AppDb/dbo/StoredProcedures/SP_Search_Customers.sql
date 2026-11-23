
CREATE PROCEDURE [dbo].[SP_Search_Customers]
	-- Add the parameters for the stored procedure here

	@from INT,
	@to INT,
	@search VARCHAR(20),
	@sortType INT,
	@sortColumn INT,
	@totalRecordCount INT OUTPUT,
	@status INT OUTPUT, 
	@message VARCHAR(20) OUTPUT
	--@filterId INT 


AS
DECLARE @statusIN[int]
	SET @statusIN = 0;
	SET  @message = ''

BEGIN
BEGIN TRY
BEGIN TRANSACTION
	SET @search = LTRIM(RTRIM(@search))
	
	--IF OBJECT_ID('xxx', 'U') IS NOT NULL 
	--DROP TABLE xxx

	IF(@sortColumn = 0 AND @sortType = 0)
	BEGIN
		IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM Customers
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY ID ASC)) AS RowNum FROM Customers  WHERE (CustomerName LIKE '%' + @search + '%' OR AddLine1 LIKE '%' + @search + '%' OR Id LIKE '%' + @search + '%' OR Tele1 LIKE '%' + @search + '%') ) 
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY Id ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM Customers WHERE (Customers.CustomerName LIKE '%' + @search + '%' OR Customers.AddLine1 LIKE '%' + @search + '%' OR Customers.Id LIKE '%' + @search + '%' OR Customers.Tele1 LIKE '%' + @search + '%') 

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Id ASC
		)) AS RowNum FROM Customers 
				WHERE CustomerName LIKE '%' + @search + '%' OR AddLine1 LIKE '%' + @search + '%' OR Id LIKE '%' + @search + '%' OR Tele1 LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Id ASC
		END 
	END

	ELSE  -- if not  (@sortColumn = 0 AND @sortType = 0)
	BEGIN  

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM Customers
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN CustomerName
					WHEN @sortColumn = 3 AND @sortType = 1 THEN AddLine1 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Tele1 END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN CustomerName
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Tele1
					WHEN @sortColumn = 3 AND @sortType = 0 THEN AddLine1 END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC

			)) AS RowNum FROM Customers  WHERE (CustomerName LIKE '%' + @search + '%' OR AddLine1 LIKE '%' + @search + '%' OR Id LIKE '%' + @search + '%' OR Tele1 LIKE '%' + @search + '%') ) 
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY 
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN CustomerName
					WHEN @sortColumn = 3 AND @sortType = 1 THEN AddLine1 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Tele1 END) DESC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END ) DESC,

					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN CustomerName
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Tele1
					WHEN @sortColumn = 3 AND @sortType = 0 THEN AddLine1 END) ASC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC
		END

ELSE
        BEGIN
		PRINT('ok')
		SELECT @totalRecordCount = COUNT(*) FROM Customers WHERE (Customers.CustomerName LIKE '%' + @search + '%' OR Customers.AddLine1 LIKE '%' + @search + '%' OR Customers.Id LIKE '%' + @search + '%' OR Customers.Tele1 LIKE '%' + @search + '%') 

		SELECT *  FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN CustomerName
					WHEN @sortColumn = 3 AND @sortType = 1 THEN AddLine1 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Tele1 END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN CustomerName
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Tele1
					WHEN @sortColumn = 3 AND @sortType = 0 THEN AddLine1 END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC
		
		)) AS RowNum  FROM Customers 
				WHERE CustomerName LIKE '%' + @search + '%' OR AddLine1 LIKE '%' + @search + '%' OR Id LIKE '%' + @search + '%' OR Tele1 LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
		(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN CustomerName
					WHEN @sortColumn = 3 AND @sortType = 1 THEN AddLine1 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Tele1 END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN CustomerName
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Tele1
					WHEN @sortColumn = 3 AND @sortType = 0 THEN AddLine1 END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC
		END 

		END -- end of else
	--SELECT * FROM xxx
	COMMIT TRAN -- Transaction Success!
	
	SET @status = @statusIN;
END TRY 
BEGIN CATCH
	SET @status = -1;
	SET @message = CAST(ERROR_NUMBER() AS VARCHAR(150)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(150))	
	ROLLBACK TRAN --RollBack in case of Error
END CATCH;
END

GO

