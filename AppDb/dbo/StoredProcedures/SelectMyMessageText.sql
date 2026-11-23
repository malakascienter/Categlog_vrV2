

CREATE PROCEDURE [dbo].[SelectMyMessageText]( @MessgageID INT, @OutputMsg NVARCHAR(MAX) OUTPUT,@Parameter1 NVARCHAR(MAX)='', @Parameter2 NVARCHAR(MAX)='', @Parameter3 NVARCHAR(MAX)='')
AS
BEGIN
	
	DECLARE @CutomMessgage NVARCHAR(MAX)= N'SET @OUT= ''MY MESSAGES ''+ @Para1 +'' Are where ''+@Para2 +''that they ''+@Para3'

	DECLARE @ParmDefinition NVARCHAR(500);

	SET @ParmDefinition = N'@Para1 NVARCHAR(MAX), @Para2 NVARCHAR(MAX), @Para3 NVARCHAR(MAX),@OUT NVARCHAR(MAX) OUTPUT';

	EXECUTE sp_executesql @CutomMessgage, 
							@ParmDefinition, 
							@Para1=@Parameter1,  
							@Para2=@Parameter2, 
							@Para3=@Parameter3,
							@OUT=@OutputMsg OUTPUT;

 END

GO

