-- =============================================
-- Author:		Yasiru
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- [dbo].[UserAccess_M_AccessPermission] 1,1,2,'S','[2]'
CREATE PROCEDURE [dbo].[UserAccess_M_AccessPermission]

@UserId		 INT,
@PropertyId INT,
@PageId      INT,
@Right		 CHAR(1),
@AltPages	NVARCHAR(MAX) 

AS
BEGIN	
	SET NOCOUNT ON;

	SELECT ISNULL(SUM(X.authorized),0)  
	From(
 		SELECT 
		CASE(@Right)
		WHEN 'S' THEN IsAllowSelect
		WHEN 'I' THEN IsAllowInsert
		WHEN 'D' THEN IsAllowDelete
		WHEN 'U' THEN IsAllowUpdate
		ELSE 0
		END  AS  authorized
		FROM
		UserWiseIndividualAccess 
		WHERE UserId = @UserId  
		AND (	PageId = @PageId 
				OR PageId IN (	SELECT [value]
								FROM OPENJSON (@AltPages)
							)
			)


		UNION

		SELECT 
		CASE(@Right)
		WHEN 'S' THEN URWP.IsAllowSelect
		WHEN 'I' THEN URWP.IsAllowInsert
		WHEN 'D' THEN URWP.IsAllowDelete
		WHEN 'U' THEN URWP.IsAllowUpdate
		ELSE 0
		END AS  authorized
		FROM
		UserRoleWisePages AS URWP	
		INNER JOIN users AS UWR ON UWR.UserRoleId = URWP.RoleId
		WHERE UWR.Id = @UserId  
		AND (	URWP.PageId = @PageId 
				OR PageId IN (	SELECT [value]
								FROM OPENJSON (@AltPages)
							)
			)
)  AS X

END

GO

