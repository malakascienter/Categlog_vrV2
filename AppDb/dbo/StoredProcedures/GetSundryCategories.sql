
CREATE PROCEDURE GetSundryCategories 
AS
BEGIN

select SC.CategoryId,C.Name from [dbo].[SundryCategories] as SC 
inner join Categories as C on SC.CategoryId = C.Id




END

GO

