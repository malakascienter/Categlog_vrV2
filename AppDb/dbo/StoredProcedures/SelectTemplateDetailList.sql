-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-10-08
-- Description:	SP to get Template Item details
-- [dbo].[SelectTemplateDetailList]  1,-999,-999
-- =============================================
CREATE PROCEDURE [dbo].[SelectTemplateDetailList] 
(
@PropertyID INT=1,
@LocationID INT = -999,
@TemplateHeaderID INT = -999
)

AS
BEGIN
	SET NOCOUNT ON;

    SELECT RH.TemplateHeaderID,RH.Name,RD.StockItemHeaderID,SH.StockItemCode,SH.Name ItemName,UN.Name UnitName,
	--,SD.QuantityInHand,SD.AveragePrice,
	RD.Qty
	FROM RequestTemplateHeader RH
	INNER JOIN RequestTemplateDetails RD ON RH.TemplateHeaderID = RD.TemplateHeaderID
	INNER JOIN StockItemHeaders SH ON SH.ID = RD.StockItemHeaderID
	--INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID
	INNER JOIN Units UN ON UN.Id = RD.UnitID
	INNER JOIN Categories CA ON SH.CategoryID = CA.Id
	INNER JOIN SubCategories SC ON SC.Id = SH.SubCategoryID
	INNER JOIN SubCategories02 SC2 ON SC2.Id =SH.SubCategory2ID
	WHERE RH.PropertyId = @PropertyID 
	AND RH.TemplateHeaderID = CASE WHEN @TemplateHeaderID = -999 THEN RH.TemplateHeaderID ELSE @TemplateHeaderID END
	--AND SD.LocationID = CASE WHEN @LocationID =-999 THEN SD.LocationID ELSE @LocationID END
	AND RH.IsHouseKeepingAPI=1
	ORDER BY RH.TemplateHeaderID

END

GO

