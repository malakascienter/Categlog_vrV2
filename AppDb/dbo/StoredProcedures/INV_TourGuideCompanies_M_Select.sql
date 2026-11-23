-- [dbo].[INV_TourGuideCompanies_M_Select] 1,1

CREATE PROCEDURE [dbo].[INV_TourGuideCompanies_M_Select]   
	@isActive INT=2,
	@PropertyId INT
AS  
BEGIN  


 SELECT [Id]
      ,[Code]
      ,[Description]
      ,[CommissionPercentage]
      ,[ContactNo]
      ,[Email]
      ,[IsActive]
      ,[PropertyId]
      ,[IsUpload]
      ,[CreatedUserId]
      ,[CreatedDateTime]
      ,[LastModifiedUserID]
      ,[LastModifiedDateTime]
  FROM [dbo].[TourGuideCompanies]
  WHERE  PropertyId=@PropertyId AND (@IsActive=2 OR IsActive=@isActive) AND IsDelete = 0
  AND ISNULL(IsApproved,0) = 1
 -- AND Module = 'I'
  Order By  Description
  
END

GO

