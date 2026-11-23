
CREATE PROCEDURE [dbo].[SP_Delete_ItemSchedule] 
	
	@MenuCode	VARCHAR(10),
	@PropertyId INT
AS
BEGIN			

	DELETE FROM POS_MenuItemSchedule WHERE MenuCode = @MenuCode AND PropertyId = @PropertyId
	DELETE FROM POS_MenuItemScheduleDays WHERE MenuCode = @MenuCode AND PropertyId = @PropertyId


END

GO

