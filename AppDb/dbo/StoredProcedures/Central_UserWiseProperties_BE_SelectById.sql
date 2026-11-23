CREATE PROCEDURE [dbo].[Central_UserWiseProperties_BE_SelectById]
@UserId  INT
AS
BEGIN


	SET NOCOUNT ON;
	SET DATEFORMAT DMY

	SELECT BC.*
	FROM [CentralAccessDB]..Central_Properties CC
	INNER JOIN Companies BC ON CC.ID = BC.CompanyID
	LEFT JOIN [CentralAccessDB]..Central_UserWiseProperties AS CUWP ON CC.Id = CUWP.PropertyId
	WHERE CUWP.UserId = @UserId

END

GO

