
-- [dbo].[SP_Search_Suppliers] 1, 6,'',0,'1',0,0,'','0',-999

CREATE PROCEDURE [dbo].[SP_Search_Suppliers]

@from INT,
	@to INT,
	@search VARCHAR(20),
	@sortType INT,
	@sortColumn VARCHAR(1),
	@totalRecordCount INT OUTPUT,
	@status INT OUTPUT, 
	@message VARCHAR(20) OUTPUT,
	@filterId INT,
	@CategoryID INT = -999
AS
DECLARE @statusIN[int]
	SET @statusIN = 0;
	SET  @message = ''
BEGIN
BEGIN TRY
BEGIN TRANSACTION
SET @search = LTRIM(RTRIM(@search))

	IF(@CategoryID = 0 OR @CategoryID IS NULL)
	BEGIN
	SET @CategoryID = -999
	END

	IF(@sortColumn = 0 AND @sortType = 0)
	BEGIN
		IF(@search IS NULL OR @search = '')
		BEGIN 
			set @totalRecordCount = 0
			SELECT @totalRecordCount = COUNT(SU.ID) FROM Suppliers SU
			LEFT JOIN SupplierCategory SC ON SC.ID = SU.SupplierCategoryID
			WHERE ((Telephone1 LIKE '%' + @search + '%' 
			OR Email LIKE '%' + @search + '%' 
			OR Name LIKE '%' + @search + '%' 
			OR ContactPerson LIKE '%' + @search + '%')
			AND (PropertyID = @filterId)
			AND ISNULL(SC.ID,0) = CASE WHEN (ISNULL(@CategoryID, -999) = -999) THEN ISNULL(SC.ID,0) ELSE @CategoryID END
			)
	
			SELECT * FROM( SELECT SU.* , (ROW_NUMBER() OVER(ORDER BY SU.ID ASC)) AS RowNum 
			FROM dbo.Suppliers  SU
			LEFT JOIN SupplierCategory SC ON SC.ID = SU.SupplierCategoryID
			WHERE ((Telephone1 LIKE '%' + @search + '%' 
			OR  Email LIKE '%' + @search + '%' 
			OR Name LIKE '%' + @search + '%' 
			OR ContactPerson LIKE '%' + @search + '%')
			AND (PropertyID = @filterId)  )
			AND ISNULL(SC.ID,0) = CASE WHEN (ISNULL(@CategoryID, -999) = -999) THEN ISNULL(SC.ID,0) ELSE @CategoryID END) 
			AS InvDets 
			WHERE RowNum BETWEEN @from AND @to 

			ORDER BY ID ASC 
			
		END

		ELSE
			BEGIN
			set @totalRecordCount = 0
			SELECT @totalRecordCount = COUNT(Suppliers.ID) 
			FROM Suppliers 
			LEFT JOIN SupplierCategory SC ON SC.ID = Suppliers.SupplierCategoryID
			WHERE ((Suppliers.Telephone1 LIKE '%' + @search + '%' 
			OR Suppliers.Email LIKE '%' + @search + '%' 
			OR Suppliers.Name LIKE '%' + @search + '%' 
			OR Suppliers.ContactPerson LIKE '%' + @search + '%') 
			AND (PropertyID = @filterId)
			AND ISNULL(SC.ID,0) = CASE WHEN (ISNULL(@CategoryID, -999) = -999) THEN ISNULL(SC.ID,0) ELSE @CategoryID END)

			SELECT * FROM ( SELECT Suppliers.* , (ROW_NUMBER() OVER(ORDER BY Suppliers.Id ASC
			)) AS RowNum FROM Suppliers 
			LEFT JOIN SupplierCategory SC ON SC.ID = Suppliers.SupplierCategoryID
					WHERE (Telephone1 
					LIKE '%' + @search + '%' 
					OR Name LIKE '%' + @search + '%' 
					OR Email LIKE '%' + @search + '%' 
					OR ContactPerson 
					LIKE '%' + @search + '%') 
					AND (PropertyID = @filterId)  
					AND ISNULL(SC.ID,0) = CASE WHEN (ISNULL(@CategoryID, -999) = -999) THEN ISNULL(SC.ID,0) ELSE @CategoryID END
					)
					AS InvDets 
					
						WHERE InvDets.RowNum BETWEEN @from AND @to 
						ORDER BY InvDets.Id ASC
					
			END 
	END

	ELSE
	BEGIN
	IF(@search IS NULL OR @search = '')
		BEGIN
		set @totalRecordCount = 0
			SELECT @totalRecordCount = COUNT(SU.ID) 
			FROM Suppliers SU
			LEFT JOIN SupplierCategory SC ON SC.ID = SU.SupplierCategoryID
			WHERE ((Telephone1 LIKE '%' + @search + '%' 
			OR Name LIKE '%' + @search + '%' 
			OR Email LIKE '%' + @search + '%' 
			OR ContactPerson LIKE '%' + @search + '%') 
			AND (PropertyID = @filterId) 
			AND ISNULL(SC.ID,0) = CASE WHEN (ISNULL(@CategoryID, -999) = -999) THEN ISNULL(SC.ID,0) ELSE @CategoryID END
			)


			--SELECT InvDets.*,ISNULL(ET.EvaluationTemplateName,'Not Evaluated')EvaluationTemplateName,ISNULL(ETR.Grade,'Not Evaluated')Grade
			--changed by Tharuka 2026-10-29: Grade = grade of the latest completed Supplier Grading (FN_GetSupplierLatestGrade);
			--  CAST: SupplierGrade is NVARCHAR(10) and ISNULL would cut 'Not Evaluated' to 10 characters
			SELECT InvDets.*,ISNULL(ET.EvaluationTemplateName,'Not Evaluated')EvaluationTemplateName,ISNULL(CAST(LG.SupplierGrade AS NVARCHAR(50)),'Not Evaluated')Grade
				,ISNULL(SC.SupplierCategoryName,'')SupplierCategoryName
			FROM( SELECT SU.* , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN SU.id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN SU.Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN SU.Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN SU.id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN SU.Name
					WHEN @sortColumn = 1 AND @sortType = 0 THEN SU.code END) ASC

			)) AS RowNum FROM Suppliers SU
			LEFT JOIN SupplierCategory SC ON SC.ID = SU.SupplierCategoryID  
			WHERE ((Telephone1 LIKE '%' + @search + '%' 
			OR Name LIKE '%' + @search + '%' 
			OR Email LIKE '%' + @search + '%' 
			OR ContactPerson LIKE '%' + @search + '%') 
			AND (SU.PropertyID = @filterId)
			AND ISNULL(SC.ID,0) = CASE WHEN (ISNULL(@CategoryID, -999) = -999) THEN ISNULL(SC.ID,0) ELSE @CategoryID END
			) )AS InvDets

			LEFT JOIN EvaluationTemplate ET ON ET.ID = InvDets.EvaluationTemplateID
			--LEFT JOIN EvaluationCriteriaRange ETR ON ETR.ID = InvDets.SupplierGradingID AND ET.ID = InvDets.EvaluationTemplateID
			--added by Tharuka 2026-10-29: Suppliers.SupplierGradingID is not the evaluated grade (the Supplier
			--  master saves 2 for every supplier); read the latest completed Supplier Grading instead
			OUTER APPLY dbo.FN_GetSupplierLatestGrade(InvDets.ID) LG
			LEFT JOIN SupplierCategory SC ON InvDets.SupplierCategoryID = SC.ID

			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN code END) ASC
		END

	ELSE
        BEGIN
		set @totalRecordCount = 0
		SELECT @totalRecordCount = COUNT(Suppliers.ID) 
		FROM Suppliers 
		LEFT JOIN SupplierCategory SC ON SC.ID = Suppliers.SupplierCategoryID
		WHERE ((Suppliers.Telephone1 LIKE '%' + @search + '%' 
		OR Suppliers.Email LIKE '%' + @search + '%' 
		OR Suppliers.Name LIKE '%' + @search + '%' 
		OR Suppliers.ContactPerson LIKE '%' + @search + '%') 
		AND (PropertyID = @filterId)
		AND ISNULL(SC.ID,0) = CASE WHEN (ISNULL(@CategoryID, -999) = -999) THEN ISNULL(SC.ID,0) ELSE @CategoryID END)

		--SELECT InvDets.*,ISNULL(ET.EvaluationTemplateName,'Not Evaluated')EvaluationTemplateName,ISNULL(ETR.Grade,'Not Evaluated')Grade
		--changed by Tharuka 2026-10-29: Grade = grade of the latest completed Supplier Grading (FN_GetSupplierLatestGrade);
		--  CAST: SupplierGrade is NVARCHAR(10) and ISNULL would cut 'Not Evaluated' to 10 characters
		SELECT InvDets.*,ISNULL(ET.EvaluationTemplateName,'Not Evaluated')EvaluationTemplateName,ISNULL(CAST(LG.SupplierGrade AS NVARCHAR(50)),'Not Evaluated')Grade
		,ISNULL(SC.SupplierCategoryName,'') SupplierCategoryName
		FROM ( SELECT SU.* , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN SU.id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN SU.Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN SU.Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN SU.id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN SU.Name
					WHEN @sortColumn = 1 AND @sortType = 0 THEN SU.code END) ASC
		
		)) AS RowNum FROM Suppliers SU
		LEFT JOIN SupplierCategory SC ON SC.ID = SU.SupplierCategoryID
				WHERE (Telephone1 LIKE '%' + @search + '%' 
				OR Name LIKE '%' + @search + '%' 
				OR Email LIKE '%' + @search + '%' 
				OR ContactPerson LIKE '%' + @search + '%') 
				AND (PropertyID = @filterId)
				AND ISNULL(SC.ID,0) = CASE WHEN (ISNULL(@CategoryID, -999) = -999) THEN ISNULL(SC.ID,0) ELSE @CategoryID END)
				AS InvDets 
				LEFT JOIN EvaluationTemplate ET ON ET.ID = InvDets.EvaluationTemplateID
			--LEFT JOIN EvaluationCriteriaRange ETR ON ETR.ID = InvDets.SupplierGradingID AND ET.ID = InvDets.EvaluationTemplateID
			--added by Tharuka 2026-10-29: Suppliers.SupplierGradingID is not the evaluated grade (the Supplier
			--  master saves 2 for every supplier); read the latest completed Supplier Grading instead
			OUTER APPLY dbo.FN_GetSupplierLatestGrade(InvDets.ID) LG
			LEFT JOIN SupplierCategory SC ON InvDets.SupplierCategoryID = SC.ID
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.id END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN Code END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.id END) ASC,
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

GO

