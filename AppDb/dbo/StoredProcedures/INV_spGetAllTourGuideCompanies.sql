-- =============================================
-- Author:		Isuru Pramodya
-- Create date:	2025-08-04
-- Description:	Get All TourGuide Companies
-- [dbo].[INV_spGetAllTourGuideCompanies] -999

-- =============================================
CREATE PROCEDURE [dbo].[INV_spGetAllTourGuideCompanies]
(@ID INT =-999,@propertyId INT)
AS
BEGIN
	SET NOCOUNT ON;

     SELECT Id,Code,Description,CommissionPercentage,ContactNo,Email,IsActive, CASE WHEN Module = 'I' THEN 'Inventory' ELSE 'POS BackEnd' end as Module,IsDelete
	 ,BankName,BranchName,AccountNo,CompanyRegistrationNo
	FROM TourGuideCompanies
	WHERE ID = CASE WHEN  @ID =-999 THEN ID ELSE @ID END
	AND ISNULL(IsDelete,0) = 0
	--AND Module = 'I'
	AND IsActive = 1 
	AND PropertyId  = @propertyId
END

GO

