
--select * from userwisedepartments
--select * from userwisecompanies
--SP_S_GetUserDepartmentandCompanise 1,2
--Action 1 for get Companies and Action 2 for get Departments 
CREATE PROCEDURE [dbo].[SP_S_GetUserDepartmentandCompanise]
@UserID INT, @Action INT

AS 

BEGIN

	IF @Action =1 
	BEGIN

		SELECT UC.Id,C.CompanyID,UC.UserId,C.Code,C.Name,C.IsActive 
		FROM dbo.UserWiseCompanies AS UC INNER JOIN dbo.Companies C ON UC.CompnayId=C.CompanyID WHERE UC.UserId =@UserID
	END

	ELSE
	BEGIN
		
		SELECT UD.id,UD.userId,D.Code,D.Name,D.IsActive,C.Name CompanyName,C.CompanyID
		FROM dbo.UserWiseDepartments AS UD 
		INNER JOIN dbo.Departments AS D ON UD.deptid= D.Id 
		INNER JOIN dbo.Companies C ON C.CompanyID = D.PropertyID
		WHERE UD.userId=@UserID



	END
    


END

GO

