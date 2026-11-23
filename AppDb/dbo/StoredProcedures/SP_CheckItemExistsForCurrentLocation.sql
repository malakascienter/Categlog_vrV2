-- =============================================
-- Author:		Vinuki
-- Create date: 21.05.2024
-- Description:	CheckItemExistsForCurrentLocation
-- =============================================
--CheckItemExistsForCurrentLocation 4,'ENG/MCV/00104'
CREATE PROCEDURE SP_CheckItemExistsForCurrentLocation 
	@LocationID int,
	@StockItemCode  VARCHAR(20),
	@PropertyID int
AS
BEGIN
	declare @StockItemId int

	select @StockItemId = Id
	from
	StockItemHeaders
	where StockItemCode = @StockItemCode and CompanyId = @PropertyID


		select SID.LocationID 
		from StockItemHeaders SIH
		inner join StockItemDetails  SID on SIH.id = SID.StockItemHeaderID 
		where SID.LocationID = @LocationID and SIH.id = @StockItemId
END

GO

