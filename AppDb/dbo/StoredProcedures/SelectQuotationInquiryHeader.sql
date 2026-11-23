
CREATE PROCEDURE [dbo].[SelectQuotationInquiryHeader](@from INT,
	@to INT,
	@search VARCHAR(20),
	@sortType INT,
	@sortColumn INT,
	@totalRecordCount INT OUTPUT,
	@status INT OUTPUT, 
	@message VARCHAR(20) OUTPUT,
	@filterId INT,
	@UserId INT=1)

AS
DECLARE @statusIN[int]
	SET @statusIN = 0;
	SET  @message = ''
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
		--SELECT CompnayId  INTO #TempCompanies FROM UserWiseCompanies WHERE UserId = @UserId		
		SELECT PropertyId AS CompnayId  INTO #TempCompanies FROM [dbo].[CentralUserWiseProperties]  WHERE UserId = @UserId	

		SET @search = LTRIM(RTRIM(@search))

		SELECT DISTINCT QH.Id QuotationID, QuotationNo,S.Name, CONVERT(VARCHAR(10),ValidFrom,103) ValidFrom, convert(varchar(10),ValidTo,103) ValidTo, 
		CASE WHEN Status='C' THEN CASE WHEN ValidTo < GETDATE()  THEN 'Expired' ELSE  'ACTIVE' END 
		ELSE CASE WHEN Status='X' THEN 'Reject' ELSE 'Pending' END  END   QStatus,
		CASE WHEN ExpdateChangeRemarks IS NULL THEN Qh.Remarks ELSE ExpdateChangeRemarks END Remarks, ExpdateChangeRemarks ExpRemarks INTO #TempQuotationInq
		FROM SupplierQuotationHeader QH
		INNER JOIN Suppliers S on S.ID= QH.SupplierId
		INNER JOIN SupplierQuotationDetails QD ON QD.QuotationHeaderId = QH.Id
		INNER JOIN #TempCompanies T ON T.CompnayId = QD.PropertyId
		WHERE SupplierId = CASE WHEN @filterId=-999 THEN SupplierId ELSE @filterId END 

		IF(@sortColumn = 0 AND @sortType = 0)
		BEGIN
			IF(@search IS NULL OR @search = '')
			BEGIN 
				SELECT @totalRecordCount = COUNT(*) FROM #TempQuotationInq 
	
				SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY QuotationID ASC)) AS RowNum FROM #TempQuotationInq  WHERE ((QuotationNo LIKE '%' + @search + '%' OR  QStatus LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%') )) 
				AS InvDets
				WHERE RowNum BETWEEN @from AND @to 
				ORDER BY RowNum ASC 
			END
		ELSE
			BEGIN
			SELECT @totalRecordCount = COUNT(*) FROM #TempQuotationInq WHERE ((QuotationNo LIKE '%' + @search + '%' OR  QStatus LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%')  )

			SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY QuotationID ASC
			)) AS RowNum FROM #TempQuotationInq 
					WHERE (QuotationNo LIKE '%' + @search + '%' OR  QStatus LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%')  )
					AS InvDets 
					
						WHERE InvDets.RowNum BETWEEN @from AND @to 
						ORDER BY RowNum ASC
			END 
		END
		ELSE
			BEGIN
			IF(@search IS NULL OR @search = '')
				BEGIN 
					SELECT @totalRecordCount = COUNT(*) FROM #TempQuotationInq 
					--select '111'
					SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
					(CASE 
							WHEN @sortColumn = 0 AND @sortType = 1 THEN QuotationId END) DESC,
							(CASE 
							WHEN @sortColumn = 3 AND @sortType = 1 THEN Name 
							WHEN @sortColumn = 1 AND @sortType = 1 THEN QuotationNo
							WHEN @sortColumn = 2 AND @sortType = 1 THEN QStatus END
							) DESC,
							(CASE 
							WHEN @sortColumn = 0 AND @sortType = 0 THEN QuotationId END) ASC,
							(CASE 
							WHEN @sortColumn = 3 AND @sortType = 0 THEN Name
							WHEN @sortColumn = 1 AND @sortType = 0 THEN QuotationNo
							WHEN @sortColumn = 2 AND @sortType = 0 THEN QStatus END)ASC 

					)) AS RowNum FROM #TempQuotationInq  WHERE ((QuotationNo LIKE '%' + @search + '%' OR  QStatus LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%')) )
					AS InvDets
					WHERE RowNum BETWEEN @from AND @to 
				
						ORDER BY 
							(CASE 
							WHEN @sortColumn = 0 AND @sortType = 1 THEN QuotationId END) DESC,
							(CASE 
							WHEN @sortColumn = 3 AND @sortType = 1 THEN Name 
							WHEN @sortColumn = 1 AND @sortType = 1 THEN QuotationNo
							WHEN @sortColumn = 2 AND @sortType = 1 THEN QStatus END
							) DESC,
							(CASE 
							WHEN @sortColumn = 0 AND @sortType = 0 THEN QuotationId END) ASC,	
							(CASE 
							WHEN @sortColumn = 3 AND @sortType = 0 THEN Name
							WHEN @sortColumn = 1 AND @sortType = 0 THEN QuotationNo
							WHEN @sortColumn = 2 AND @sortType = 0 THEN QStatus END) ASC

				END
			ELSE
				BEGIN
				SELECT @totalRecordCount = COUNT(*) FROM #TempQuotationInq WHERE ((QuotationNo LIKE '%' + @search + '%' OR  QStatus LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%')  )

				SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
							(CASE 
							WHEN @sortColumn = 0 AND @sortType = 1 THEN QuotationId END) DESC,
							(CASE 
							WHEN @sortColumn = 3 AND @sortType = 1 THEN Name 
							WHEN @sortColumn = 1 AND @sortType = 1 THEN QuotationNo
							WHEN @sortColumn = 2 AND @sortType = 1 THEN QStatus END
							) DESC,
							(CASE 
							WHEN @sortColumn = 1 AND @sortType = 0 THEN QuotationId END) ASC,
							(CASE 
							WHEN @sortColumn = 3 AND @sortType = 0 THEN Name
							WHEN @sortColumn = 1 AND @sortType = 0 THEN QuotationNo
							WHEN @sortColumn = 2 AND @sortType = 0 THEN QStatus END) ASC
		
				)) AS RowNum FROM #TempQuotationInq  
						WHERE (QuotationNo LIKE '%' + @search + '%' OR  QStatus LIKE '%' + @search + '%' OR Name LIKE '%' + @search + '%') )
						AS InvDets 
					
							WHERE InvDets.RowNum BETWEEN @from AND @to 
							ORDER BY 
											(CASE 
							WHEN @sortColumn = 0 AND @sortType = 1 THEN QuotationId END) DESC,
							(CASE 
							WHEN @sortColumn = 3 AND @sortType = 1 THEN Name 
							WHEN @sortColumn = 1 AND @sortType = 1 THEN QuotationNo
							WHEN @sortColumn = 2 AND @sortType = 1 THEN QStatus END
							) DESC,
							(CASE 
							WHEN @sortColumn = 1 AND @sortType = 0 THEN QuotationId END) ASC,
							(CASE 
							WHEN @sortColumn = 3 AND @sortType = 0 THEN Name
							WHEN @sortColumn = 1 AND @sortType = 0 THEN QuotationNo
							WHEN @sortColumn = 2 AND @sortType = 0 THEN QStatus END) ASC
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

