--select * from SalesPersons
CREATE PROCEDURE [dbo].[SP_Search_SalesPersons]

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
            save transaction SP_Search_SalesPerson;








SET @search = LTRIM(RTRIM(@search))

	IF(@sortColumn = 0 AND @sortType = 0)
	BEGIN
		IF(@search IS NULL OR @search = '')   
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM SalesPersons
	
			SELECT * FROM( SELECT Id,SalesPersonCode,SalesPersonName,Address1,ReferenceNo,Email,Telephone, (ROW_NUMBER() OVER(ORDER BY Id ASC)) AS RowNum FROM dbo.SalesPersons AS SP  WHERE (Id LIKE '%' + @search + '%' OR  SalesPersonCode LIKE '%' + @search + '%' OR SalesPersonName LIKE '%' + @search + '%'OR ReferenceNo LIKE '%' + @search + '%'OR Address1 LIKE '%' + @search + '%' OR Address2 LIKE '%' + @search + '%'OR Address3 LIKE '%' + @search + '%'OR Email LIKE '%' + @search + '%'OR Telephone LIKE '%' + @search + '%'OR Mobile LIKE '%' + @search + '%'OR Telephone LIKE '%' + @search + '%') ) 
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY Id ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM SalesPersons  WHERE (Id LIKE '%' + @search + '%' OR  SalesPersonCode LIKE '%' + @search + '%' OR SalesPersonName LIKE '%' + @search + '%'OR ReferenceNo LIKE '%' + @search + '%'OR Address1 LIKE '%' + @search + '%' OR Address2 LIKE '%' + @search + '%'OR Address3 LIKE '%' + @search + '%'OR Email LIKE '%' + @search + '%'OR Telephone LIKE '%' + @search + '%'OR Mobile LIKE '%' + @search + '%'OR Telephone LIKE '%' + @search + '%') 

		SELECT * FROM ( SELECT Id,SalesPersonCode,SalesPersonName,Address1,ReferenceNo,Email,Telephone, (ROW_NUMBER() OVER(ORDER BY Id ASC
		)) AS RowNum FROM SalesPersons 
				WHERE Id LIKE '%' + @search + '%' OR  SalesPersonCode LIKE '%' + @search + '%' OR SalesPersonName LIKE '%' + @search + '%'OR ReferenceNo LIKE '%' + @search + '%'OR Address1 LIKE '%' + @search + '%' OR Address2 LIKE '%' + @search + '%'OR Address3 LIKE '%' + @search + '%'OR Email LIKE '%' + @search + '%'OR Telephone LIKE '%' + @search + '%'OR Mobile LIKE '%' + @search + '%'OR Telephone LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Id ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM SalesPersons 
			--select 1/0
			SELECT  * FROM( SELECT Id,SalesPersonCode,SalesPersonName,Address1,ReferenceNo,Email,Telephone, (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN SalesPersonCode
					WHEN @sortColumn = 3 AND @sortType = 1 THEN ReferenceNo 
					WHEN @sortColumn = 4 AND @sortType = 1 THEN Address1 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN SalesPersonName END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN SalesPersonCode
					WHEN @sortColumn = 3 AND @sortType = 0 THEN ReferenceNo 
					WHEN @sortColumn = 4 AND @sortType = 0 THEN Address1 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN SalesPersonName END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC

			)) AS RowNum FROM SalesPersons  WHERE (Id LIKE '%' + @search + '%' OR  SalesPersonCode LIKE '%' + @search + '%' OR SalesPersonName LIKE '%' + @search + '%'OR ReferenceNo LIKE '%' + @search + '%'OR Address1 LIKE '%' + @search + '%' OR Address2 LIKE '%' + @search + '%'OR Address3 LIKE '%' + @search + '%'OR Email LIKE '%' + @search + '%'OR Telephone LIKE '%' + @search + '%'OR Mobile LIKE '%' + @search + '%'OR Telephone LIKE '%' + @search + '%')) 
			AS InvDets

			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN SalesPersonCode
					WHEN @sortColumn = 3 AND @sortType = 1 THEN ReferenceNo 
					WHEN @sortColumn = 4 AND @sortType = 1 THEN Address1 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN SalesPersonName END) DESC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END ) DESC,

					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN SalesPersonCode
					WHEN @sortColumn = 3 AND @sortType = 0 THEN ReferenceNo 
					WHEN @sortColumn = 4 AND @sortType = 0 THEN Address1 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN SalesPersonName END) ASC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC
		END

ELSE
        BEGIN
		--select 1/0
		SELECT @totalRecordCount = COUNT(*) FROM SalesPersons  WHERE (Id LIKE '%' + @search + '%' OR  SalesPersonCode LIKE '%' + @search + '%' OR SalesPersonName LIKE '%' + @search + '%'OR ReferenceNo LIKE '%' + @search + '%'OR Address1 LIKE '%' + @search + '%' OR Address2 LIKE '%' + @search + '%'OR Address3 LIKE '%' + @search + '%'OR Email LIKE '%' + @search + '%'OR Telephone LIKE '%' + @search + '%'OR Mobile LIKE '%' + @search + '%'OR Telephone LIKE '%' + @search + '%') 

		SELECT * FROM ( SELECT Id,SalesPersonCode,SalesPersonName,Address1,ReferenceNo,Email,Telephone, (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN SalesPersonCode
					WHEN @sortColumn = 3 AND @sortType = 1 THEN ReferenceNo 
					WHEN @sortColumn = 4 AND @sortType = 1 THEN Address1 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN SalesPersonName END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN SalesPersonCode
					WHEN @sortColumn = 3 AND @sortType = 0 THEN ReferenceNo 
					WHEN @sortColumn = 4 AND @sortType = 0 THEN Address1 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN SalesPersonName END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC

			)) AS RowNum FROM SalesPersons 
				WHERE Id LIKE '%' + @search + '%' OR  SalesPersonCode LIKE '%' + @search + '%' OR SalesPersonName LIKE '%' + @search + '%'OR ReferenceNo LIKE '%' + @search + '%'OR Address1 LIKE '%' + @search + '%' OR Address2 LIKE '%' + @search + '%'OR Address3 LIKE '%' + @search + '%'OR Email LIKE '%' + @search + '%'OR Telephone LIKE '%' + @search + '%'OR Mobile LIKE '%' + @search + '%'OR Telephone LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN SalesPersonCode
					WHEN @sortColumn = 3 AND @sortType = 1 THEN ReferenceNo 
					WHEN @sortColumn = 4 AND @sortType = 1 THEN Address1 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN SalesPersonName END) DESC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END ) DESC,

					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN SalesPersonCode
					WHEN @sortColumn = 3 AND @sortType = 0 THEN ReferenceNo 
					WHEN @sortColumn = 4 AND @sortType = 0 THEN Address1 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN SalesPersonName END) ASC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC
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

        raiserror ('SP_Search_SalesPersons: %d: %s', 16, 1, @error, @message) ;
END CATCH;
END

GO

