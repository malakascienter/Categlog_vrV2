-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetMaxSequenceForSubLevelDetail]
	@MenuItemCode NVARCHAR(10),
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;

SELECT [SubLevelDetailID]
      ,[SetMenuItemID]
      ,[SetMenuLevelID]
      ,[SetMenuSubLevelID]
      ,[SortOrder] as SortOrder
      ,[SubLevelQuantity]
      ,[IsActive]
  FROM [dbo].[POS_SetMenuSubLevelDetails]
  where [SortOrder] = (select max(s.SortOrder) from POS_SetMenuSubLevelDetails s where s.SetMenuItemID = @MenuItemCode) AND PropertyId = @PropertyId
END

GO

