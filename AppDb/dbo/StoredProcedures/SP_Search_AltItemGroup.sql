CREATE PROCEDURE [dbo].[SP_Search_AltItemGroup] --0,1000,'',1,1,0,1,'',1-- 1,2,1,'G004','aaa','192.168.0.0',1,1,'2018-04-19 15:02:20.633','2018-04-19 15:02:20.633','',1,2,1,1,''

		@from INT,
		@to INT,
		--@Id int ,
		--@GropCOde varchar(max),
		--@GropName varchar(max),
		--@IPAddress varchar(max),
		--@CreatedUserID int,
		--@LastModUserID int,
		--@CreatedDate datetime,
		--@LastModDate datetime,
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
			SELECT @totalRecordCount = COUNT(*) FROM AltItemGroups WHERE PropertyID = @filterId
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY ID ASC)) AS RowNum FROM AltItemGroups  WHERE (id LIKE '%' + @search + '%' OR GropCOde LIKE '%' + @search + '%' OR GropName LIKE '%' + @search + '%') AND (PropertyID = @filterId)) 
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY Id ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM AltItemGroups WHERE ((AltItemGroups.id LIKE '%' + @search + '%' OR AltItemGroups.GropCOde LIKE '%' + @search + '%' OR AltItemGroups.GropName LIKE '%' + @search + '%') and PropertyID = @filterId)

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Id ASC
		)) AS RowNum FROM AltItemGroups 
				WHERE (Id LIKE '%' + @search + '%' OR GropName LIKE '%' + @search + '%' OR GropCOde LIKE '%' + @search + '%') AND (PropertyID = @filterId) ) 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Id ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM AltItemGroups where PropertyID = @filterId
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN GropName
					WHEN @sortColumn = 1 AND @sortType = 1 THEN GropCOde END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN GropName
					WHEN @sortColumn = 1 AND @sortType = 0 THEN GropCOde END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC

			)) AS RowNum FROM AltItemGroups  WHERE (id LIKE '%' + @search + '%' OR GropName LIKE '%' + @search + '%' OR GropCOde LIKE '%' + @search + '%')AND (PropertyID = @filterId) ) 
			AS InvDets

			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN GropName
					WHEN @sortColumn = 1 AND @sortType = 1 THEN GropCOde END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN GropName
					WHEN @sortColumn = 1 AND @sortType = 0 THEN GropCOde END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC
		END

ELSE-------------------
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM AltItemGroups WHERE ((AltItemGroups.Id LIKE '%' + @search + '%' OR AltItemGroups.GropName LIKE '%' + @search + '%' OR AltItemGroups.GropCOde LIKE '%' + @search + '%')AND (PropertyID = @filterId)) 

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN GropName
					WHEN @sortColumn = 1 AND @sortType = 1 THEN GropCOde END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN GropName
					WHEN @sortColumn = 1 AND @sortType = 0 THEN GropCOde END) ASC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id END) ASC
		
		)) AS RowNum FROM AltItemGroups 
				WHERE (id LIKE '%' + @search + '%' OR GropName LIKE '%' + @search + '%' OR GropCOde LIKE '%' + @search + '%') AND (PropertyID = @filterId))
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
		(CASE 
					WHEN @sortColumn = 2 AND @sortType = 1 THEN GropName
					WHEN @sortColumn = 1 AND @sortType = 1 THEN GropCOde END) DESC,
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id END
					) DESC,
					(CASE 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN GropName
					WHEN @sortColumn = 1 AND @sortType = 0 THEN GropCOde END) ASC,
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

