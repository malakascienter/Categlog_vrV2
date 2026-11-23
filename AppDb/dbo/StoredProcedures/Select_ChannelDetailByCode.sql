

CREATE PROCEDURE [dbo].[Select_ChannelDetailByCode]
	@Code VARCHAR(5)
	
	
AS
BEGIN	
SET NOCOUNT ON

	
	SELECT * FROM ChannelDetails WHERE ChannelCode = @Code


END

GO

