
CREATE PROCEDURE [dbo].[SP_Get_GetTourGuideWiseDocumentById] 
	@TourGuideId	INT,
	@PropertyId     INT
AS
BEGIN 
	SELECT * 
	FROM TourGuideWiseDocument WHERE TourGuideId =@TourGuideId  AND IsActive = 1
END

GO

