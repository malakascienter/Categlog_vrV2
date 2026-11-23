CREATE  PROCEDURE [dbo].[Select_ActionButtons]
@RefItemRequired INT =2	,
@PropertyId INT
AS
BEGIN
	Select * From ActionButtons 
	WHERE RefItemRequired=@RefItemRequired OR @RefItemRequired = 2
END

GO

