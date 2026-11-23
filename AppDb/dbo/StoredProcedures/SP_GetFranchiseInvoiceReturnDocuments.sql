-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-09-15
-- Description:	get all BI and GRN documents to the return

-- EXEC dbo.SP_GetFranchiseInvoiceReturnDocuments 1,1,273

-- =============================================

CREATE   PROCEDURE dbo.SP_GetFranchiseInvoiceReturnDocuments
    @Propertyid   INT,
    @Locationid   INT,
    @Departmentid INT,
    @IsSR         BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Locationid2 INT;
    SELECT @Locationid2 = Id
    FROM Locations WHERE DepartmentID = @Departmentid AND PropertyId = @Propertyid

    SELECT
        SH.Id                                                          AS StockTransactionHeaderID,
        SH.DocumentNo,
        SH.TransactionDate,
        SH.TaxInvoiceNumber,
        SH.InvoiceLocationID                                           AS FranchiseLocationID,
        SH.InvoiceDocStatus,
        SH.DocumentNo + ' | ' + CONVERT(VARCHAR(10), SH.TransactionDate, 120) AS DisplayText
    FROM StockTransactionHeaders SH
    WHERE SH.PropertyID      = @Propertyid
      AND SH.TransactionType = 'BI'
      AND SH.IsInvoiceBasedTransaction = 1
      AND SH.LocationID      = @Locationid
      AND SH.DepartmentID    = @Departmentid
      --AND SH.InvoiceDocStatus <> 'X' OR NULL
      AND @IsSR = 0 

      AND EXISTS (
            SELECT 1
            FROM   StockTransactionDetails SD
            WHERE  SD.StockTransactionHeaderID = SH.Id
              AND  SD.Quantity - ISNULL(SD.ReturnQuantity, 0) > 0
          )
    --ORDER BY SH.Id DESC;

    UNION

    SELECT
        SH.Id                                                          AS StockTransactionHeaderID,
        SH.DocumentNo,
        SH.TransactionDate,
        SH.TaxInvoiceNumber,
        SH.InvoiceLocationID                                           AS FranchiseLocationID,
        SH.InvoiceDocStatus,
        SH.DocumentNo + ' | ' + CONVERT(VARCHAR(10), SH.TransactionDate, 120) AS DisplayText
    FROM StockTransactionHeaders SH
    WHERE SH.PropertyID      = @Propertyid
      AND SH.TransactionType = 'SR'
      AND SH.IsInvoiceBasedTransaction = 1
      AND SH.LocationID      = @Locationid2
    
      AND @IsSR = 1 

      AND EXISTS (
            SELECT 1
            FROM   StockTransactionDetails SD
            WHERE  SD.StockTransactionHeaderID = SH.Id
              AND  SD.Quantity - ISNULL(SD.ReturnQuantity, 0) > 0
          )
    ORDER BY SH.Id DESC;


END

GO

