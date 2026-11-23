
--===========================================
-- Author:		Chiraj
-- Create date: 2020-6-16
-- Description:	OutletWiseMenuItem_M_SelectBy_OutletId
-- =============================================
CREATE PROCEDURE [dbo].[OutletWiseMenuItem_M_SelectBy_OutletId]
	@OutletCode VARCHAR(3),
	@PropertyId INT
AS
BEGIN
	
  SET NOCOUNT ON;

  DELETE FROM [dbo].[Temp_POS_OutletWiseMenuItems]

  --SELECT * FROM  [dbo].[POS_OutletWiseMenuItems] 
  --WHERE OutletCode=@OutletCode AND PropertyId=@PropertyId

  INSERT INTO [dbo].[Temp_POS_OutletWiseMenuItems]
           ([OutletCode]
           ,[MenuCode]
           ,[IsUpload]
           ,[PropertyId]
           ,[CreatedUserId]
           ,[CreatedDateTime]
           ,[ModifyUserId]
           ,[ModifiedDateTime])

  SELECT     [OutletCode]
		    ,[MenuCode]
		    ,[IsUpload]
		    ,[PropertyId]
		    ,[CreatedUserId]
		    ,[CreatedDateTime]
		    ,[ModifyUserId]
		    ,[ModifiedDateTime]
  FROM  [dbo].[POS_OutletWiseMenuItems] 
  WHERE OutletCode=@OutletCode AND PropertyId=@PropertyId

  SELECT * FROM  [dbo].[Temp_POS_OutletWiseMenuItems] 

END

GO

