--select * from projectdetails
-- GetItemWiseSupplierPrice 1,19

CREATE PROCEDURE [dbo].[GetItemWiseSupplierPrice]
@ItemId INT,@ProjectId INT
AS
BEGIN


	SELECT DISTINCT PW.SupplierID,S.Name INTO #suppliers from Suppliers as S 
	INNER join ProjectWiseSupplierPrices as PW on  S.ID=PW.SupplierID 
	WHERE PW.ProjectID=@ProjectID ORDER BY PW.SupplierID

	DECLARE @MinSupID INT,@MinPrice MONEY
    


   Select @MinPrice = Min(Price) from ( SELECT  MIN(ISNULL(Price,0)) Price FROM #suppliers s 
	LEFT OUTER JOIN   ProjectWiseSupplierPrices  P
	ON S.SupplierId=P.SupplierId AND ProjectId=@ProjectId AND StockItemID=@ItemId 
	WHERE ISNULL(Price,0)<>0
	GROUP BY s.supplierid ) TT



	SELECT  @MinSupID = S.SupplierId FROM #suppliers s 
	LEFT OUTER JOIN   ProjectWiseSupplierPrices  P
	ON S.SupplierId=P.SupplierId AND ProjectId=@ProjectId AND StockItemID=@ItemId 
	WHERE price= @MinPrice 

	--SELECT @MinPrice,@MinSupID

	SELECT s.SupplierId,StockItemId,ISNULL(Price,0) Price , @MinSupID IsDefault FROM #suppliers s 
	LEFT OUTER JOIN   ProjectWiseSupplierPrices  P
	ON S.SupplierId=P.SupplierId AND ProjectId=@ProjectId AND StockItemID=@ItemId 
	 
	ORDER BY SupplierID



END

--SELECT * FROM ProjectWiseSupplierPrices WHERE projectID=2

GO

