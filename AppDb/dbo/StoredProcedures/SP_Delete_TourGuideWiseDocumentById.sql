
CREATE PROCEDURE [dbo].[SP_Delete_TourGuideWiseDocumentById] 
	@Id	INT,
	@PropertyId     INT
AS
BEGIN 

	UPDATE TourGuideWiseDocument
	SET IsActive = 0
	WHERE Id =@Id
	
END

GO

