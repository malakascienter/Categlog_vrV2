
CREATE  PROCEDURE [dbo].[ItemImage_M_Select_ById]
	@MenuitemId NVARCHAR(10),
	@PropertyId INT
AS  
BEGIN  
	SELECT [Code]
      ,[DataType]
      ,[ItemImage]
	  ,ImageName
  FROM [dbo].[POS_Image] 
  WHERE [Code] = @MenuitemId AND [DataType] = 'ITM' AND PropertyId = @PropertyId
END

GO

