
CREATE PROCEDURE [dbo].[StockItemWiseImage_M_Save]
(
	@StockItemId BIGINT,
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

	       IF EXISTS (SELECT 1 FROM [dbo].[StockItemWiseImage] WHERE [StockItemId] = @StockItemId )
		   BEGIN
			
			 UPDATE [dbo].[StockItemWiseImage]
		     SET [ItemImage] = @ItemImage,ImageName = @ImageName
		     WHERE [StockItemId] = @StockItemId  AND PropertyId = @PropertyId
			
		   END
		   ELSE
		   BEGIN

			INSERT INTO [dbo].[StockItemWiseImage]
           ([StockItemId]
           ,[ItemImage]
           ,[PropertyId]
           ,[ImageName])
			 VALUES
			(@StockItemId
           ,@ItemImage
           ,@PropertyId
           ,@ImageName)

		   

		   END

    END
	ELSE IF(@Action = 'U')
	BEGIN

		   
		   --SELECT @ItemId = Id FROM MainMenu WHERE ItemCode = @ItemCode

		   IF EXISTS (SELECT 1 FROM [dbo].[StockItemWiseImage] WHERE [StockItemId] = @StockItemId )
		   BEGIN
			
			 UPDATE [dbo].[StockItemWiseImage]
		     SET [ItemImage] = @ItemImage,ImageName = @ImageName
		     WHERE [StockItemId] = @StockItemId  AND PropertyId = @PropertyId
			
		   END
		   ELSE
		   BEGIN

			INSERT INTO [dbo].[StockItemWiseImage]
           ([StockItemId]
           ,[ItemImage]
           ,[PropertyId]
           ,[ImageName])
			 VALUES
			(@StockItemId
           ,@ItemImage
           ,@PropertyId
           ,@ImageName)

		   END

		  

	END
	ELSE
	BEGIN
		RAISERROR('Invalid operation',16,1)
	END


	SELECT TOP(1) StockItemId,'' AS DataType,[ItemImage] AS ItemImage,ImageName,PropertyId FROM [StockItemWiseImage] WHERE [StockItemId] = @StockItemId

END

GO

