CREATE PROCEDURE [dbo].[SP_SelectAllLoctionWiseStockItemExist]
	-- Add the parameters for the stored procedure here
	@LocationID	INT,
	@StockItemID INT = -999
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    
	SELECT DISTINCT h.Id,Name,d.LocationID 
	FROM StockItemHeaders h 
	INNER JOIN StockItemDetails d on h.Id= d.StockItemID 
	WHERE d.LocationID = @LocationID 
	AND h.Id = CASE WHEN @StockItemID=-999 THEN h.Id ELSE @StockItemID END
	ORDER BY h.Name

END

GO

