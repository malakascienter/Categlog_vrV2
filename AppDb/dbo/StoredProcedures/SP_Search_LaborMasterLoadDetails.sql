CREATE PROCEDURE [dbo].[SP_Search_LaborMasterLoadDetails]

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

	IF(@sortColumn = 0 AND @sortType = 0)
	BEGIN
		IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM LaborMasters 
			SELECT *
			 FROM ( 
				SELECT LM.ID As Id,S.ID AS SupplierID , S.Name AS SupplierName , LT.Id AS LaborTypeId ,
						LT.LabourName  AS LabourTypeName,LU.Id AS LaborUnitId , LU.LaborUnitName ,
						LM.price,s.PropertyID AS PropertyID , LU.LaborUnitCode  AS LaborUnitCode , (ROW_NUMBER() OVER(ORDER BY LM.ID ASC)) AS RowNum 
				 FROM LaborMasters LM INNER JOIN LaborUnits LU ON LM.LaborUnitId=LU.Id
				 INNER JOIN  LabourTypes LT ON LM.LaborTypeId=LT.Id
				 INNER JOIN Suppliers  S ON LM.SupplierId = S.Id
				 WHERE ((LaborUnitId LIKE '%' + @search + '%') 
			 )) 
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY InvDets.SupplierName ASC 
		END
	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*)
		FROM LaborMasters LM INNER JOIN LaborUnits LU ON LM.LaborUnitId=LU.Id
				 INNER JOIN  LabourTypes LT ON LM.LaborTypeId=LT.Id
				 INNER JOIN Suppliers  S ON LM.SupplierId = S.Id
		WHERE ((LU.LaborUnitName LIKE '%' + @search + '%' OR LT.LabourName LIKE '%' + @search + '%'OR LM.price LIKE '%' + @search + '%' OR S.Name LIKE '%' + @search + '%') 
		--AND (LaborUnitId = @filterId)
		) 

		SELECT * 
		FROM (
				SELECT LM.ID As Id,S.ID AS SupplierID , S.Name AS SupplierName , LT.Id AS LaborTypeId ,
				LT.LabourName  AS LabourTypeName,LU.Id AS LaborUnitId , LU.LaborUnitName ,
				LM.price,s.PropertyID AS PropertyID , LU.LaborUnitCode  AS LaborUnitCode , (ROW_NUMBER() OVER(ORDER BY LM.Id ASC)) AS RowNum 
				FROM   LaborMasters LM INNER JOIN LaborUnits LU ON LM.LaborUnitId=LU.Id
				 INNER JOIN  LabourTypes LT ON LM.LaborTypeId=LT.Id
				 INNER JOIN Suppliers  S ON LM.SupplierId = S.Id 
				WHERE LU.LaborUnitName LIKE '%' + @search + '%' OR LT.LabourName LIKE '%' + @search + '%' OR price LIKE '%' + @search + '%' OR S.Name LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.LaborUnitName ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) 
			FROM LaborMasters LM INNER JOIN LaborUnits LU ON LM.LaborUnitId=LU.Id
				 INNER JOIN  LabourTypes LT ON LM.LaborTypeId=LT.Id
				 INNER JOIN Suppliers  S ON LM.SupplierId = S.Id 
			
	
			SELECT * FROM( SELECT  LM.ID As Id, S.ID AS SupplierID , S.Name AS SupplierName , LT.Id AS LaborTypeId ,
				LT.LabourName  AS LabourTypeName,LU.Id AS LaborUnitId , LU.LaborUnitName ,
				LM.price,s.PropertyID AS PropertyID , LU.LaborUnitCode  AS LaborUnitCode  , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN LM.Id  END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN LaborTypeId 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN LaborUnitId END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN LM.Id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN LaborTypeId 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN LaborUnitId END) ASC

			)) AS RowNum 
			FROM LaborMasters LM INNER JOIN LaborUnits LU ON LM.LaborUnitId=LU.Id
				 INNER JOIN  LabourTypes LT ON LM.LaborTypeId=LT.Id
				 INNER JOIN Suppliers  S ON LM.SupplierId = S.Id 
			WHERE ((LU.LaborUnitName LIKE '%' + @search + '%' OR LT.LabourName LIKE '%' + @search + '%' OR price LIKE '%' + @search + '%' OR S.Name LIKE '%' + @search + '%') 
			--AND (LaborUnitId = @filterId)
			))
			AS InvDets

			WHERE InvDets.RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.SupplierID  END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN LaborTypeId 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN LaborUnitId END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.SupplierID END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN LaborTypeId 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN LaborUnitId END) ASC
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*)
		 FROM LaborMasters LM INNER JOIN LaborUnits LU ON LM.LaborUnitId=LU.Id
				 INNER JOIN  LabourTypes LT ON LM.LaborTypeId=LT.Id
				 INNER JOIN Suppliers  S ON LM.SupplierId = S.Id 
		 WHERE ((LU.LaborUnitName LIKE '%' + @search + '%' OR LT.LabourName LIKE '%' + @search + '%' OR LM.price LIKE '%' + @search + '%' OR S.Name LIKE '%' + @search + '%') 
		--AND (LaborUnitId = @filterId)
		) 

		SELECT * 
		FROM ( SELECT LM.ID As Id,S.ID AS SupplierID , S.Name AS SupplierName , LT.Id AS LaborTypeId ,
				LT.LabourName  AS LabourTypeName,LU.Id AS LaborUnitId , LU.LaborUnitName ,
				LM.price,s.PropertyID AS PropertyID , LU.LaborUnitCode  AS LaborUnitCode  ,
				 (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN LM.Id  END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN LaborTypeId 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN LaborUnitId END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN LM.Id END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN LaborTypeId 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN LaborUnitId END) ASC
		
		)) AS RowNum 
		FROM LaborMasters LM INNER JOIN LaborUnits LU ON LM.LaborUnitId=LU.Id
				 INNER JOIN  LabourTypes LT ON LM.LaborTypeId=LT.Id
				 INNER JOIN Suppliers  S ON LM.SupplierId = S.Id  
				WHERE (LU.LaborUnitName LIKE '%' + @search + '%' OR LT.LabourName LIKE '%' + @search + '%' OR price LIKE '%' + @search + '%' OR S.Name LIKE '%' + @search + '%') 
				--AND (LaborUnitId = @filterId)
				 )
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.SupplierID  END) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN LaborTypeId 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN LaborUnitId END
					) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.SupplierID END) ASC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN LaborTypeId 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN LaborUnitId END) ASC
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

