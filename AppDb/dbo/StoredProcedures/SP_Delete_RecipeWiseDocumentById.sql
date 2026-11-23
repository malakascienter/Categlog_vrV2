
CREATE PROCEDURE [dbo].[SP_Delete_RecipeWiseDocumentById] 
	@Id	INT,
	@PropertyId     INT
AS
BEGIN 

	UPDATE [RecipeWiseDocument]
	SET IsActive = 0
	WHERE Id =@Id
	
END

GO

