-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--TableDetails_M_SelectBy_TableCategory 3,2
CREATE PROCEDURE [dbo].[TableDetails_M_SelectBy_TableCategory]
@TableCategoryId INT,
@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;
   SELECT TL.*,TCL.TableCategoryName FROM  [dbo].[POS_TableList] TL INNER JOIN POS_TableCategories TCL ON TL.TableCategoryID = TCL.TableCategoryID
   WHERE TL.PropertyId=@PropertyId 
   AND @TableCategoryId=TL.TableCategoryID
   AND TL.MarkAsDelete=0
END

GO

