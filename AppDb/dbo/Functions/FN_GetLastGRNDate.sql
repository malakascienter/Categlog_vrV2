-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-01-31
-- Description:	Get Last GRN Date
-- =============================================
CREATE FUNCTION  [dbo].[FN_GetLastGRNDate](@StockItemID INT,@LocationID INT ,@Date DATETIME) 

RETURNS DATE
AS
BEGIN
 DECLARE @GRNDate DATE

SELECT TOP (1) @GRNDate=  SH.TransactionDate
 FROM StockTransactionDetails SD
 INNER JOIN StockTransactionHeaders SH 
 ON SD.StockTransactionHeaderID =SH.Id
 WHERE SH.LocationID = @LocationId AND SH.TransactionType = 'GR' AND SD.StockItemID = @StockItemId AND SH.TransactionDate<=@Date
 order by SH.CREATEDDATE DESC

 RETURN @GRNDate;

END

GO

