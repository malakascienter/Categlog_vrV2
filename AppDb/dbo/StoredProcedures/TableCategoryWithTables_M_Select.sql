-- =============================================
-- Author:		Chiraj
-- Create date: 2019-2-13
-- Description:Tablewithcategory Details_M_Select
-- =============================================
--[TableCategoryWithTables_M_Select] 2
CREATE PROCEDURE [dbo].[TableCategoryWithTables_M_Select]
	@PropertyId INT
AS
BEGIN	
	SET NOCOUNT ON;
	SELECT 
	 TableCategoryID
	 ,TableCategoryName
	 ,OutletID
	 ,IsActive
	 ,SequenceID	
	,(
	SELECT 
	Tl.TableID
	,Tl.TableCategoryID
	,Tl.TableName
	,Tl.IsActive
	,Tl.SeatCount
	,Tl.SequenceID
	FROM POS_TableList as Tl
	inner join POS_TableCategories As Tc On Tc.TableCategoryID=Tl.TableCategoryID
	 where 
	 Tl.PropertyId=@PropertyId AND Tl.MarkAsDelete=0 FOR JSON AUTO )AS RecipeDetailJson
	
	FROM POS_TableCategories  WHERE PropertyId=@PropertyId order by TableCategoryID


	

END

GO

