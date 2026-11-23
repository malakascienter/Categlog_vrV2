-- =============================================
-- Author:		Chiraj
-- Create date: 2019-02-
-- Description:	Select Recipe Header data
-- =============================================
CREATE PROCEDURE [dbo].[RecipeHeader_M_Select]
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT *
	 FROM RecipeHeader WHERE PropertyId=@propertyId order by Id
  
END

GO

