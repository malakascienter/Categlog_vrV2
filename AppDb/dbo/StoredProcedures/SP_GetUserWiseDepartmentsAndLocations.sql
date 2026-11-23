-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 27 September 2023
-- Description:	Loading UserWise Departments and Locations

-- [dbo].[SP_GetUserWiseDepartmentsAndLocations] 4168,1,1

-- [dbo].[SP_GetUserWiseDepartmentsAndLocations] 4168,2,1
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetUserWiseDepartmentsAndLocations]
(@UserID INT,
@Action INT,
@PropertyId INT)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @UserData TABLE(
	Id INT,
	UserName NVARCHAR(200),
	EmployeeId NVARCHAR(MAX)
	)

	DECLARE @IsCentralLogin BIT

	SELECT @IsCentralLogin = IsCentralLogin FROM Companies WHERE CompanyID = @PropertyID 
	IF(@IsCentralLogin = 1)
	BEGIN
		INSERT INTO @UserData
		SELECT Id, UserName, EmpNumber
		FROM [dbo].[CentralUsers]
	END
	ELSE
	BEGIN
		INSERT INTO @UserData
		SELECT Id, UserName,EmployeeId
		FROM UserMasters
	END


    IF(@Action = 1)
	BEGIN
		SELECT D.Id,@UserID UserID,D.Code,D.Name,D.IsActive,C.Name CompanyName,0 AS IsCheck,C.CompanyID
		INTO #TempDepartments
		FROM Departments D
		INNER JOIN dbo.Companies C ON C.CompanyID = D.PropertyID
		WHERE D.PropertyID = @PropertyId

		UPDATE #TempDepartments
		SET IsCheck = 1
		FROM #TempDepartments TD
		INNER JOIN UserWiseDepartments UD ON TD.Id = UD.deptid
		WHERE UD.userId = @UserID --AND UD.companyId = @PropertyId
	

		SELECT *
		FROM #TempDepartments 
		ORDER BY IsCheck DESC
	END

	IF(@Action = 2)
	BEGIN

		SELECT LO.Id,@UserID UserID,LO.Code,LO.Name,LO.IsActive,CO.Name CompanyName,0 AS IsCheck,CO.CompanyID
		INTO #TempLocations
		FROM Locations LO
		INNER JOIN Companies CO ON CO.CompanyID = LO.CompanyID
		WHERE LO.CompanyID = @PropertyId

		UPDATE #TempLocations
		SET IsCheck =1
		FROM #TempLocations TL
		INNER JOIN UserWise_Location UL ON UL.LocationID = TL.Id
		WHERE UL.UserID = @UserID --AND UL.CompanyId = @PropertyId

		select *
		from #TempLocations
		--where Ischeck=1
		ORDER BY IsCheck DESC
	END


END

GO

