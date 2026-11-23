CREATE Proc [dbo].[InsertMasterFileChangeLog](@MasterFileName VARCHAR(200), @UserID int, @Operation char(1), @Description VARCHAR(MAX))
AS


SET @Description= CASE WHEN @Operation='I' THEN 'Insert ' ELSE CASE WHEN @Operation='D' THEN 'Delete ' ELSE 'Update ' END END   + 'For '+ @Description

Insert into [dbo].[MasterFileChangeLog] (MasterFileName, UserID,  Narration)
Values (@MasterFileName,@UserID, @Description)

GO

