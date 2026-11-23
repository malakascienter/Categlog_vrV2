-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-02-01
-- Description:	Loading ContractedSupplier_ID
-- =============================================
CREATE FUNCTION [dbo].[FN_GetContractedSupplier_ID]
   ( 
    @StockitemID INT,
	@PropertyID INT,
	@LocationID INT
    )
RETURNS  INT
AS
    BEGIN
		DECLARE @ContractSupplierID INT

		SELECT TOP (1) @ContractSupplierID = SupplierID
		FROM SupplierWiseItemDetails
		WHERE CompanyId =@PropertyID
		AND LocationId = @LocationID
		AND StockItemID = @StockitemID
		AND IsContractedSupplier =1
		ORDER BY CostPrice ASC


		RETURN ISNULL(@ContractSupplierID,'')
    END

GO

