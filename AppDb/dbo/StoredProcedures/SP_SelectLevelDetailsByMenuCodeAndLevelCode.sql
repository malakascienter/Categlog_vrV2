-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_SelectLevelDetailsByMenuCodeAndLevelCode]
	@MenuItemCode NVARCHAR(10),
	@LevelCode NVARCHAR(10),
	@PropertyId INT
AS
BEGIN
SET NOCOUNT ON;

	SELECT s.LevelDetailID as LevelDetailId,S.SetMenuLevelID as SetMenuLevelId,
				S.LevelQuantity AS Quantity, S.SortOrder AS Sequence,
				CASE 
				WHEN S.IsOptional = 1 THEN 'Yes'
				ELSE 'No'
				END as Optional,
				CASE 
				WHEN S.IsDependLevel = 1 THEN 'Yes'
				ELSE 'No'
				END as DependLevel,
				CASE 
				WHEN S.IsActive = 1 THEN 'Active'
				ELSE 'Inactive'
				END as Status,
				CASE 
				WHEN s.DependLevelId = 0 THEN 'N/A'
				ELSE s.DependLevelId
				END as DependLevelId,
				s.IsDependLevel as IsDependLevel,
				s.IsOptional as IsOptional,
				S.IsActive	  
	FROM POS_SetMenuLevelDetails  s
	WHERE SetMenuItemID = @MenuItemCode AND SetMenuLevelID = @LevelCode AND IsActive = 1  AND S.PropertyId = @PropertyId

END

GO

