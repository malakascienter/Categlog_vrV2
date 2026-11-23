-- =============================================
-- Author:		VInuki
-- Create date: 01.06.2024
-- Description:	<Description,,>
--SP_GetAddedDetails 1229
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetAddedDetails] (@POHeaderID int)

AS
BEGIN

	SELECT 
		PO.PaymentTermsDetailID as PaymentMethodID, 
		PO.SupplierReferenceNo as SupplierReferenceNo,
		(
			SELECT 
			AD.Name AS Name,
            PC.AdditionalChargeID ,
            PC.ChargeAmount

			
			FROM 
				AdditionalChargesDetails AD
			INNER JOIN 
				POwiseCharges PC ON AD.Id = PC.AdditionalChargeID
			WHERE 
				PC.POHeaderID = PO.id
			FOR JSON PATH
		) AS Data
	FROM 
		POHeaders PO
	WHERE 
		PO.id = @POHeaderID



END

GO

