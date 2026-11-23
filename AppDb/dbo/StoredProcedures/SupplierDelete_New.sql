-- =============================================
-- Author:		Nivesh
-- Create date: 2023.09.06
-- =============================================
--SupplierDelete_New 555,4168

CREATE PROCEDURE [dbo].[SupplierDelete_New] 
(
@SupplierID INT,
@UserID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RowCount INT;

    SELECT @RowCount = COUNT(*)
    FROM (
        SELECT DISTINCT s.Code 
        FROM PoHeaders ph
        INNER JOIN Suppliers s ON ph.SupplierID = s.ID
        WHERE ph.SupplierID = @SupplierID

        UNION ALL

        SELECT DISTINCT s.Code
        FROM StockTransactionHeaders sh
        INNER JOIN Suppliers s ON sh.SupplierID = s.ID
        WHERE sh.SupplierID = @SupplierID

        UNION ALL

        SELECT DISTINCT s.Code
        FROM [dbo].[SupplierWiseItemDetails] SP
        INNER JOIN Suppliers s ON sp.SupplierID = s.ID
        WHERE sp.SupplierID = @SupplierID
    ) AS TotalRows;

    SELECT @RowCount;

	--IF(@RowCount =0)
	--	BEGIN
	--		DELETE 
	--		FROM 
	--		Suppliers 
	--		WHERE Suppliers.ID =@SupplierID 
	--		AND 
	--		Suppliers.CreatedUserID =@UserID
	--	END
END

GO

