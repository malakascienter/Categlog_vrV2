
CREATE PROCEDURE [dbo].[SP_ReportOrginalCheck]
	@HeaderID INT,
	@TransactionType INT
AS
BEGIN
	IF(@TransactionType = '3' OR @TransactionType = '5' OR @TransactionType = '6' OR @TransactionType = '13')
BEGIN
	UPDATE dbo.StockTransactionHeaders 
	SET IsPrint = 1 
	WHERE id = @HeaderID AND TransactionID= @TransactionType
	END
    ELSE IF  (@TransactionType = '1' OR @TransactionType = '8' OR @TransactionType = '11' OR @TransactionType = '14')
	BEGIN
	UPDATE dbo.RequestHeaders 
	SET Isprint = 1 
	WHERE id = @HeaderID AND TransactionTypeCode = @TransactionType
	END
    ELSE IF  (@TransactionType = '2')
	BEGIN
	UPDATE dbo.PoHeaders 
	SET Isprint = 1 
	WHERE id = @HeaderID 
	END
	ELSE IF  (@TransactionType = '-999')
	BEGIN
	UPDATE dbo.InvoiceHeaders 
	SET Isprint = 1 
	WHERE id = @HeaderID 
	END
END

GO

