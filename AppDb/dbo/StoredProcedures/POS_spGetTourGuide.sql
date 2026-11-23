
CREATE PROCEDURE [dbo].[POS_spGetTourGuide]
@GuidID INT
AS 
SET NOCOUNT ON

SELECT	G.Code AS Code, G.Description AS Name, G.NIC, C.Description AS Copmany
FROM	TourGuideMaster AS G INNER JOIN TourGuideCompanies AS C ON G.TourGuideCompaniesId = C.Id
WHERE	G.ID = @GuidID

GO

