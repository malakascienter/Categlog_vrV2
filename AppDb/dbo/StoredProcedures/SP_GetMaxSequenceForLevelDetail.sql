-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetMaxSequenceForLevelDetail]
	@MenuItemCode NVARCHAR(10),
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;
SELECT [LevelDetailID]
      ,[SetMenuItemID]
      ,[SetMenuLevelID]
      ,[SortOrder] as Sequence
      ,[LevelQuantity]
      ,[IsDependLevel]
      ,[IsOptional]
      ,[DependLevelId]
      ,[IsActive]
  FROM [dbo].[POS_SetMenuLevelDetails]
  where  [SortOrder] = (select max(s.SortOrder) from [POS_SetMenuLevelDetails] s where s.SetMenuItemID = @MenuItemCode) AND PropertyId = @PropertyId
END

GO

