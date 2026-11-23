CREATE PROCEDURE [dbo].[SP_Search_SupplierPaymentAgreements]

@from INT,
	@to INT,
	@search VARCHAR(20),
	@sortType INT,
	@sortColumn INT,
	@totalRecordCount INT OUTPUT,
	@status INT OUTPUT, 
	@message VARCHAR(20) OUTPUT
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
			SELECT @totalRecordCount = COUNT(*) FROM SupplierPaymentAgreements
	
			SELECT InvDets.*, p.Name AS PayMethodName FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY Description ASC)) AS RowNum FROM dbo.SupplierPaymentAgreements  WHERE ( Description LIKE '%' + @search + '%' OR  AdvanceRatio LIKE '%' + @search + '%' OR Creditperiod LIKE '%' + @search + '%') ) 
			AS InvDets
			INNER JOIN dbo.PaymentTerms AS p ON InvDets.PayMethodID = p.Id 
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY InvDets.Description ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM SupplierPaymentAgreements WHERE (Description LIKE '%' + @search + '%' OR  AdvanceRatio LIKE '%' + @search + '%' OR Creditperiod LIKE '%' + @search + '%') 

		SELECT InvDets.*, p.Name AS PayMethodName FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Description ASC
		)) AS RowNum FROM SupplierPaymentAgreements 
				WHERE Description LIKE '%' + @search + '%' OR  AdvanceRatio LIKE '%' + @search + '%' OR Creditperiod LIKE '%' + @search + '%') 
				AS InvDets 
					INNER JOIN dbo.PaymentTerms AS p ON InvDets.PayMethodID = p.Id 
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Description ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM SupplierPaymentAgreements
	
			SELECT  InvDets.*, p.Name AS PayMethodName FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Creditperiod
					WHEN @sortColumn = 2 AND @sortType = 0 THEN AdvanceRatio END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Description END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Creditperiod
					WHEN @sortColumn = 2 AND @sortType = 1 THEN AdvanceRatio END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Description END) DESC

			)) AS RowNum FROM SupplierPaymentAgreements  WHERE (Description LIKE '%' + @search + '%' OR  AdvanceRatio LIKE '%' + @search + '%' OR Creditperiod LIKE '%' + @search + '%' )) 
			AS InvDets
			INNER JOIN dbo.PaymentTerms AS p ON InvDets.PayMethodID = p.Id 
			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE  
					WHEN @sortColumn = 1 AND @sortType = 0 THEN InvDets.Creditperiod
					WHEN @sortColumn = 2 AND @sortType = 0 THEN InvDets.AdvanceRatio END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.Description END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Creditperiod
					WHEN @sortColumn = 2 AND @sortType = 1 THEN AdvanceRatio END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.Description END) DESC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM SupplierPaymentAgreements WHERE (Description LIKE '%' + @search + '%' OR  AdvanceRatio LIKE '%' + @search + '%' OR Creditperiod LIKE '%' + @search + '%') 

		SELECT InvDets.* , p.Name AS PayMethodName FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Creditperiod
					WHEN @sortColumn = 2 AND @sortType = 0 THEN AdvanceRatio END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Description END) ASC,
					(CASE  
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Creditperiod
					WHEN @sortColumn = 2 AND @sortType = 1 THEN AdvanceRatio END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Description END) DESC
		
		)) AS RowNum FROM SupplierPaymentAgreements 
				WHERE Description LIKE '%' + @search + '%' OR  AdvanceRatio LIKE '%' + @search + '%' OR Creditperiod LIKE '%' + @search + '%') 
				AS InvDets 
					INNER JOIN dbo.PaymentTerms AS p ON InvDets.PayMethodID = p.Id 
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE  
					WHEN @sortColumn = 1 AND @sortType = 0 THEN Creditperiod
					WHEN @sortColumn = 2 AND @sortType = 0 THEN AdvanceRatio END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.Description END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Creditperiod
					WHEN @sortColumn = 2 AND @sortType = 1 THEN AdvanceRatio END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.Description END) DESC
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

