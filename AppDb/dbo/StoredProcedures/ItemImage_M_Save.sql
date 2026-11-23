
create PROCEDURE [dbo].[ItemImage_M_Save]
(
	@ItemCode NVARCHAR(10),
	@ItemImage IMAGE,
	@Action	NVARCHAR(3),
	@PropertyId INT,
	@ImageName VARCHAR(100)
)

AS
BEGIN
SET NOCOUNT ON;

	DECLARE @ItemId INT 

	IF(@Action = 'I')
	BEGIN

		 
		  --SELECT @ItemId = Id FROM MainMenu WHERE ItemCode = @ItemCode

		  INSERT INTO [dbo].[POS_Image]
           ([Code]
           ,[DataType]
           ,[ItemImage]
		   ,PropertyId
		   ,ImageName)
		   VALUES
           (@ItemCode
           ,'ITM'
           ,@ItemImage
		   ,@PropertyId
		   ,@ImageName)	

    END
	ELSE IF(@Action = 'U')
	BEGIN

		   
		   --SELECT @ItemId = Id FROM MainMenu WHERE ItemCode = @ItemCode

		   IF EXISTS (SELECT 1 FROM [dbo].[POS_Image] WHERE [Code] = @ItemCode AND [DataType] = 'ITM')
		   BEGIN
			
			 UPDATE [dbo].[POS_Image]
		     SET [ItemImage] = @ItemImage,ImageName = @ImageName
		     WHERE [Code] = @ItemCode  AND [DataType] = 'ITM' AND PropertyId = @PropertyId
			
		   END
		   ELSE
		   BEGIN

			INSERT INTO [dbo].[POS_Image]
            ([Code]
            ,[DataType]
            ,[ItemImage]
			 ,PropertyId
			 ,ImageName)
		   VALUES
            (@ItemCode
            ,'ITM'
            ,@ItemImage
			,@PropertyId
			,@ImageName)	

		   END

		  

	END
	ELSE
	BEGIN
		RAISERROR('Invalid operation',16,1)
	END


END

GO

