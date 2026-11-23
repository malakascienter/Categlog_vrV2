-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2023-12-06
-- Description:	Loading UserWise POAccessCodes
-- [dbo].[RT_UserWisePOAccessCodes] 58,1
-- =============================================
create PROCEDURE [dbo].[RT_UserWisePOAccessCodes]
	@UserRoleID INT,
	@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT Id,LTRIM(RTRIM(AccessCode))AS AccessCode,DisplayName,PropertyId,0 IsCheck,@UserRoleID UserGroupID,SortOrder
	INTO #TempUserWiseAccessCodes
	FROM RT_POS_AccessCodes
	WHERE Active=1 AND PropertyId=@PropertyId order by SortOrder


	UPDATE #TempUserWiseAccessCodes
	SET IsCheck =1
	FROM #TempUserWiseAccessCodes AC
	INNER JOIN [dbo].[RT_POS_UserRoleWiseAccess] UA ON AC.Id = UA.AccessCodeId
	WHERE AC.PropertyId = @PropertyID AND UA.UserRoleId = @UserRoleID

	select Id,LTRIM(RTRIM(AccessCode))AS AccessCode,DisplayName,UserGroupID, IsCheck,PropertyId,SortOrder
	from #TempUserWiseAccessCodes
	ORDER BY SortOrder ASC






END

GO

