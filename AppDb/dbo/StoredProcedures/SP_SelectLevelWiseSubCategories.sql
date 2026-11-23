-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-08-22
-- Description:	SP for selection Level Wise Sub Cat & Su cat 2
--  [dbo].[SP_SelectLevelWiseSubCategories] 2,8,1
-- =============================================
CREATE PROCEDURE [dbo].[SP_SelectLevelWiseSubCategories]
	@Action INT,
	@CatID INT,
	@SubCatID INT,
	@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;

  IF(@Action = 1)
  BEGIN
	SELECT *
	FROM SubCategories SUB 
	WHERE SUB.CategoryId = @CatID
	AND SUB.IsActive=1

  END
  ELSE
  BEGIN
	SELECT *
	FROM SubCategories02 SUB2
	WHERE SUB2.SubCategoryId = @SubCatID
	AND SUB2.CategoryId = @CatID
	AND IsActive = 1
  END
END

GO

