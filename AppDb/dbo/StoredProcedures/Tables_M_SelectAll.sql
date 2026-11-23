
CREATE PROCEDURE [dbo].[Tables_M_SelectAll]
	@PropertyId INT
AS
BEGIN	
	SET NOCOUNT ON;

	SELECT 
	 Tl.TableID
	,Tl.TableName
	,Tl.TableCategoryID
	,TC.TableCategoryName
	,Tl.IsActive
	,Tl.SequenceID
	FROM POS_TableList as Tl
	INNER JOIN POS_TableCategories As TC On TC.TableCategoryID=Tl.TableCategoryID
    WHERE Tl.PropertyId=@PropertyId AND Tl.MarkAsDelete=0 


	

END

GO

