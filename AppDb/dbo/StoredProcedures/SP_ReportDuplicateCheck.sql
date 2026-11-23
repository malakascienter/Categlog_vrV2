
CREATE PROCEDURE [dbo].[SP_ReportDuplicateCheck] --2155,1
	@HeaderID INT,
	@TransactionType INT
AS
BEGIN
	IF(@TransactionType = '3' OR @TransactionType = '5' OR @TransactionType = '6' OR @TransactionType = '13')
BEGIN
	SELECT IsPrint
	FROM dbo.StockTransactionHeaders
	WHERE id = @HeaderID AND TransactionID= @TransactionType
	
	END
    ELSE IF  (@TransactionType = '1' OR @TransactionType = '8' OR @TransactionType = '11' OR @TransactionType = '14')
	BEGIN
	select Isprint 
	from dbo.RequestHeaders 
	WHERE id = @HeaderID AND TransactionTypeCode = @TransactionType
	
	END
    ELSE IF  (@TransactionType = '2')
	BEGIN
	select Isprint
	from dbo.PoHeaders 
	WHERE id = @HeaderID 
	
	END
END

GO

