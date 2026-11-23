-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--SP_GetAllOrderDetailsById 6
CREATE PROCEDURE [dbo].[SP_GetAllOrderDetailsById] 
	@OrderHeaderID INT 
AS
BEGIN 
SELECT OD.Id AS Id,OrderHeaderID,ProductID,OrderQty,IssueQty,BalanceQty,ConvertFactor,UnitID,Total,OD.TaxGroupID AS TaxGroupID,TaxValue,IsPercentageForDiscount,ItemDiscountValue,ItemDiscountRate,NetTotal,OH.CompanyID,OH.LocationID,SD.Name AS productName,U.Name AS UnitName, OH.GrossAmount AS GrossAmount, OH.TotalDiscount AS TotalDiscount, OH.NetAmount AS  NetAmount,SDH.SellingPrice
FROM dbo.OrderDetails OD 
INNER JOIN dbo.StockItemHeaders SD ON SD.Id=OD.ProductID 
INNER JOIN dbo.Units U ON U.Id=OD.UnitID 
INNER JOIN OrderHeaders OH ON OH.Id = OD.OrderHeaderID
INNER JOIN StockItemDetails SDH on SDH.StockItemHeaderID=OD.ProductID and SDH.LocationID=OH.locationID WHERE OD.OrderHeaderID=@OrderHeaderID 



END

--select * from orderheaders 
--select * from OrderDetails 
--select * from StockItemDetails

GO

