CREATE PROCEDURE [dbo].[SP_DeleteProcumentRequestDetails]
@UniqueId AS INT,
@PropertyID AS INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcurementID AS BIGINT
	SELECT @ProcurementID = ProcurementID FROM [SupplierQuotation] WHERE  Id = @UniqueId

	DELETE FROM [SupplierQuotation]  WHERE ID = @UniqueId


	select * from [SupplierQuotation] where ProcurementID =  @ProcurementID
	 
END

GO

