-- =============================================
-- Author:		Nivesh
-- Create date: 2024-08-09
-- Description:	Stock Spot Check Report
-- =============================================
-- SP_StockSpotCheck_Rpt 1008

CREATE PROCEDURE [dbo].[SP_StockSpotCheck_Rpt] 
	@StockTxnID INT
AS
BEGIN

	SET NOCOUNT ON;
	SELECT DISTINCT 
	SD.ID,
	SD.StockSpotHeaderID,
	SD.QuantityInHand,
	SH.SpotCheckDate,
	SD.PhysicalQty,
	SD.Remark,
	U.Name Unit,
	SD.AveragePrice Price,
	SIH.StockItemCode,
	L.Name LocationName,
	C.Name CompanyName,
	C.Address1 Address,
	C.Telephone1 TelNo,
	SIH.Name ItemName,
	SH.Remark HeaderRemark,
	CA.Name CategoryName,
	SCA.Name SubCategoryName,
	SC2A.Description SubCategory2Name,
	SH.DocNo ,
	SD.Remark ItemRemark,
	(SD.QuantityInHand - SD.PhysicalQty) Variance
	FROM
	[dbo].[StockSpotCheckHeader] SH
	INNER JOIN [dbo].[StockSpotCheckDetail] SD 
	ON SD.StockSpotHeaderID = SH.ID
	INNER JOIN Locations L ON L.Id = SH.LocationID
	INNER JOIN Companies C ON C.CompanyID = SH.PropertyID
	INNER JOIN StockItemHeaders SIH ON SIH.ID = SD.StockItemID
	INNER JOIN StockItemDetails SID ON SID.StockItemHeaderID = SIH.Id AND SID.CompanyID = SH.PropertyID AND SID.LocationID = SH.LocationID
	LEFT JOIN Categories CA ON CA.id =SIH.CategoryID
	LEFT JOIN SubCategories SCA ON SCA.Id = SIH.SubCategoryID
	LEFT JOIN SubCategories02 SC2A ON SC2A.Id = SIH.SubCategory2ID
	LEFT JOIN Units U ON U.Id = SID.MasterUnitID
	WHERE 
	SH.ID = @StockTxnID
END

GO

