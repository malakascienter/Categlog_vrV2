
CREATE PROCEDURE [dbo].[SP_Load_ItemScheduleDays] 
	
	@MenuItemCode	VARCHAR(10),
	@PropertyId INT
AS
BEGIN			

SELECT * FROM POS_MenuItemScheduleDays WHERE  MenuCode = @MenuItemCode AND PropertyId = @PropertyId
	
END

GO

