
-- =============================================
-- Author:		chiraj
-- Create date: 2018-11-06
-- Description:	Get Item Code  BY category fro mainmenu
-- =============================================
CREATE PROCEDURE [dbo].[GetItemCode_By_Category]
	--@PrefixCode VARCHAR(3),
	@CategoryCode VARCHAR(3),
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT [dbo].[MainMenu_GetNextDocNo] (@CategoryCode,@PropertyId)
  
END

GO

