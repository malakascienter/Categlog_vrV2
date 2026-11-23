
CREATE PROCEDURE [dbo].[Delete_ItemWastage]
	@id int,
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;
	
	DELETE FROM [POS_ItemWastageDetails] WHERE Id = @id 


END

GO

