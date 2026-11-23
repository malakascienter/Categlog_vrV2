CREATE PROCEDURE [dbo].[SP_Search_CreditApprovals]

@from INT,
	@to INT,
	@search VARCHAR(20),
	@sortType INT, -- 1
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
 set nocount on;
    declare @trancount int;
    set @trancount = @@trancount;
BEGIN TRY

   if @trancount = 0
            begin transaction
        else
            save transaction SP_Search_CreditApprovals;








SET @search = LTRIM(RTRIM(@search))

	IF(@sortColumn = 0 AND @sortType = 0)
	BEGIN
		IF(@search IS NULL OR @search = '')   
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM CreditApprovals
	
			SELECT * FROM( SELECT CA.Amount, CA.Id,CustomerName,IsApproved,CA.DocumentStatus,(ROW_NUMBER() OVER(ORDER BY CA.Id ASC)) AS RowNum FROM dbo.CreditApprovals AS CA inner join Customers on Customers.Id=CA.CustomerId   WHERE (CA.Id LIKE '%' + @search + '%' OR  CustomerName LIKE '%' + @search + '%' OR Amount LIKE '%' + @search + '%' ) ) 
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY Id ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM CreditApprovals as CA inner join Customers C on CA.CustomerId = c.Id  WHERE (CA.Id LIKE '%' + @search + '%' OR  C.CustomerName LIKE '%' + @search + '%' OR CA.Amount LIKE '%' + @search + '%') 

		SELECT * FROM ( SELECT CA.Amount, CA.Id,CustomerName,IsApproved,CA.DocumentStatus, (ROW_NUMBER() OVER(ORDER BY CA.Id ASC
		)) AS RowNum FROM CreditApprovals as CA inner join Customers C on CA.CustomerId = c.Id 
				WHERE CA.Id LIKE '%' + @search + '%' OR  C.CustomerName LIKE '%' + @search + '%' OR Amount LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Id ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM CreditApprovals as CA inner join Customers C on CA.CustomerId = c.Id
			--select 1/0
			SELECT  * FROM( SELECT CA.Amount, CA.Id,CustomerName,IsApproved,CA.DocumentStatus, (ROW_NUMBER() OVER(ORDER BY 
			--(CASE 
					--WHEN @sortColumn = 0 AND @sortType = 1 THEN CA.Id END)DESC,
					--WHEN @sortColumn = 1 AND @sortType = 1 THEN ExchangeRate END) DESC,
					(CASE 
					WHEN @sortColumn = 3 AND @sortType = 1 THEN Amount
					 END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN CustomerName END)DESC,
					--(CASE 
					--WHEN @sortColumn = 0 AND @sortType = 0 THEN CA.Id END)ASC,
					--WHEN @sortColumn = 1 AND @sortType = 0 THEN ExchangeRate END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN CustomerName
					 END) ASC,
					 (CASE 
					 WHEN @sortColumn = 2 AND @sortType = 0 THEN Amount END)ASC

			)) AS RowNum FROM CreditApprovals as CA inner join Customers C on CA.CustomerId = c.Id   WHERE (CA.Id LIKE '%' + @search + '%' OR  C.CustomerName LIKE '%' + @search + '%' OR CA.Amount LIKE '%' + @search + '%')) 
			AS InvDets

			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					--(CASE 
					--WHEN @sortColumn = 0 AND @sortType = 1 THEN Id 
					--WHEN @sortColumn = 1 AND @sortType = 1 THEN ExchangeRate END) DESC,
					--END)DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN CustomerName
					 END
					) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Amount END)DESC,
					--(CASE 
					--WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END)ASC,
					--WHEN @sortColumn = 1 AND @sortType = 0 THEN ExchangeRate END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN CustomerName END) ASC,		
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Amount END)ASC
		END

ELSE
        BEGIN
		--select 1/0
		SELECT @totalRecordCount = COUNT(*) FROM CreditApprovals AS CA,Customers AS C WHERE (CA.Id LIKE '%' + @search + '%' OR  C.CustomerName LIKE '%' + @search + '%' OR CA.Amount LIKE '%' + @search + '%') 

		SELECT * FROM ( SELECT CA.Amount, CA.Id,CustomerName,IsApproved,CA.DocumentStatus, (ROW_NUMBER() OVER(ORDER BY 
		--(CASE 
					--WHEN @sortColumn = 0 AND @sortType = 1 THEN CA.Id END),
					--WHEN @sortColumn = 1 AND @sortType = 1 THEN ExchangeRate END) DESC,
					(CASE 
					
					WHEN @sortColumn = 3 AND @sortType = 1 THEN Amount
					 END)DESC,
					 (CASE 					
					WHEN @sortColumn = 3 AND @sortType = 1 THEN CustomerName 
					 END)DESC,
					--(CASE 
					--WHEN @sortColumn = 0 AND @sortType = 0 THEN CA.id END)ASC,
					--WHEN @sortColumn = 1 AND @sortType = 0 THEN ExchangeRate END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Amount 
					END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN CustomerName END)ASC
		
		)) AS RowNum FROM CreditApprovals as CA inner join Customers C on CA.CustomerId = c.Id 
				WHERE CA.Id LIKE '%' + @search + '%' OR  C.CustomerName LIKE '%' + @search + '%' OR CA.Amount LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					--(CASE 
					--WHEN @sortColumn = 0 AND @sortType = 1 THEN id END)DESC,
					--WHEN @sortColumn = 1 AND @sortType = 1 THEN ExchangeRate END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Amount 
					END)DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN CustomerName  END)DESC,
					--(CASE 
					--WHEN @sortColumn = 0 AND @sortType = 0 THEN id END)ASC,
					--WHEN @sortColumn = 1 AND @sortType = 0 THEN ExchangeRate END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN CustomerName END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Amount END)ASC
		END 

		END 
		 if @trancount = 0
            commit;

	SET @status = @statusIN;
END TRY 
BEGIN CATCH
	SET @status = -1;
	SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))	

	declare @error int,  @xstate int;
        select @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();
        if @xstate = -1
            rollback;
        if @xstate = 1 and @trancount = 0
            rollback
        if @xstate = 1 and @trancount > 0
            rollback transaction SP_Search_CreditApprovals;

        raiserror ('SP_Search_CreditApprovals: %d: %s', 16, 1, @error, @message) ;
END CATCH;
END

GO

