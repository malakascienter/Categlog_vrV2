CREATE PROCEDURE [dbo].[POS_spGetAllTourGuides]
@CompanyId INT = 0
AS 
SET NOCOUNT ON

SELECT	G.ID AS GuidID, G.TourGuideCompaniesId AS CompanyID, G.Code AS Code, G.Description AS Name, G.NIC, C.Description AS Copmany,
		G.CommissionPercentage AS GuidePercentage, C.CommissionPercentage AS GuideCompanyPercentage
FROM	TourGuideMaster AS G INNER JOIN TourGuideCompanies AS C ON G.TourGuideCompaniesId = C.Id
WHERE	G.IsActive = 1

GO

