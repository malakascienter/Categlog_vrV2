CREATE PROCEDURE [dbo].[TourGuide_M_Select]   
	@isActive INT=2,
	@PropertyId INT
AS  
BEGIN  


 SELECT H.*,C.Description AS TourGuideCompaniesName
  FROM [dbo].[TourGuideMaster] H INNER JOIN TourGuideCompanies C ON H.TourGuideCompaniesId = C.Id
  WHERE  H.PropertyId=@PropertyId AND (@IsActive=2 OR H.IsActive=@isActive) AND H.IsDelete = 0
  Order By  Description
  
END

GO

