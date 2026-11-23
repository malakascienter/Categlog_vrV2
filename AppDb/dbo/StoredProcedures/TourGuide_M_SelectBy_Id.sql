
CREATE PROCEDURE [dbo].[TourGuide_M_SelectBy_Id]
	@Id INT,
	@PropertyId INT
AS
BEGIN

   SET NOCOUNT ON;
   SELECT * FROM TourGuideMaster WHERE   PropertyId=@PropertyId AND Id=@Id
END

GO

