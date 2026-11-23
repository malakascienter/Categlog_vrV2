

-- =============================================
-- Author:		Chiraj	
-- Create date: 2018-11-05
-- Description:	Select item category
-- =============================================
CREATE PROCEDURE [dbo].[ItemCategory_M_Select]
	@isActive INT=2,
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;
  SELECT [Id]
      ,[Code]
      ,[Name]
      ,[IsActive]
  FROM [ItemCategory]
  WHERE PropertyId=@PropertyId AND( @IsActive=2 OR IsActive=@isActive ) Order By Id Desc, CAST(Code AS INT) 

   
END

GO

