
-- =============================================
-- Author:		Dilshan
-- Create date: 2025-10-14
-- Description:	SpeacialOrderRevamp
-- =============================================
CREATE PROCEDURE [dbo].[SPO_spGetAllCustomerTypes]
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;

	SELECT ID,CustomerTypeName,IsActive AS isActive,isEnableCompanyDetails,isEnableEmployeeDetails,isEnableCreditDetails,IsCustomerApprove FROM SPO_CustomerType

    
END

GO

