
CREATE PROCEDURE [dbo].[TourGuideCompanies_M_SelectBy_Id]
	@Id INT,
	@PropertyId INT
AS
BEGIN

   SET NOCOUNT ON;
   SELECT * FROM TourGuideCompanies WHERE   PropertyId=@PropertyId AND Id=@Id
END

GO

