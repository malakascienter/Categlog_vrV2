
/*
select * from Inv_RecipeHeader
InsertRecipeHeaders '{"CompanyId":1,"Id":0,"Code":"sas","IsActive":true,"Name":"sasas","Type":"I","Unit":2}','I'
*/
create PROCEDURE [dbo].[InsertRecipeHeaders]
	@Data VARCHAR(MAX),
	@operation VARCHAR(2)
AS
BEGIN
	IF @operation = 'I'
	BEGIN
		INSERT INTO Inv_RecipeHeader(RecipeCode,RecipeName,IsActive,UnitId,CompanyId)
		SELECT Code,Name,IsActive,Unit,CompanyId
		FROM OPENJSON(@Data,'$')
		WITH (
			Code VARCHAR(50),
			Name VARCHAR(100),
			IsActive BIT,
			Unit INT,
			CompanyId INT
		)
	END
	ELSE IF @operation = 'U'
	BEGIN
		UPDATE Inv_RecipeHeader
		SET 
			RecipeName = temp.Name,
			RecipeCode = temp.Code,
			IsActive = temp.IsActive,
			UnitId = temp.Unit
		FROM 
			Inv_RecipeHeader rec
		INNER JOIN (
			SELECT Id,Code, Name, IsActive, Unit, CompanyId
			FROM OPENJSON(@Data, '$')
			WITH (
				Id int,
				Code VARCHAR(50),
				Name VARCHAR(100),
				IsActive BIT,
				Unit INT,
				CompanyId INT
			)
		) AS temp
		ON rec.Id = temp.Id; 
	END
END

GO

