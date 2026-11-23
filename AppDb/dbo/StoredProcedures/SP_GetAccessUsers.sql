
create PROCEDURE [dbo].[SP_GetAccessUsers] (@UserId INT)

AS
BEGIN
	SELECT CompnayId INTO #TempProperties FROM UserWiseCompanies 
	WHERE UserId = @UserId

	SELECT DISTINCT UC.UserId AS Id, U.UserName AS Name FROM UserWiseCompanies UC
	INNER JOIN  #TempProperties TP
	ON UC.CompnayId = TP.CompnayId
	INNER JOIN UserMasters U
	ON U.Id = UC.UserId
	UNION 
	SELECT U.Id AS UserId,U.UserName FROM usermasters U
	WHERE U.Id NOT IN(SELECT UM.UserId FROM  userwisecompanies UM)
END

GO

