

--exec [dbo].[DeleteRequestTemplteDetals] 1
CREATE Procedure [dbo].[DeleteRequestTemplteDetals] (@TemplateHeaderID int,@UserID int=1)
AS
BEGIN
	DECLARE @Name VARCHAR(MAX) 

	SELECT @Name = Name FROM RequestTemplateHeader WHERE TemplateHeaderId =  @TemplateHeaderID

	EXEC InsertMasterFileChangeLog 'Stock Item Template',@UserID,'D',@Name

	DELETE FROM	RequestTemplateHeader WHERE TemplateHeaderID = @TemplateHeaderID
	DELETE FROM	RequestTemplateDetails WHERE TemplateHeaderID = @TemplateHeaderID


END

GO

