-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-09-12
-- Description:	Loading PO for Re-Call
-- [dbo].[GetPOForReCall] 1
-- [dbo].[GetPOForReCall]  1,607,4
-- =============================================
CREATE PROCEDURE [dbo].[GetPOForReCall] 
	@PropertyID INT,
	@SupplierID INT,
	@LocationID INT

	AS
BEGIN
	SET NOCOUNT ON;

    SELECT Id,CONCAT(PoNo,' | ',CONVERT(DATE,DocumentDate)) PONO
	FROM PoHeaders
	WHERE PropertyID = @PropertyID 
	AND LocationID = @LocationID AND SupplierID = @SupplierID
	ORDER BY ID DESC
END

GO

