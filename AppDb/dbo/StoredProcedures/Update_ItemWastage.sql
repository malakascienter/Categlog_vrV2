
CREATE PROCEDURE [dbo].[Update_ItemWastage]
	@id int,
	@Qty MONEY,
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;
	
	UPDATE  [POS_ItemWastageDetails]
	SET Qty = @Qty
	WHERE Id = @id 


END

GO

