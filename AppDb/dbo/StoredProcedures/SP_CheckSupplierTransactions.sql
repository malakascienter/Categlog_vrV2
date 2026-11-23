-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 19 September 2023
-- Description:	Checking Supplier Transactions
-- [dbo].[SP_CheckSupplierTransactions] 2,4168

-- [dbo].[SP_CheckSupplierTransactions] 20,4168
-- =============================================
CREATE PROCEDURE [dbo].[SP_CheckSupplierTransactions] 
(
@SupplierID INT,
@UserID INT
)
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE @RowCount INT;
	--Added by Isuru 2023-10-09 for check AP_Credt table transaction
	DECLARE @BSPCode VARCHAR(100),@CreditorTypeID int

	SELECT @BSPCode =BSPCODE
	FROM Suppliers
	WHERE ID = @SupplierID

	--end

	SELECT @CreditorTypeID= CreditorTypeID FROM Suppliers WHERE ID = @SupplierID
	IF @CreditorTypeID IS NOT NULL
	BEGIN
        SELECT DISTINCT s.Code,'PO Header' TransactionType
        FROM PoHeaders ph
        INNER JOIN Suppliers s ON ph.SupplierID = s.ID
        WHERE ph.SupplierID = @SupplierID

        UNION ALL

        SELECT DISTINCT s.Code,'Stock Transaction' TransactionType
        FROM StockTransactionHeaders sh
        INNER JOIN Suppliers s ON sh.SupplierID = s.ID
        WHERE sh.SupplierID = @SupplierID

        UNION ALL

        SELECT DISTINCT s.Code,'Supplier Wise Item' TransactionType
        FROM [dbo].[SupplierWiseItemDetails] SP
        INNER JOIN Suppliers s ON sp.SupplierID = s.ID
        WHERE sp.SupplierID = @SupplierID

		--Added by Isuru 2023-10-09 for check AP_Credt table transaction
		UNION ALL

		SELECT SU.Code,'GL Transaction' TransactionType
		FROM eFinancials_Accounting..Destinity_AP_CREDT AP
		INNER JOIN Suppliers SU ON SU.BSPCODE = AP.BSPCode
		WHERE AP.BSPCode = @BSPCode

		--End
	END
	ELSE
	BEGIN 
		SELECT '' Code,'' TransactionType
	END
   
END

GO

