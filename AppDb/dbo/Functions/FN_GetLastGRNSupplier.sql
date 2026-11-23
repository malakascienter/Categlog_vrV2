-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-02-01
-- Description:	Loading Last GRN Supplier
-- =============================================
CREATE FUNCTION [dbo].[FN_GetLastGRNSupplier]
   ( 
      @LocationID INT,
      @StockItemID INT ,
	  @Date DATE
    )
RETURNS  VARCHAR(MAX)
AS
    BEGIN
        DECLARE @LastGRNSupplier  VARCHAR(MAX);

		SELECT TOP(1)@LastGRNSupplier=  SU.Name
		FROM StockTransactionHeaders SH
		INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID
		INNER JOIN Suppliers SU ON SU.ID = SH.SupplierID
		WHERE SH.TransactionType='GR' 
		AND SD.StockItemID=@StockItemID
		AND SH.LocationID = CASE WHEN @LocationID =-999 THEN SH.LocationID ELSE @LocationID END
		AND SH.TransactionDate <=@Date
		ORDER BY SH.CreatedDate DESC

		RETURN ISNULL(@LastGRNSupplier,'')
    END

GO

