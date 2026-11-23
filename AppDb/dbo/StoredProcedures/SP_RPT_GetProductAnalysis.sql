-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2023-12-11
-- Description:	Producct Analysis Report

-- [dbo].[SP_RPT_GetProductAnalysis] '12','2024/03/01','2024/1/31',1

-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_GetProductAnalysis] 
@LocationID VARCHAR(MAX),
@FromDate DATE,
@ToDate DATE,
@PropertyID INT
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT SH.StockItemCode,SH.Name ItemName,LO.Name LocationName,CA.Name CategoryName,SUM(IVD.Quantity) Quantity,SH.Id StockItemID
	,AVG(IVD.SellingPrice) SellingPrice,SUM(IVD.Quantity*IVD.SellingPrice) Value,--(SUM(IVD.Quantity)*AVG(IVD.SellingPrice)) Value, commented by Isuru 2024-04-08 for report not tally 
	SU.Name SubCategory,SU2.Description SubCategory2
	,SUM(IVD.Quantity * IVD.AveragePrice) CostValue,(SUM(IVD.Quantity * IVD.AveragePrice))/SUM(IVD.Quantity) AVGCostPrice
	FROM POS_InvoiceHeader IVH
	INNER JOIN POS_InvoiceDetail IVD ON IVH.InvHeaderID = IVD.InvHeaderID
	INNER JOIN StockItemHeaders SH ON SH.Id = IVD.ItemID and sh.CompanyId=@PropertyID
	INNER JOIN Categories CA ON CA.Id = SH.CategoryID
	INNER JOIN SubCategories SU ON SU.ID = SH.SubCategoryID
	INNER JOIN SubCategories02 SU2 ON SU2.Id = SH.SubCategory2ID
	INNER JOIN Locations LO ON LO.Id = IVH.LocationID
	WHERE IVH.CompanyID = @PropertyID AND IVH.BusinessDate BETWEEN @FromDate AND @ToDate AND IVH.LocationID IN (SELECT * FROM string_split(@LocationID,N',')) 
	GROUP BY SH.StockItemCode,SH.Name,LO.Name,CA.Name,SH.Id,SU.Name,SU2.Description
	ORDER BY SH.StockItemCode


  
END

GO

