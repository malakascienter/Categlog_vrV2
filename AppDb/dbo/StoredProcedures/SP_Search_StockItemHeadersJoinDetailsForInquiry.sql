 --[dbo].[SP_Search_StockItemHeadersJoinDetailsForInquiry] 1,10,'149',0,0,0,0,0,0,0,0,null,null,null,1,0,15,0
 
 --go
CREATE PROCEDURE [dbo].[SP_Search_StockItemHeadersJoinDetailsForInquiry] 
@from INT,
	@to INT, 
	@search VARCHAR(20),
	@sortType INT,
	@sortColumn INT, 
	@catergoryID INT,
	@subcatergoryID INT,
	@supplierID INT,
	@totalRecordCount INT OUTPUT,
	@status INT OUTPUT, 
	@message VARCHAR(20) OUTPUT,
    @supname VARCHAR(255),
	@SIHFrom INT,
	@SIHTO INT,
	@CompanyId INT,
	@SubCategory2ID INT ,
	@LocationID INT,
	@IsProductionItem BIT
AS 
DECLARE @statusIN[INT]
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
			SELECT @totalRecordCount = COUNT(*) FROM StockItemHeaders AS H 	
			INNER JOIN StockItemDetails AS SD ON SD.StockItemHeaderID = H.id
				WHERE H.CategoryID = (CASE when(@catergoryID = 0) THEN H.CategoryID ELSE @catergoryID end)  AND 
				H.SubCategoryID = (CASE when(@subcatergoryID = 0) THEN H.SubCategoryID ELSE @subcatergoryID end) 
				AND H.SubCategory2ID = (CASE when(@SubCategory2ID = 0) THEN H.SubCategory2ID ELSE @SubCategory2ID end)
				AND H.CompanyId=@CompanyId
				AND SD.LocationID = @LocationID
				AND ISNULL(H.IsProductionItem,0) = ISNULL(@IsProductionItem,0)
				--AND H.SupplierID = (CASE when(@supplierID = 0) THEN H.SupplierID ELSE @supplierID end)
	
			SELECT * 
			FROM( 
			SELECT H.Name, H.StockItemCode, H.SupplierID, H.Id ,H.ImageUrl,H.IsExpiryDateApplicable,H.TaxGroupID,H.PLUCode
			,SD.QuantityInHand, (ROW_NUMBER() OVER(ORDER BY H.Id ASC)) AS RowNum , C.Name AS CategoryName,  SB.Name AS SubCatergoryName,
			SB2.Description AS SubCatergory2Name, (SELECT [dbo].[FN_GetTopMasterUnit] (H.Id)) AS MasterUnit,L.Name LocationName,ISNULL(H.IsProductionItem,0) IsProductionItem
			FROM dbo.StockItemHeaders  AS H
			INNER JOIN StockItemDetails AS SD ON SD.StockItemHeaderID = H.id
			LEFT JOIN Locations L ON L.id = SD.LocationID
			LEFT JOIN Categories C On C.Id = H.CategoryID
			LEFT JOIN SubCategories SB ON SB.Id = h.SubCategoryID
			LEFT JOIN SubCategories02 SB2 ON SB2.Id = H.SubCategory2ID
				WHERE H.CategoryID = (CASE when(@catergoryID = 0) THEN H.CategoryID ELSE @catergoryID end)  AND 
				H.SubCategoryID = (CASE when(@subcatergoryID = 0) THEN H.SubCategoryID ELSE @subcatergoryID end) 
				AND H.SubCategory2ID = (CASE when(@SubCategory2ID = 0) THEN H.SubCategory2ID ELSE @SubCategory2ID end)
					AND H.CompanyId=@CompanyId
					AND SD.LocationID = @LocationID
					AND ISNULL(H.IsProductionItem,0) = ISNULL(@IsProductionItem,0)
				--AND H.SupplierID = (CASE when(@supplierID = 0) THEN H.SupplierID ELSE @supplierID end)
				)
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to  
			--ORDER BY InvDets.Id ASC 
			ORDER BY InvDets.StockItemCode ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM StockItemHeaders AS H 
		INNER JOIN StockItemDetails AS SD ON SD.StockItemHeaderID = H.id
		WHERE ((H.Id LIKE '%' + @search + '%' OR H.StockItemCode LIKE '%' + @search + '%' OR H.Name LIKE '%' + @search + '%' OR H.PLUCode LIKE '%' + @search + '%') 
		AND H.CategoryID = (CASE when(@catergoryID = 0) THEN H.CategoryID ELSE @catergoryID end)  AND 
				H.SubCategoryID = (CASE when(@subcatergoryID = 0) THEN H.SubCategoryID ELSE @subcatergoryID end) 
				AND H.SubCategory2ID = (CASE when(@SubCategory2ID = 0) THEN H.SubCategory2ID ELSE @SubCategory2ID end)
				AND H.CompanyId=@CompanyId
				AND SD.LocationID = @LocationID
				AND ISNULL(H.IsProductionItem,0) = ISNULL(@IsProductionItem,0)
				--AND H.SupplierID = (CASE when(@supplierID = 0) THEN H.SupplierID ELSE @supplierID end) 
				)

		SELECT *
		FROM ( SELECT H.Name, H.StockItemCode, H.SupplierID, H.Id ,H.ImageUrl,H.IsExpiryDateApplicable,H.TaxGroupID,H.PLUCode
			, SD.QuantityInHand, (ROW_NUMBER() OVER(ORDER BY H.Id ASC
		)) AS RowNum, C.Name AS CategoryName,  SB.Name AS SubCatergoryName,
			SB2.Description AS SubCatergory2Name, 
			(SELECT [dbo].[FN_GetTopMasterUnit] (H.Id)) AS MasterUnit,L.Name LocationName,ISNULL(H.IsProductionItem,0) IsProductionItem
			FROM dbo.StockItemHeaders  AS H
			INNER JOIN StockItemDetails AS SD ON SD.StockItemHeaderID = H.id
			LEFT JOIN Locations L ON L.id = SD.LocationID
			LEFT JOIN Categories C On C.Id = H.CategoryID
			LEFT JOIN SubCategories SB ON SB.Id = h.SubCategoryID
			LEFT JOIN SubCategories02 SB2 ON SB2.Id = H.SubCategory2ID				
				WHERE (((H.Name + H.StockItemCode+ H.PluCode LIKE 
					(CASE WHEN @Search IS NULL THEN H.Name + H.StockItemCode+ H.PluCode ELSE '%'+ @search +'%' END)
				) )  	AND H.CompanyId=@CompanyId 
				AND H.CategoryID = (CASE when(@catergoryID = 0) THEN H.CategoryID ELSE @catergoryID end)  AND 
				H.SubCategoryID = (CASE when(@subcatergoryID = 0) THEN H.SubCategoryID ELSE @subcatergoryID end)
				AND H.CompanyId=@CompanyId
				AND H.SubCategory2ID = (CASE when(@SubCategory2ID = 0) THEN H.SubCategory2ID ELSE @SubCategory2ID end)
				AND SD.LocationID = @LocationID
				AND ISNULL(H.IsProductionItem,0) = ISNULL(@IsProductionItem,0)
			))
			AS InvDets
			WHERE InvDets.RowNum BETWEEN @from AND @to 
			--ORDER BY InvDets.Id ASC
			ORDER BY InvDets.StockItemCode ASC


		END 
	END

	ELSE

	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM StockItemHeaders AS H 	
			INNER JOIN StockItemDetails AS SD ON SD.StockItemHeaderID = H.id
			WHERE SD.LocationID = @LocationID
			AND ISNULL(H.IsProductionItem,0) = ISNULL(@IsProductionItem,0)

			SELECT *
		FROM ( SELECT H.Name, H.StockItemCode, H.SupplierID, H.Id ,H.ImageUrl,H.IsExpiryDateApplicable,H.TaxGroupID,H.PLUCode, 
		--(ROW_NUMBER() OVER(ORDER BY H.Id ASC)) AS RowNum ,
		C.Name AS CategoryName,  SB.Name AS SubCatergoryName,
			SB2.Description AS SubCatergory2Name, (SELECT [dbo].[FN_GetTopMasterUnit] (H.Id)) AS MasterUnit
			,SD.QuantityInHand, (ROW_NUMBER() OVER(ORDER BY 
			(CASE 	WHEN @sortColumn = 0 AND @sortType = 1 THEN H.StockItemCode END) DESC,
					--(case WHEN @sortColumn = 1 AND @sortType = 1 THEN H.Name END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN H.Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN H.StockItemCode END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN H.StockItemCode END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN H.Name
					WHEN @sortColumn = 1 AND @sortType = 0 THEN H.StockItemCode END) ASC

			)) AS RowNum ,L.Name LocationName,ISNULL(H.IsProductionItem,0) IsProductionItem
			FROM dbo.StockItemHeaders  AS H	
			INNER JOIN StockItemDetails AS SD ON SD.StockItemHeaderID = H.id
			LEFT JOIN Locations L ON L.id = SD.LocationID
				LEFT JOIN Categories C On C.Id = H.CategoryID
				LEFT JOIN SubCategories SB ON SB.Id = h.SubCategoryID
				LEFT JOIN SubCategories02 SB2 ON SB2.Id = H.SubCategory2ID
				WHERE (((H.Name + H.StockItemCode+ H.PluCode LIKE	
				
				
				 (CASE WHEN @Search IS NULL THEN H.Name + H.StockItemCode+ H.PluCode ELSE '%'+@search+'%' END)
				
				
				) )  
				AND H.CategoryID = (CASE when(@catergoryID = 0) THEN H.CategoryID ELSE @catergoryID end)  AND 
				H.SubCategoryID = (CASE when(@subcatergoryID = 0) THEN H.SubCategoryID ELSE @subcatergoryID end) AND 
				 H.CompanyId=@CompanyId AND
				H.SupplierID = (CASE when(@supplierID = 0) THEN H.SupplierID ELSE @supplierID end)
				AND SD.LocationID = @LocationID
				AND ISNULL(H.IsProductionItem,0) = ISNULL(@IsProductionItem,0)))
				
			AS InvDets
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN StockItemCode END) DESC,
					(case WHEN @sortColumn = 1 AND @sortType = 1 THEN Name END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN StockItemCode END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN StockItemCode END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN StockItemCode END) ASC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM StockItemHeaders
		INNER JOIN StockItemDetails AS SD ON SD.StockItemHeaderID = StockItemHeaders.id
		WHERE ((StockItemHeaders.id LIKE '%' + @search + '%' 
		OR StockItemHeaders.StockItemCode LIKE '%' + @search + '%' OR StockItemHeaders.Name LIKE '%' + @search + '%' OR PLUCode LIKE '%' + @search + '%' ) 
		AND StockItemHeaders.CategoryID = (CASE when(@catergoryID = 0) THEN StockItemHeaders.CategoryID ELSE @catergoryID end)  AND 
				StockItemHeaders.SubCategoryID = (CASE when(@subcatergoryID = 0) THEN StockItemHeaders.SubCategoryID ELSE @subcatergoryID end) AND StockItemHeaders.CompanyId=@CompanyId AND 
				StockItemHeaders.SupplierID = (CASE when(@supplierID = 0) THEN StockItemHeaders.SupplierID ELSE @supplierID end)
				AND SD.LocationID = @LocationID 
				AND ISNULL(StockItemHeaders.IsProductionItem,0) = ISNULL(@IsProductionItem,0))

		SELECT *
		FROM ( SELECT H.Name, H.StockItemCode, H.SupplierID, H.Id ,H.ImageUrl,H.IsExpiryDateApplicable,H.TaxGroupID,H.PLUCode,C.Name AS CategoryName,  SB.Name AS SubCatergoryName,
			SB2.Description AS SubCatergory2Name, (SELECT [dbo].[FN_GetTopMasterUnit] (H.Id)) AS MasterUnit
		 ,SD.QuantityInHand, (ROW_NUMBER() OVER(ORDER BY 
						(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN StockItemCode END) DESC,
					--(case WHEN @sortColumn = 1 AND @sortType = 1 THEN H.Name END) DESC,
					--(case WHEN @sortColumn = 1 AND @sortType = 1 THEN H.Name END) DESC,

					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN H.Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN H.StockItemCode END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN H.StockItemCode END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN H.Name
					WHEN @sortColumn = 1 AND @sortType = 0 THEN H.StockItemCode END) ASC
		
		)) AS RowNum ,L.Name LocationName,ISNULL(H.IsProductionItem,0) IsProductionItem
			FROM dbo.StockItemHeaders  AS H	
			INNER JOIN StockItemDetails AS SD ON SD.StockItemHeaderID = H.id
			LEFT JOIN Locations L ON L.id = SD.LocationID
				LEFT JOIN Categories C On C.Id = H.CategoryID
				LEFT JOIN SubCategories SB ON SB.Id = h.SubCategoryID
				LEFT JOIN SubCategories02 SB2 ON SB2.Id = H.SubCategory2ID
				WHERE (((H.Name + H.StockItemCode+ H.PluCode LIKE 
				
				
				 (CASE WHEN @Search IS NULL THEN H.Name + H.StockItemCode+ H.PluCode ELSE '%' +@search +'%' END)
				
				
				) )  
				AND H.CategoryID = (CASE when(@catergoryID = 0) THEN H.CategoryID ELSE @catergoryID end)  AND 
				H.SubCategoryID = (CASE when(@subcatergoryID = 0) THEN H.SubCategoryID ELSE @subcatergoryID end)AND 
			    H.CompanyId=@CompanyId 
				AND SD.LocationID = @LocationID
				AND ISNULL(H.IsProductionItem,0) = ISNULL(@IsProductionItem,0)
				AND H.SupplierID = (CASE when(@supplierID = 0) THEN H.SupplierID ELSE @supplierID end)))
			AS InvDets
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
						(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN StockItemCode END) DESC,
					--(case WHEN @sortColumn = 1 AND @sortType = 1 THEN Name END) DESC,
			
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN StockItemCode END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN StockItemCode END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN Name 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN StockItemCode END) ASC
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

