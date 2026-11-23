-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-04-22
-- Description:	CheckContractedSupplierExists

-- [dbo].[SP_CheckContractedSupplierExists] 1,1,1,1

-- =============================================
CREATE PROCEDURE [dbo].[SP_CheckContractedSupplierExists]
	@StockitemID INT,
	@SupplierID INT,
	@PropertyID INT,
	@LocationID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ContractSupplierID INT

	SELECT TOP (1) @ContractSupplierID = SupplierID
	FROM SupplierWiseItemDetails
	WHERE CompanyId =@PropertyID
	AND LocationId = @LocationID
	AND StockItemID = @StockitemID
	AND IsContractedSupplier =1
	ORDER BY CostPrice ASC

	IF(@SupplierID = @ContractSupplierID)
	BEGIN

	SELECT @ContractSupplierID ContractSupplierID,SU.Name SupName,SW.CostPrice,1 as Result
	FROM SupplierWiseItemDetails SW
	INNER JOIN SUPPLIERS SU ON SU.ID = SW.SupplierID
	WHERE SU.ID = @ContractSupplierID
	AND SW.CompanyId =@PropertyID
	AND SW.LocationId = @LocationID
	AND SW.StockItemID = @StockitemID
	AND CONVERT(DATE,GETDATE()) BETWEEN SW.Validfrom AND SW.ValidTo


	END
	ELSE
	BEGIN
	SELECT @ContractSupplierID ContractSupplierID,SU.Name SupName,SW.CostPrice,0 as Result
	FROM SupplierWiseItemDetails SW
	INNER JOIN SUPPLIERS SU ON SU.ID = SW.SupplierID
	WHERE SU.ID = @ContractSupplierID
	AND SW.CompanyId =@PropertyID
	AND SW.LocationId = @LocationID
	AND SW.StockItemID = @StockitemID
	AND CONVERT(DATE,GETDATE()) BETWEEN SW.Validfrom AND SW.ValidTo
	END

   
END

GO

