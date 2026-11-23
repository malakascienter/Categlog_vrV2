-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-08-12
-- Description: Get Last GRN Supplier ID, Supplier, Date , Qty and Price
-- =============================================

CREATE   FUNCTION [dbo].[FN_GetLastGRNDetails]
(
    @LocationID   INT,
    @StockItemID  INT,
    @PropertyID   INT,
    @Date         DATE = NULL,  
    @SupplierID   INT  = NULL 
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (1)
        SH.TransactionDate  AS LastGRNDate,
        SH.SupplierID       AS LastGRNSupplierID,
        SU.Name             AS LastGRNSupplier,
        SD.Quantity         AS LastGRNQuantity,
        SD.UnitPrice        AS LastGRNPrice
    FROM StockTransactionDetails SD
    INNER JOIN StockTransactionHeaders SH ON SD.StockTransactionHeaderID = SH.Id
    INNER JOIN Suppliers SU ON SU.ID = SH.SupplierID
    WHERE SH.TransactionType = 'GR'
      AND SD.StockItemID = @StockItemID
      AND SH.LocationID = CASE WHEN @LocationID = -999 THEN SH.LocationID ELSE @LocationID END
      AND (@Date IS NULL OR SH.TransactionDate <= @Date)
      AND (@SupplierID IS NULL OR SH.SupplierID = @SupplierID)
      AND SH.PropertyID = @PropertyID
      --AND SH.DepartmentID = @DepartmentID
    ORDER BY SH.TransactionDate DESC, SH.CreatedDate DESC, SD.Id DESC
);

GO

