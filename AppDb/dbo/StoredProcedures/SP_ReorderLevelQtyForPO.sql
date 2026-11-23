-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-08-15
-- Description:	Re-Order Reached items for PO

-- [dbo].[SP_ReorderLevelQtyForPO] 4,-999,1
-- =============================================
CREATE PROCEDURE [dbo].[SP_ReorderLevelQtyForPO]
	@locationID INT,
	@categoryid INT,
	@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;

	     DECLARE @Temp TABLE
						(
						 UniqueId			    INT IDENTITY(1,1) NOT NULL,
						 RequestHeaderID        INT,
						 LocationID             INT,
						 DocumentNo             VARCHAR(50),
						 RequestDate            DATETIME,
						 DeliveryDate			DATETIME,
						 HRemarks               VARCHAR(500),
						 DepartmentID           INT,
						 DepartmentName         VARCHAR(200),
						 StockItemID            INT,
						 ItemName               VARCHAR(200),
						 StockItemCode          VARCHAR(50),
						 UnitID                 INT,
						 UnitName               VARCHAR(200),
						 ApprovedQuantity       MONEY,
						 ItemRemarks            VARCHAR(200),
						 RequestedQuantity      MONEY,
						 SupplierPurchaseUnitID INT,
						 Supplier               VARCHAR(200),
						 CostPrice              MONEY,
						 SupplierID             INT,
						 LocationName           VARCHAR(200),
						 TenderBoardHeaderNo	varchar(200),
						 TenderBoardHeaderId	int,
						 Urgent					BIT,
						 ApprovedDate VARCHAR(30),
						 QtyInHand decimal(18,6),
						 ItemTaxAmount decimal(18,6)
						);


	INSERT INTO @Temp(ApprovedDate,ApprovedQuantity,CostPrice,DeliveryDate,DepartmentID,DepartmentName,DocumentNo,HRemarks,ItemName,ItemRemarks,ItemTaxAmount,LocationID,LocationName,QtyInHand,RequestDate,RequestHeaderID,RequestedQuantity,
					 StockItemCode,StockItemID,Supplier,SupplierID,SupplierPurchaseUnitID,TenderBoardHeaderId,TenderBoardHeaderNo,UnitID,UnitName,Urgent)

	SELECT ''ApprovedDate,SD.ReOrderQuantity ApprovedQuantity,0 CostPrice,CONVERT(DATE,GETDATE()) DeliveryDate,CO.DefaultDepartmentID DepartmentID,DEP.Name DepartmentName,'' DocumentNo,'' HRemarks,SH.Name ItemName,SH.Remarks ItemRemarks,
	 0 ItemTaxAmount,SD.LocationID,LO.Name LocationName,SD.QuantityInHand QtyInHand,CONVERT(DATE,GETDATE())   RequestDate,0 RequestHeaderID,SD.ReOrderQuantity RequestedQuantity,
	 SH.StockItemCode,SH.Id StockItemID,'' Supplier,0 SupplierID,0 SupplierPurchaseUnitID,0 TenderBoardHeaderId,NULL TenderBoardHeaderNo,U.Id UnitID,U.Name UnitName,0 Urgent

	--LO.Name LocationName,SH.StockItemCode,SH.Name ItemName,U.Name UnitName,SD.QuantityInHand,SD.ReOrderLevel,sd.ReOrderQuantity
	--,SH.Id StockItemID,SD.LocationID,CASE WHEN  SD.QuantityInHand < SD.ReOrderLevel THEN 1 WHEN SD.QuantityInHand = SD.ReOrderLevel THEN 2 END AS Level
	--,CO.Name CompanyName
	FROM StockItemHeaders SH
	INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID
	INNER JOIN Locations LO ON LO.Id = SD.LocationID
	INNER JOIN Units U ON U.Id = SD.MasterUnitID
	INNER JOIN Companies CO ON CO.CompanyID = SH.CompanyId
	INNER JOIN Departments DEP ON CO.DefaultDepartmentID = DEP.Id
	WHERE SH.CompanyId = @PropertyID AND SD.ReOrderLevel>0
	AND SD.QuantityInHand <= SD.ReOrderLevel
	AND SD.LocationID = CASE WHEN @locationID=-999 THEN SD.LocationID ELSE @locationID END
	AND SH.CategoryID = CASE WHEN @categoryid=-999 THEN SH.CategoryID ELSE @categoryid END
	ORDER BY SD.QuantityInHand ASC

	


	UPDATE TP
	SET TP.Supplier = SU.Name, TP.SupplierID = SU.ID,TP.SupplierPurchaseUnitID = SUP.PurchaseUnitID,TP.CostPrice = SUP.COSTPRICE
	FROM @Temp TP
	INNER JOIN SupplierWiseItemDetails SUP ON TP.StockItemID = SUP.StockItemID AND TP.LocationID = SUP.LocationId
	INNER JOIN Suppliers SU ON SU.ID = SUP.SupplierID
	WHERE SUP.LocationId = @locationID AND SUP.CompanyId = @PropertyID

	SELECT *
	FROM @Temp TP


	

    
END

GO

