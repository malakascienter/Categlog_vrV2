
CREATE PROCEDURE [dbo].[SP_Get_GetTourGuideCompaniesWiseDocumentById] 
	@TourGuideCompaniesId	INT,
	@PropertyId     INT
AS
BEGIN 
	SELECT * 
	FROM [TourGuideCompaniesWiseDocument] WHERE TourGuideCompaniesId =@TourGuideCompaniesId  AND IsActive = 1
END

GO

