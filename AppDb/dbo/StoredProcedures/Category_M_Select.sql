--[dbo].[POS_Category_M_Select]  1,1
CREATE PROCEDURE [dbo].[Category_M_Select]   
	@isActive INT=2,
	@PropertyId INT
AS  
BEGIN  

--RAISERROR('Category Prefix already exists',16,1)  
 SELECT C.[CatgId]
      ,TRIM(C.[Code]) AS Code
	  ,ISNULL(C1.Name, '') +
		CASE 
			WHEN ISNULL(C1.Name, '') <> ''  THEN ' | '
			ELSE ''
		END +
		ISNULL(C2.Name, '') +
		CASE 
			WHEN (ISNULL(C2.Name, '') <> '') THEN ' | '
			ELSE ''
		END +
		ISNULL(C.[Description], '') AS LongDescription
	  ,C.Description
      ,C.[Prefix]
      ,C.[Acc]
      ,C.[ID]
      ,C.[Colour]
      ,C.[Seq]
      ,C.[CatType]
      ,C.[Active]
      ,C.[IsUpload]
      ,C.[PropertyId]
      ,C.[CreatedUserId]
      ,C.[CreatedDateTime]
      ,C.[ModifiedUserId]
      ,C.[ModifiedDateTime]
      ,C.[IsEButlerCategory]
      ,C.[Classification01Id]
      ,C.[Classification02Id]  FROM Category  C
 LEFT JOIN POS_Classification01 C1 ON C.Classification01Id = C1.Id
 LEFT JOIN POS_Classification02 C2 ON C.Classification02Id = C2.Id
  WHERE  C.PropertyId=@PropertyId AND (@IsActive=2 OR C.Active=@isActive)
  Order By  C.Seq--CatgId Desc,Code 
  
END

GO

