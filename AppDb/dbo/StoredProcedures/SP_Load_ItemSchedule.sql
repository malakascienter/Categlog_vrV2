
CREATE PROCEDURE [dbo].[SP_Load_ItemSchedule] 
	
	@MenuItemCode	VARCHAR(10),
	@PropertyId INT
AS
BEGIN			

SELECT * FROM POS_MenuItemSchedule WHERE  MenuCode = @MenuItemCode AND PropertyId = @PropertyId
	
END

GO

