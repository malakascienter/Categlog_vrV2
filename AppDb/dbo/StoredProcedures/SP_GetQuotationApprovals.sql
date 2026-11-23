CREATE PROCEDURE [dbo].[SP_GetQuotationApprovals]
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
	DROP TABLE mydata
SELECT @from F ,@to TOX ,
	@search search,
	@sortType sortType ,
	@sortColumn sortColumn,
	@totalRecordCount totalRecordCount,
	@status status, 
	@message message INTO mydata 
	
	SELECT QH.Id,S.Name AS SupplierName,QH.QuotationNo,QH.ValidFrom ,QH.Remarks,
	QH.ValidTo,QH.LeadTimeExpireDays AS LeadTimeExpire INTO #TempQuote
	FROM [dbo].[SupplierQuotationHeader] QH
	--INNER JOIN QuotationWiseProperties QWP ON QWP.QuotationHeaderId = QH.Id
	--INNER JOIN dbo.Companies C ON C.CompanyID = QWP.PropertyId
	INNER JOIN dbo.Suppliers S ON S.ID = QH.SupplierId
	WHERE QH.Status = 'P' AND QH.IsActive = 1


	SET @search = LTRIM(RTRIM(@search))

	IF(@sortColumn = 0 AND @sortType = 0)
	BEGIN
		IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM Companies 
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY Id ASC)) AS RowNum FROM #TempQuote 
			WHERE ( SupplierName LIKE '%' + @search + '%' OR QuotationNo LIKE '%' + @search + '%') )
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY Id ASC 
		END
		
	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM #TempQuote
		WHERE  (#TempQuote.SupplierName LIKE '%' + @search + '%'
		OR #TempQuote.QuotationNo LIKE '%' + @search + '%')

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Id ASC
		)) AS RowNum FROM #TempQuote 
				WHERE SupplierName LIKE '%' + @search + '%' OR QuotationNo LIKE '%' + @search + '%')
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Id ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM #TempQuote
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN SupplierName END
				
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN SupplierName END) ASC

			)) AS RowNum FROM #TempQuote  WHERE ( SupplierName LIKE '%' + @search + '%' OR QuotationNo LIKE '%' + @search + '%' ) )
			AS InvDets

			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN SupplierName END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN SupplierName END) ASC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM #TempQuote WHERE ( #TempQuote.SupplierName LIKE '%' + @search + '%' OR #TempQuote.QuotationNo LIKE '%' + @search + '%')

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN SupplierName END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN SupplierName END) ASC
		
		)) AS RowNum FROM #TempQuote
				WHERE  SupplierName LIKE '%' + @search + '%' OR QuotationNo LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN SupplierName END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN SupplierName END) ASC
		END 
		SET @status=1

		END 
		COMMIT TRAN -- Transaction Success!
	SET @status = @statusIN;
END TRY 
BEGIN CATCH
	  SELECT  
            ERROR_NUMBER() AS ErrorNumber  
            ,ERROR_SEVERITY() AS ErrorSeverity  
            ,ERROR_STATE() AS ErrorState  
            ,ERROR_PROCEDURE() AS ErrorProcedure  
            ,ERROR_LINE() AS ErrorLine  
            ,ERROR_MESSAGE() AS ErrorMessage;  
		IF @@TRANCOUNT>0
			DECLARE @ErrorMessage NVARCHAR(4000);  
			DECLARE @ErrorSeverity INT;  
			DECLARE @ErrorState INT;  
			SELECT   
			@ErrorMessage = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState = ERROR_STATE(); 
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState); --Added by Nivesh 2024-02-13
END CATCH;
END

GO

