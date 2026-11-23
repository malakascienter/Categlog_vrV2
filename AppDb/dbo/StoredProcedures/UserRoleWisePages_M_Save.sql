-- =============================================
-- Author:		Yasiru
-- Create date: 2017-09-07
-- Description:	User Roles
-- =============================================
CREATE PROCEDURE [dbo].[UserRoleWisePages_M_Save]
(
	@Operation CHAR(1),
	@MainNavigationId INT,
	@RoleId			  INT,
	@UserRoleWisePagesJson  NVARCHAR(max),
	@UserId INT = -1,
	@PropertyId INT
)

AS
BEGIN
SET NOCOUNT ON;
	IF(@Operation = 'I')
		BEGIN

		create table #TempIds
		(MainNavigationId int)

		Insert Into #TempIds
		Select MainNavigationId
		FROM 
		OPENJSON (@UserRoleWisePagesJson)
		WITH ( MainNavigationId INT '$.MainNavigationId' )


		DELETE FROM UserRoleWisePages WHERE RoleId = @RoleId AND  MainNavigationId IN (SELECT MainNavigationId FROM #TempIds) AND PropertyId=@PropertyId

			INSERT INTO UserRoleWisePages(RoleId,MainNavigationId, PageId, IsAllowInsert, IsAllowUpdate, IsAllowDelete, IsAllowSelect, CreatedUserId, CreatedDateTime, LastUpdatedUserId, LastUpdatedDateTime,PropertyId)
			Select @RoleId,MainNavigationId, PageId, IsAllowInsert, IsAllowUpdate, IsAllowDelete, IsAllowSelect,@UserId, GETDATE(), @UserId, GETDATE(),@PropertyId
			FROM 
				OPENJSON (@UserRoleWisePagesJson)
		    WITH (
			   PageId INT '$.PageId',
			   MainNavigationId INT '$.MainNavigationId',
			   IsAllowInsert BIT '$.IsAllowInsert',
			   IsAllowUpdate BIT '$.IsAllowUpdate',
			   IsAllowDelete BIT '$.IsAllowDelete',
			   IsAllowSelect BIT '$.IsAllowSelect'
		    )
        
		
		If(OBJECT_ID('tempdb..#TempIds') Is Not Null)
		Begin
			Drop Table #TempIds
		End

		END

END

GO

