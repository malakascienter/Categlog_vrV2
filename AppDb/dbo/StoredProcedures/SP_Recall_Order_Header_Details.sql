CREATE PROCEDURE [dbo].[SP_Recall_Order_Header_Details]
	@headerID int
AS
BEGIN
	SELECT od.OrderQty AS RequestedQuantity , OD.SellingPrice AS UnitPrice , (SELECT U.Code FROM dbo.Units AS U WHERE OD.UnitID=u.Id ) AS UnitName, SIH.Name AS ItemName, OD.ProductId AS StockItemID ,OD.ApprovedQuantity AS ApprovedQuantity,
	OD.Id AS RequestDetailID, OD.Id, OD.IsPercentageForDiscount AS IsPercentageForDiscount, OD.ItemDiscountRate AS DiscountPercentage, OD.ItemDiscountValue AS DiscountValue, OD.TaxValue AS TaxValue  --OH.NetAmount AS NetAmount

	FROM OrderDetails OD Inner JOIN  StockItemHeaders SIH ON OD.ProductID = SIH.Id
	-- Inner join OrderHeaders OH ON OD.OrderHeaderID = OH.Id
	--select * from OrderDetails
	WHERE OD.OrderHeaderID = @headerID
	END

	--select * from OrderDetails

GO

