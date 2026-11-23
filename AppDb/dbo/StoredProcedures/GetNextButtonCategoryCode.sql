
-- =============================================
-- Author:		chiraj
-- Create date: 2018-11-06
-- Description:	Get Item Code  BY category fro mainmenu
-- =============================================
CREATE PROCEDURE [dbo].[GetNextButtonCategoryCode]
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT [dbo].[ButtonCategory_GetNextDocNo] (@PropertyId)
  
END

GO

