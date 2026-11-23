-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 19 september 2023
-- Description:	Supplier Master Report
-- [dbo].[SP_LocWiseSupplierMasterReport] 1,12,1
-- =============================================
CREATE PROCEDURE [dbo].[SP_LocWiseSupplierMasterReport]
	@IsActive int,
	@LocationID int
AS
BEGIN
	SET NOCOUNT ON;

	IF(@LocationID = -999)
	BEGIN

	SELECT SU.ID,PropertyID,Code, SU.Name, Address1, BillingAddress, SU.Email, Telephone1, Telephone2, FaxNo, ContactPerson, Remarks, CreditLimit, CreditPeriod, NameOnCheque, 
         CASE WHEN SU.IsActive = 1 THEN 'Active' ELSE 'Inactive' END  IsActive, VatNo, BSPCODE, AccountNo, Graceperiod, DefaultPaymenttype, Bankcode, 
          BranchCode, CommissionAcc, DeductionControl,CU.UserName, AP.Name CreditorType,IsConsigments
	FROM  Suppliers SU
	LEFT JOIN CentralUsers CU ON CU.Id = SU.CreatedUserID
	LEFT JOIN Destinity_AP_CreditorTypes AP ON SU.CreditorTypeID = AP.ID
	WHERE SU.IsActive= @IsActive
	END
	ELSE
	BEGIN
	SELECT DISTINCT SU.ID,PropertyID,Code, SU.Name, Address1, BillingAddress, SU.Email, Telephone1, Telephone2, FaxNo, ContactPerson, Remarks, CreditLimit, CreditPeriod, NameOnCheque, 
         CASE WHEN SU.IsActive = 1 THEN 'Active' ELSE 'Inactive' END  IsActive, VatNo, BSPCODE, AccountNo, Graceperiod, DefaultPaymenttype, Bankcode, 
          BranchCode, CommissionAcc, DeductionControl,CU.UserName, AP.Name CreditorType,IsConsigments
	FROM  Suppliers SU
	LEFT JOIN CentralUsers CU ON CU.Id = SU.CreatedUserID
	LEFT JOIN Destinity_AP_CreditorTypes AP ON SU.CreditorTypeID = AP.ID
	INNER JOIN SupplierWiseItemDetails SRT ON SRT.SupplierID = SU.ID
	WHERE SU.IsActive= @IsActive AND SRT.LocationId = @LocationID 
	END

END

GO

