CREATE PROCEDURE [dbo].[SP_UserWiseDepartment]
	@userID INT,
	@comanyid INT

AS
BEGIN
	SELECT UD.deptid AS 'id', D.name AS 'text', D.IsPaxCount FROM UserWiseDepartments AS UD
	INNER JOIN Departments AS D ON UD.deptid = D.Id
	WHERE UD.UserID= @userID AND UD.companyId = CASE WHEN @comanyid = -999 THEN UD.companyId ELSE @comanyid END
	AND D.IsActive = 1
END

GO

