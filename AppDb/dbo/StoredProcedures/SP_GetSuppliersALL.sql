-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-09-19
-- Description:	Loading Only IsPettyCash suppliers 
-- [dbo].[SP_GetSuppliersALL] 1
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetSuppliersALL]
	@PropertyID INT
AS
BEGIN
		SET NOCOUNT ON;

		SELECT  ID, PropertyID, Code, Name, Address1, BillingAddress, Email, Telephone1, Telephone2, FaxNo, ContactPerson, CountryID, Remarks, CreditLimit, CreditPeriod, PaymentTermID, CurrencyID, NameOnCheque, SupplierGradingID, 
                  IsDefaultSupplier, IsActive, IPAddress, CreatedUserID, LastModUserID, CreatedDate, LastModDate, IsLabor, IsForeign, VatNo, BSPCODE, AccountNo, GracePeriod, DefaultPaymentType, BankCode, BranchCode, CommissionAcc, 
                  DeductionControl, CreditorTypeID, IsConsigments, IsPettyCash
		FROM     Suppliers
		WHERE IsActive=1-- AND IsPettyCash = 1

    
END

GO

