
CREATE PROCEDURE [dbo].[SP_GetLocationWiseGRN](@from INT,
	@to INT,
	@search VARCHAR(20),
	@sortType INT,
	@sortColumn INT,
	@totalRecordCount INT OUTPUT,
	@status INT OUTPUT, 
	@message VARCHAR(20) OUTPUT,
	@filterId INT,
	@PropertyId INT,
	@type INT)
	
AS
DECLARE @statusIN[int]
	SET @statusIN = 0;
	SET  @message = ''
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION

		SET @search = LTRIM(RTRIM(@search))

		CREATE TABLE #TempGRNDetails
		(
		TxnId INT,
		DocumentNo VARCHAR(20),
		SuppName VARCHAR(300),
		InvNo VARCHAR(300),
		RefNo VARCHAR(300)
		)

		IF @type = 1
		BEGIN		
			INSERT INTO  #TempGRNDetails
			SELECT DISTINCT SH.Id AS TxnId,SH.DocumentNo,S.Name AS SuppName,SH.ReferenceNo AS InvNo,PO.PoNo AS RefNo 
			FROM StockTransactionHeaders SH
			INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID	
			INNER JOIN Suppliers S ON S.ID = SH.SupplierID
			LEFT JOIN PoHeaders PO ON PO.Id = SH.ReferenceID
			LEFT JOIN ThreeWayMatchingHeader TM ON TM.GRNTxnId = SH.Id 
			WHERE SH.LocationID = @filterId AND SH.TransactionType = 'GR' AND SH.PropertyID = @PropertyId AND TM.Approved IS NULL 
			AND SH.ReferenceID <> 0
		END
		IF @type = 2
		BEGIN
			INSERT INTO  #TempGRNDetails
			SELECT DISTINCT SH.Id AS TxnId,SH.DocumentNo,S.Name AS SuppName,SH.ReferenceNo AS InvNo,PO.PoNo AS RefNo
			FROM StockTransactionHeaders SH
			INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID	
			INNER JOIN Suppliers S ON S.ID = SH.SupplierID
			LEFT JOIN PoHeaders PO ON PO.Id = SH.ReferenceID
			LEFT JOIN ThreeWayMatchingHeader TM ON TM.GRNTxnId = SH.Id 
			WHERE SH.LocationID = @filterId AND SH.TransactionType = 'GR' AND SH.PropertyID = @PropertyId AND  TM.Approved=0
			AND SH.ReferenceID <> 0
		END

		

		IF(@sortColumn = 0 AND @sortType = 0)
		BEGIN
			IF(@search IS NULL OR @search = '')
			BEGIN 
				SELECT @totalRecordCount = COUNT(*) FROM #TempGRNDetails 
	
				SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY QuotationID ASC)) AS RowNum FROM #TempGRNDetails  WHERE ((DocumentNo LIKE '%' + @search + '%' OR  SuppName LIKE '%' + @search + '%' OR InvNo LIKE '%' + @search + '%'  OR RefNo LIKE '%' + @search + '%') )) 
				AS InvDets
				WHERE RowNum BETWEEN @from AND @to 
				ORDER BY RowNum ASC 
			END
		ELSE
			BEGIN
			SELECT @totalRecordCount = COUNT(*) FROM #TempGRNDetails WHERE ((DocumentNo LIKE '%' + @search + '%' OR  SuppName LIKE '%' + @search + '%' OR InvNo LIKE '%' + @search + '%'  OR RefNo LIKE '%' + @search + '%') ) 

			SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY QuotationID ASC
			)) AS RowNum FROM #TempGRNDetails 
					WHERE (DocumentNo LIKE '%' + @search + '%' OR  SuppName LIKE '%' + @search + '%' OR InvNo LIKE '%' + @search + '%'  OR RefNo LIKE '%' + @search + '%')  )
					AS InvDets 
					
						WHERE InvDets.RowNum BETWEEN @from AND @to 
						ORDER BY RowNum ASC
			END 
		END
		ELSE
			BEGIN
			IF(@search IS NULL OR @search = '')
				BEGIN 
					SELECT @totalRecordCount = COUNT(*) FROM #TempGRNDetails 
					--select '111'
					SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
					(CASE 
							WHEN @sortColumn = 0 AND @sortType = 1 THEN DocumentNo END) DESC,
							(CASE 
							WHEN @sortColumn = 3 AND @sortType = 1 THEN RefNo 
							WHEN @sortColumn = 1 AND @sortType = 1 THEN SuppName
							WHEN @sortColumn = 2 AND @sortType = 1 THEN InvNo END
							) DESC,
							(CASE 
							WHEN @sortColumn = 0 AND @sortType = 0 THEN DocumentNo END) ASC,
							(CASE 
							WHEN @sortColumn = 3 AND @sortType = 0 THEN RefNo
							WHEN @sortColumn = 1 AND @sortType = 0 THEN SuppName
							WHEN @sortColumn = 2 AND @sortType = 0 THEN InvNo END)ASC 

					)) AS RowNum FROM #TempGRNDetails  WHERE ((DocumentNo LIKE '%' + @search + '%' OR  SuppName LIKE '%' + @search + '%' OR InvNo LIKE '%' + @search + '%'  OR RefNo LIKE '%' + @search + '%')) )
					AS InvDets
					WHERE RowNum BETWEEN @from AND @to 
				
						ORDER BY 
							(CASE 
							WHEN @sortColumn = 0 AND @sortType = 1 THEN DocumentNo END) DESC,
							(CASE 
							WHEN @sortColumn = 3 AND @sortType = 1 THEN RefNo 
							WHEN @sortColumn = 1 AND @sortType = 1 THEN SuppName
							WHEN @sortColumn = 2 AND @sortType = 1 THEN InvNo END
							) DESC,
							(CASE 
							WHEN @sortColumn = 0 AND @sortType = 0 THEN DocumentNo END) ASC,
							(CASE 
							WHEN @sortColumn = 3 AND @sortType = 0 THEN RefNo
							WHEN @sortColumn = 1 AND @sortType = 0 THEN SuppName
							WHEN @sortColumn = 2 AND @sortType = 0 THEN InvNo END)ASC 

				END
			ELSE
				BEGIN
				SELECT @totalRecordCount = COUNT(*) FROM #TempGRNDetails WHERE ((DocumentNo LIKE '%' + @search + '%' OR  SuppName LIKE '%' + @search + '%' OR InvNo LIKE '%' + @search + '%'  OR RefNo LIKE '%' + @search + '%')  )

				SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
							(CASE 
							WHEN @sortColumn = 0 AND @sortType = 1 THEN DocumentNo END) DESC,
							(CASE 
							WHEN @sortColumn = 3 AND @sortType = 1 THEN RefNo 
							WHEN @sortColumn = 1 AND @sortType = 1 THEN SuppName
							WHEN @sortColumn = 2 AND @sortType = 1 THEN InvNo END
							) DESC,
							(CASE 
							WHEN @sortColumn = 0 AND @sortType = 0 THEN DocumentNo END) ASC,
							(CASE 
							WHEN @sortColumn = 3 AND @sortType = 0 THEN RefNo
							WHEN @sortColumn = 1 AND @sortType = 0 THEN SuppName
							WHEN @sortColumn = 2 AND @sortType = 0 THEN InvNo END)ASC 
		
				)) AS RowNum FROM #TempGRNDetails  
						WHERE (DocumentNo LIKE '%' + @search + '%' OR  SuppName LIKE '%' + @search + '%' OR InvNo LIKE '%' + @search + '%'  OR RefNo LIKE '%' + @search + '%') )
						AS InvDets 
					
							WHERE InvDets.RowNum BETWEEN @from AND @to 
							ORDER BY 
							(CASE 
							WHEN @sortColumn = 0 AND @sortType = 1 THEN DocumentNo END) DESC,
							(CASE 
							WHEN @sortColumn = 3 AND @sortType = 1 THEN RefNo 
							WHEN @sortColumn = 1 AND @sortType = 1 THEN SuppName
							WHEN @sortColumn = 2 AND @sortType = 1 THEN InvNo END
							) DESC,
							(CASE 
							WHEN @sortColumn = 0 AND @sortType = 0 THEN DocumentNo END) ASC,
							(CASE 
							WHEN @sortColumn = 3 AND @sortType = 0 THEN RefNo
							WHEN @sortColumn = 1 AND @sortType = 0 THEN SuppName
							WHEN @sortColumn = 2 AND @sortType = 0 THEN InvNo END)ASC 
				END 
		END
		
	COMMIT TRAN;
	SET @status = @statusIN;
	END TRY
	BEGIN CATCH
		SET @status = -1;
		SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))	
	END CATCH

END

GO

