
-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-02-01
-- Description:	Loading Last GRN Supplier ID
-- =============================================
CREATE FUNCTION [dbo].[FN_GetLastGRNSupplier_ID_BySupplierWiseItemsTable]
   ( 
      @LocationID INT,
      @StockItemID INT 
    )
RETURNS  INT
AS
    BEGIN
        DECLARE @LastGRNSupplierID  INT

		
		SELECT TOP(1)@LastGRNSupplierID= SupplierID
		FROM SUPPLIERWISEITEMDETAILS SU
		WHERE SU.STOCKITEMID=@StockItemID  AND SU.LocationID = CASE WHEN @LocationID =-999 THEN SU.LocationID ELSE @LocationID END
		ORDER BY SU.CreatedDate DESC

		RETURN ISNULL(@LastGRNSupplierID,'')
    END

GO

