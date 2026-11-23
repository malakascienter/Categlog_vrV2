


-- =============================================
-- Author:		Banu
-- Create date: 16/10/2018
-- Description:	Get selected Menu list for price change
-- =============================================
CREATE PROCEDURE [dbo].[MainMenu_Select_For_Price] 
	@MenuItemCode VARCHAR(4),
	@MenuId INT,
	@PropertyId INT
AS
BEGIN  
	SELECT * FROM MainMenu WHERE ItemCode = @MenuItemCode AND Id = @MenuId AND PropertyId=@PropertyId
END

GO

