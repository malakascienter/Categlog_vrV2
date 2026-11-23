-- =============================================
-- Author:		<Thisura>
-- Create date: <2018/04/10>
-- Description:	<UserWiseRolesSave>
-- =============================================
CREATE PROCEDURE [dbo].[UserWiseRoles_M_Save]
@SelectedRolesJson NVARCHAR(MAX),
@UserId INT,
@CreatedUserId INT,
@PropertyId INT,
@Operation CHAR
AS
BEGIN
	IF @Operation = 'I'
	BEGIN
	  
		DELETE FROM UserWiseRoles WHERE UserId = @UserId

		INSERT INTO UserWiseRoles(UserId, RoleId, CreatedUserId, CreatedDateTime, LastUpdatedUserId, LastUpdatedDateTime,PropertyId)
		SELECT @UserId, RoleId,@CreatedUserId, GETDATE(),@CreatedUserId, GETDATE(),@PropertyId
		FROM OPENJSON(@SelectedRolesJson)
		WITH 
		(
			RoleId INT '$.RoleId'
		)
	END

END

GO

