CREATE PROCEDURE [dbo].[SP_CheckName]
	@name NVARCHAR(max)
AS
BEGIN
	SELECT ProjectName FROM dbo.ProjectDetails WHERE ProjectName = @name
END

GO

