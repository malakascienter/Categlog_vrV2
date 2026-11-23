create PROCEDURE [dbo].[SP_GetPOWiseSupplier](@DocId INT, @Value CHAR(2))
AS
BEGIN
IF(@Value = 'G')
	BEGIN
		SELECT S.Id, S.Name AS SuppName
		FROM PoHeaders PH
		INNER JOIN Suppliers S
		ON PH.SupplierID = S.Id
		WHERE PH.Id = @DocId
	END
IF(@Value = 'S')
BEGIN
	SELECT S.Id, S.Name AS SuppName
	FROM StockTransactionHeaders SH
	INNER JOIN Suppliers S
	ON SH.SupplierID = S.Id
	WHERE SH.Id = @DocId
END
END

GO

