--EXEC [GetUserWiseLocations] 1
CREATE PROCEDURE [dbo].[GetUserWiseLocations] @UserID INT
AS
BEGIN

	SET NOCOUNT ON;

	SELECT UL.Id, UL.UserID, L.Code, L.Name, UL.IsActive ,C.Name CompanyName,C.CompanyID
	FROM UserWise_Location AS UL 
	INNER JOIN Locations AS L
	INNER JOIN dbo.Companies C ON C.CompanyID = L.CompanyID
	ON UL.LocationID = L.Id 
	WHERE UL.UserID = @UserID
END

GO

