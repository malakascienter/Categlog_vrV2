-- =============================================
-- Author:		<Yasiru>
-- Create date: <2018/04/10>
-- Description:	<UserWiseRolesSave>
-- =============================================
CREATE PROCEDURE [dbo].[UserWiseOutlet_M_Save]
@SelectedOutletJson NVARCHAR(MAX),
@UserId INT,
@CreatedUserId INT,
@Operation CHAR,
@PropertyId INT
AS
BEGIN
	IF @Operation = 'I'
	BEGIN
	  
		DELETE FROM UserWiseOutlet WHERE UserId = @UserId AND PropertyId = @PropertyId

		INSERT INTO UserWiseOutlet(UserId, OutletCode,IsUpload,PropertyId ,CreatedUserId, CreatedDateTime, LastUpdatedUserId, LastUpdatedDateTime)
		SELECT @UserId, OutletCode,0,@PropertyId,@CreatedUserId, GETDATE(),@CreatedUserId, GETDATE()
		FROM OPENJSON(@SelectedOutletJson)
		WITH 
		(
			OutletCode NVARCHAR(50) '$.Code'
		)
	END

END

GO

