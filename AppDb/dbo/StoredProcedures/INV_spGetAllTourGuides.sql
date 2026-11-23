
-- [dbo].[INV_spGetAllTourGuides] 1,0

CREATE PROCEDURE [dbo].[INV_spGetAllTourGuides]
@PropertyId INT,
@IsAll BIT = 1
AS
BEGIN
    SELECT	CreatedUserId AS UserId,	Id AS Id,	TourGuideCompaniesId AS TourGuideCompaniesId,	Code AS Code,	Description AS Description,
	NIC AS NIC,	ContactNo As ContactNo,	Email AS Email,	IsActive AS IsActive,	PropertyId As PropertyId,	CommissionPercentage As CommissionPercentage,Module As Module
    ,TourGuideLicense,Address,BankName,Branch,BankAccount,TourGuideTypeID
    FROM TourGuideMaster 
    WHERE IsDelete = 0  -- Only active records
    AND PropertyId= @PropertyId
    AND ISNULL(IsApproved,0) =CASE WHEN @IsAll = 0 THEN 1 ELSE  ISNULL(IsApproved,0) END
  --  AND Module = 'I'

END

GO

