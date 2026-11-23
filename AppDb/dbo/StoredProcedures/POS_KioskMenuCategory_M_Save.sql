
CREATE PROCEDURE [dbo].[POS_KioskMenuCategory_M_Save]
(
	@CategoryID INT,
	@CategoryName NVARCHAR(100),
	@SortOrder	INT,
	@IsActive BIT,
	@UserId INT = -1,
	@Operation CHAR(1),
	@Image Image,
	@IsChangeImage bit,
	@ItemType  CHAR(1),
	@PropertyId INT,
	@ImageName VARCHAR(100)
	
)

AS
BEGIN
SET NOCOUNT ON;
	IF(@Operation = 'I')
		BEGIN

		 IF NOT EXISTS (SELECT 1 FROM POS_KioskMenuCategory WHERE SortOrder = @SortOrder)
		 BEGIN
		   	  INSERT INTO [dbo].[POS_KioskMenuCategory]
              ([CategoryName]
              ,[SortOrder]
              ,[IsActive]
              ,[CreatedUserId]
              ,[CreatedDateTime]
              ,[LastEditedUserId]
              ,[LastEditedDateTime]
			  ,ItemType
			  ,PropertyId)
		   	  VALUES
              (@CategoryName
              ,@SortOrder
              ,@IsActive
              ,@UserId
              ,GETDATE()
              ,@UserId
              ,GETDATE()
			  ,@ItemType
			  ,@PropertyId)
		   
		   DECLARE @Id AS INT
		   SET @Id = SCOPE_IDENTITY()

		   INSERT INTO [dbo].[POS_Image]
           ([Code]
           ,[DataType]
           ,[ItemImage]
		   ,PropertyId
		   ,ImageName)
		   VALUES
           (@Id
           ,'CAT'
           ,@Image
		   ,@PropertyId
		   ,CONCAT(@Id,'_',@ImageName))


		   --TRANSFER FROM HO TO OUTLET SYNC
			INSERT INTO Sync_MasterDataTransferStatus
			SELECT @PropertyId,A.CategoryID, B.code, 'KioskCat', @IsActive
			FROM (SELECT @Id AS CategoryID) A
			CROSS JOIN Location_Ref B WHERE B.Active = 1

		  END
		  ELSE
		  BEGIN
			RAISERROR('Sequence already exists.',16,1)
		  END	

         END
		 ELSE IF(@Operation = 'U')
		 BEGIN
		 IF EXISTS (SELECT 1 FROM POS_KioskMenuCategory WHERE CategoryID = @CategoryID)
		 BEGIN
		   --DECLARE @Id AS INT
		   
		   IF NOT EXISTS (SELECT 1 FROM POS_KioskMenuCategory WHERE SortOrder = @SortOrder AND CategoryID != @CategoryID)
		   BEGIN

		   	   UPDATE [dbo].[POS_KioskMenuCategory]
			   SET [CategoryName] = @CategoryName
			  ,[SortOrder] = @SortOrder
			  ,[IsActive] = @IsActive
			  ,[LastEditedUserId] = @UserId
			  ,[LastEditedDateTime] = GETDATE()
			  ,[ItemType] = @ItemType
			  ,PropertyId = @PropertyId
			   WHERE CategoryID = @CategoryID

			   IF @IsChangeImage = 1
			   BEGIN
					UPDATE [dbo].[POS_Image]
					SET [DataType] =  'CAT'
					   ,[ItemImage] = @Image
					WHERE [Code] = @CategoryID AND  [DataType] =  'CAT'
			   END
			   ELSE
			   BEGIN
					UPDATE [dbo].[POS_Image]
					SET [DataType] =  'CAT'
					   --,[ItemImage] = @Image
					WHERE [Code] = @CategoryID AND  [DataType] =  'CAT'
			   END

			   --TRANSFER FROM HO TO OUTLET SYNC
				INSERT INTO Sync_MasterDataTransferStatus
				SELECT @PropertyId,A.CategoryID, B.code, 'KioskCat', @IsActive
				FROM (SELECT @CategoryID AS CategoryID) A
				CROSS JOIN Location_Ref B WHERE B.Active = 1

		  END
		  ELSE
		  BEGIN
			RAISERROR('Sequence already exists.',16,1)
		  END

		END
		ELSE
		BEGIN
			RAISERROR('No record exists.',16,1)
		END		
	END
	ELSE
	BEGIN
		RAISERROR('Invalid operation',16,1)
	END

	


END

GO

