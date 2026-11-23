--SP_GetInoviceDetailsList 5185,2
CREATE PROCEDURE [dbo].[SP_GetInoviceDetailsList] 
	-- Add the parameters for the stored procedure here
	@InvoiceHeaderID INT,
	@Operation INT
AS
BEGIN
	
	IF(@Operation=1)
	BEGIN

	SELECT *,SH.Name AS ItemName,U.Name AS UnitName FROM dbo.InvoiceDetails ID INNER JOIN dbo.StockItemHeaders SH ON SH.Id = ID.ItemID
	INNER JOIN dbo.Units U ON U.Id=ID.UnitID 	
	WHERE InvoiceHeaderID=@InvoiceHeaderID

    END
	
	ELSE 

	BEGIN

	SELECT *,ID.ID,SH.Name AS ItemName,U.Name AS UnitName FROM dbo.Temp_InvoiceDetail ID INNER JOIN dbo.StockItemHeaders SH ON SH.Id = ID.ItemID
	INNER JOIN dbo.Units U ON U.Id=ID.UnitID 	
	WHERE InvoiceHeaderID=@InvoiceHeaderID

	end 
END

GO

