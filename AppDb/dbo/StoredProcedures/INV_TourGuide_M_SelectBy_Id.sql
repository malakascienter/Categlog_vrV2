
CREATE PROCEDURE [dbo].[INV_TourGuide_M_SelectBy_Id]
	@Id INT,
	@PropertyId INT
AS
BEGIN

   SET NOCOUNT ON;

   SELECT  Id, TourGuideCompaniesId, Code, Description, NIC, ContactNo, Email, IsActive, IsDelete, PropertyId, IsUpload, CreatedUserId, 
   CreatedDateTime, LastModifiedUserID, LastModifiedDateTime, CommissionPercentage, Module 
   FROM TourGuideMaster WHERE   PropertyId=@PropertyId AND Id=@Id
END

GO

