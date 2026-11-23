
--select [dbo].[FN_GetNewBalVal] (4,4,'gr',1500,1200)
--go
CREATE   FUNCTION  [dbo].[FN_GetNewBalVal]
(
@ItemID INT,
@LocationID INT,
@TxnType CHAR(5),
@Quantity DECIMAL(38,8),
@UntPrice DECIMAL(38,8))

RETURNS DECIMAL(38,8)
AS
BEGIN
	DECLARE @NewBalVal DECIMAL(38,8), @LastVal DECIMAL(38,8);

	SELECT TOP(1)  @LastVal = SD.BalVal
	FROM StockTransactionDetails  SD
	INNER JOIN StockTransactionHeaders SH ON SH.Id = SD.StockTransactionHeaderID
	WHERE SD.StockItemID = @ItemID AND SH.LocationID = @LocationID
	ORDER BY SH.TransactionDate,SD.CreatedDate DESC

	IF(@LastVal IS NULL)
		SET @LastVal = 0

	SET @NewBalVal  = @LastVal + CASE
					  WHEN @TxnType IN ('GR','TI','RI','RC','IR','AA','PU','BR') THEN  @Quantity*@UntPrice --'BR' added by Tharuka 2026-09-15 : Franchise Return
					  WHEN @TxnType IN ('SR','TO','II','IN','AAM','DN','IF','PI','FW','BI') THEN -@Quantity*@UntPrice END


	RETURN @NewBalVal

END

GO

