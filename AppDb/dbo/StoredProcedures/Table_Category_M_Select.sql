-- =============================================
-- Author:		Chiraj
-- Create date: <Create Date,,>
-- Description:	2020-07-09
-- =============================================
CREATE PROCEDURE [dbo].[Table_Category_M_Select]
@isActive INT=2,
@PropertyId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    select * from POS_TableCategories
	WHERE  PropertyId=@PropertyId AND (@IsActive=2 OR IsActive=@isActive)
  Order By TableCategoryID
END

GO

