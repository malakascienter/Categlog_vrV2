
-- =============================================
-- Author:		Chiraj
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE TableCategory_M_SelectBy_Id
	@Id INT,
	@PropertyId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   SELECT * FROM POS_TableCategories WHERE   PropertyId=@PropertyId AND TableCategoryID=@Id
END

GO

