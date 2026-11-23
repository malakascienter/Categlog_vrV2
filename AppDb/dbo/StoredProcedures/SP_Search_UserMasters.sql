

-- SP_Search_UserMasters 1,10,'',1,0,0,0,0

CREATE PROCEDURE [dbo].[SP_Search_UserMasters]

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
			SELECT @totalRecordCount = COUNT(*) FROM UserMasters
	
			SELECT * 
			FROM( SELECT UM.Id, UM.UserName ,UM.UserDescription ,UM.Password ,UM.FirstName , UM.LastName, EMP.ID AS EmployeeID  ,EMP.Name  AS EmployeeName   ,EMP.Designation ,EMP.Code, UG.Id AS UserGroupID ,UG.UserGroupName
			 , (ROW_NUMBER() OVER(ORDER BY UM.ID ASC)) AS RowNum
			 FROM UserMasters UM  INNER JOIN Employees EMP ON UM.EmployeeId=EMP.Id
				INNER JOIN UserGroups UG ON UM.UserGroupID = UG.Id 
			 WHERE ( EMP.Name   LIKE '%' + @search + '%' OR UM.UserName LIKE '%' + @search + '%' OR UM.UserDescription LIKE '%'+ @search +'%' OR UG.UserGroupName LIKE '%'+ @search +'%') AND um.IsDelete =0   ) 
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY Id ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) 
		FROM UserMasters UM  INNER JOIN Employees EMP ON UM.EmployeeId=EMP.Id
				INNER JOIN UserGroups UG ON UM.UserGroupID = UG.Id  
			 WHERE ( EMP.Name   LIKE '%' + @search + '%' OR UM.UserName LIKE '%' + @search + '%' OR UM.UserDescription LIKE '%'+ @search +'%' OR UG.UserGroupName LIKE '%'+ @search +'%')  AND um.IsDelete =0 

		SELECT *
		 FROM ( SELECT   UM.Id, UM.UserName ,UM.UserDescription ,UM.Password ,UM.FirstName , UM.LastName, EMP.ID AS EmployeeID  ,EMP.Name  AS EmployeeName  ,EMP.Designation ,EMP.Code, UG.Id AS UserGroupID ,UG.UserGroupName
		  , (ROW_NUMBER() OVER(ORDER BY UM.Id ASC
		)) AS RowNum 
		FROM UserMasters UM  INNER JOIN Employees EMP ON UM.EmployeeId=EMP.Id
				INNER JOIN UserGroups UG ON UM.UserGroupID = UG.Id  
			 WHERE (  EMP.Name   LIKE '%' + @search + '%' OR UM.UserName LIKE '%' + @search + '%' OR UM.UserDescription LIKE '%'+ @search +'%' OR UG.UserGroupName LIKE '%'+ @search +'%')  AND um.IsDelete =0) 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Id ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) 
			FROM  UserMasters UM  INNER JOIN Employees EMP ON UM.EmployeeId=EMP.Id
				INNER JOIN UserGroups UG ON UM.UserGroupID = UG.Id  
			 WHERE (  EMP.Name   LIKE '%' + @search + '%' OR UM.UserName LIKE '%' + @search + '%' OR UM.UserDescription LIKE '%'+ @search +'%' OR UG.UserGroupName LIKE '%'+ @search +'%')  AND um.IsDelete =0
	
			SELECT * 
			FROM( SELECT  UM.Id, UM.UserName ,UM.UserDescription ,UM.Password ,UM.FirstName , UM.LastName, EMP.ID AS EmployeeID  ,EMP.Name  AS EmployeeName  ,EMP.Designation ,EMP.Code, UG.Id AS UserGroupID ,UG.UserGroupName , 
			(ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					--WHEN @sortColumn = 0 AND @sortType = 1 THEN UserName 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN UM.Id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN UserName
					WHEN @sortColumn = 2 AND @sortType = 1 THEN UserDescription 
					WHEN @sortColumn = 3 AND @sortType = 1 THEN EMP.Name END) DESC,
					(CASE 
					--WHEN @sortColumn = 0 AND @sortType = 0 THEN UserName 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN UM.Id  END) ASC,
					(CASE 
										-- 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN UserName
					WHEN @sortColumn = 2 AND @sortType = 0 THEN UserDescription 
					WHEN @sortColumn = 3 AND @sortType = 0 THEN EMP.Name END) ASC

			)) AS RowNum 
			FROM UserMasters UM  INNER JOIN Employees EMP ON UM.EmployeeId=EMP.Id
				INNER JOIN UserGroups UG ON UM.UserGroupID = UG.Id 
			 WHERE (  EMP.Name   LIKE '%' + @search + '%' OR UM.UserName LIKE '%' + @search + '%' OR UM.UserDescription LIKE '%'+ @search +'%' OR UG.UserGroupName LIKE '%'+ @search +'%')  AND um.IsDelete =0) 
			AS InvDets

			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
				--	WHEN @sortColumn = 0 AND @sortType = 1 THEN UserName
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.Id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN UserName
					WHEN @sortColumn = 2 AND @sortType = 1 THEN UserDescription
					WHEN @sortColumn = 3 AND @sortType = 1 THEN InvDets.EmployeeName END) DESC,
					(CASE 
					--WHEN @sortColumn = 0 AND @sortType = 0 THEN UserName
					WHEN @sortColumn = 1 AND @sortType = 0 THEN  InvDets.Id  END) ASC,
					(CASE
					WHEN @sortColumn = 1 AND @sortType = 0 THEN UserName 
					WHEN @sortColumn = 2 AND @sortType = 0 THEN UserDescription 
					WHEN @sortColumn = 3 AND @sortType = 0 THEN InvDets.EmployeeName END) ASC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) 
		FROM UserMasters UM  INNER JOIN Employees EMP ON UM.EmployeeId=EMP.Id
				INNER JOIN UserGroups UG ON UM.UserGroupID = UG.Id   
			 WHERE (  EMP.Name   LIKE '%' + @search + '%' OR UM.UserName LIKE '%' + @search + '%' OR UM.UserDescription LIKE '%'+ @search +'%' OR UG.UserGroupName LIKE '%'+ @search +'%')  AND um.IsDelete =0

		SELECT *
		 FROM ( SELECT  UM.Id,UM.UserName ,UM.UserDescription ,UM.Password ,UM.FirstName , UM.LastName, EMP.ID AS EmployeeID  ,EMP.Name  AS EmployeeName  ,EMP.Designation ,EMP.Code, UG.Id AS UserGroupID ,UG.UserGroupName , 
		(ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					--WHEN @sortColumn = 0 AND @sortType = 1 THEN UserName
					WHEN @sortColumn = 0 AND @sortType = 1 THEN UM.Id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN UserName
					WHEN @sortColumn = 2 AND @sortType = 1 THEN UserDescription
					WHEN @sortColumn = 3 AND @sortType = 1 THEN EMP.Name END) DESC,
					(CASE 
					--WHEN @sortColumn = 0 AND @sortType = 0 THEN UserName
					WHEN @sortColumn = 0 AND @sortType = 0 THEN  UM.Id  END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN UserName
					WHEN @sortColumn = 2 AND @sortType = 0 THEN UserDescription 
					WHEN @sortColumn = 3 AND @sortType = 0 THEN EMP.Name END) ASC
		
		)) AS RowNum 
		FROM UserMasters UM  INNER JOIN Employees EMP ON UM.EmployeeId=EMP.Id
				INNER JOIN UserGroups UG ON UM.UserGroupID = UG.Id  
			 WHERE ( EMP.Name   LIKE '%' + @search + '%' OR UM.UserName LIKE '%' + @search + '%' OR UM.UserDescription LIKE '%'+ @search +'%' OR UG.UserGroupName LIKE '%'+ @search +'%')  AND um.IsDelete =0) 
				AS InvDets

			WHERE InvDets.RowNum BETWEEN @from AND @to 

					ORDER BY 
					(CASE 
					--WHEN @sortColumn = 0 AND @sortType = 1 THEN UserName
					WHEN @sortColumn = 0 AND @sortType = 1 THEN InvDets.Id END) DESC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 1 THEN UserName
					WHEN @sortColumn = 2 AND @sortType = 1 THEN UserDescription 
					WHEN @sortColumn = 3 AND @sortType = 1 THEN InvDets.EmployeeName END) DESC,
					(CASE 
					--WHEN @sortColumn = 0 AND @sortType = 0 THEN UserName
					WHEN @sortColumn = 0 AND @sortType = 0 THEN InvDets.Id END) ASC,
					(CASE 
					WHEN @sortColumn = 1 AND @sortType = 0 THEN UserName
					WHEN @sortColumn = 2 AND @sortType = 0 THEN UserDescription
					WHEN @sortColumn = 3 AND @sortType = 0 THEN InvDets.EmployeeName
					 END) ASC
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

