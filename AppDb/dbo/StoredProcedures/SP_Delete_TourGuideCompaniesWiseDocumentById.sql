
CREATE PROCEDURE [dbo].[SP_Delete_TourGuideCompaniesWiseDocumentById] 
	@Id	INT,
	@PropertyId     INT
AS
BEGIN 

	UPDATE TourGuideCompaniesWiseDocument
	SET IsActive = 0
	WHERE Id =@Id
	
END

GO

