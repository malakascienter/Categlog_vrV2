CREATE PROCEDURE [dbo].[SP_Credit_Approval_Details]
	@headerID int
AS
BEGIN
	--SELECT od.OrderQty AS RequestedQuantity , OD.SellingPrice AS UnitPrice , (SELECT U.Code FROM dbo.Units AS U WHERE OD.UnitID=u.Id ) AS UnitName, SIH.Name AS ItemName, OD.ProductId AS StockItemID ,OD.ApprovedQuantity AS ApprovedQuantity,
	--OD.Id AS RequestDetailID, OD.Id

	SELECT C.CustomerName , C.LocationId ,C.CreditLimit,CA.CRNumber ,CA.Amount ,CA.CRNumber 
	FROM CreditApprovals CA Inner Join Customers C ON CA.CustomerId = C.Id
	WHERE CA.Id = @headerID
	
	END

	
--SELECT * FROM CreditApprovals  

GO

