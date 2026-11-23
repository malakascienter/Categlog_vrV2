CREATE PROCEDURE [dbo].[SP_Search_BankBranches]

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
			SELECT @totalRecordCount = COUNT(*) FROM dbo.BankBranches BB inner join dbo.Banks B ON B.Id = BB.BankID 
	
			SELECT * FROM( SELECT BB.*,B.Bank_Name , (ROW_NUMBER() OVER(ORDER BY BB.ID ASC)) AS RowNum FROM BankBranches BB INNER JOIN dbo.Banks B ON B.Id=BB.BankID WHERE (BB.Id LIKE '%' + @search + '%' OR Branch_Code LIKE '%' + @search + '%' OR BB.Branch_Name LIKE '%' + @search + '%' OR B.Bank_Name LIKE '%' + @search + '%') ) 
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY Id ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM dbo.BankBranches BB INNER JOIN dbo.Banks B ON B.Id=BB.BankID WHERE (BB.Id LIKE '%' + @search + '%' OR Branch_Code LIKE '%' + @search + '%' OR Branch_Name LIKE '%' + @search + '%' OR B.Bank_Name LIKE '%' + @search + '%') 

		SELECT * FROM ( SELECT BB.*,B.Bank_Name , (ROW_NUMBER() OVER(ORDER BY BB.Id ASC
		)) AS RowNum FROM dbo.BankBranches BB INNER JOIN dbo.Banks B ON B.Id=BB.BankID
				WHERE BB.Id LIKE '%' + @search + '%' OR Branch_Code LIKE '%' + @search + '%' OR BB.Branch_Name LIKE '%' + @search + '%' OR B.Bank_Name LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Id ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM dbo.BankBranches BB inner join dbo.Banks B ON B.Id = BB.BankID 
	
			SELECT * FROM( SELECT BB.*,B.Bank_Name, (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Branch_Code
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Branch_Code END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN BB.Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Branch_Code
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Branch_Code END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN BB.Id END) ASC

			)) AS RowNum FROM dbo.BankBranches BB INNER JOIN dbo.Banks B ON B.Id=BB.BankID WHERE (BB.id LIKE '%' + @search + '%' OR Branch_Code LIKE '%' + @search + '%' OR BB.Branch_Name LIKE '%' + @search + '%' OR B.Bank_Name LIKE '%' + @search + '%') ) 
			AS InvDets

			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN InvDets.Branch_Code
					WHEN @sortColumn = 1 AND @sortType = 1 THEN InvDets.Branch_Code END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN InvDets.Branch_Code
					WHEN @sortColumn = 1 AND @sortType = 0 THEN InvDets.Branch_Code END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM dbo.BankBranches BB INNER JOIN dbo.Banks B ON B.Id=BB.BankID WHERE (BB.Id LIKE '%' + @search + '%' OR Branch_Code LIKE '%' + @search + '%' OR Branch_Name LIKE '%' + @search + '%' OR B.Bank_Name LIKE '%' + @search + '%') 

		SELECT * FROM ( SELECT BB.*,B.Bank_Name , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Branch_Code
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Branch_Code END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN BB.Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Branch_Code
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Branch_Code END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN BB.Id END) ASC
		
		)) AS RowNum FROM dbo.BankBranches BB INNER JOIN dbo.Banks B ON B.Id=BB.BankID
				WHERE BB.id LIKE '%' + @search + '%' OR Branch_Code LIKE '%' + @search + '%' OR BB.Branch_Name LIKE '%' + @search + '%' OR B.Bank_Name LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
		(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN InvDets.Branch_Code
					WHEN @sortColumn = 1 AND @sortType = 1 THEN InvDets.Branch_Code END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN InvDets.Branch_Code
					WHEN @sortColumn = 1 AND @sortType = 0 THEN InvDets.Branch_Code END) ASC,
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

