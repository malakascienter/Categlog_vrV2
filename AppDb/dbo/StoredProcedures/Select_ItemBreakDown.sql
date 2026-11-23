-- =============================================
-- Author:		Chiraj
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[Select_ItemBreakDown] 'B002',1
CREATE PROCEDURE [dbo].[Select_ItemBreakDown]
	@MainMenuCode VARCHAR(4),
	@PropertyId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		select LTRIM(RTRIM(t.RecipeCode))AS RecipeCode,t.Qty ,t.AdditionalCost,R.Description,R.Ord_Type,R.LowerVariencePerc,R.HigherVariencePerc
		from ItemBreakDown t inner join RecipeHeader R ON T.RecipeCode = R.RecipeCode AND t.PropertyId = R.PropertyId 
		where MainMenuCode=@MainMenuCode AND t.PropertyId=@PropertyId AND R.PropertyId = @PropertyId
END

GO

