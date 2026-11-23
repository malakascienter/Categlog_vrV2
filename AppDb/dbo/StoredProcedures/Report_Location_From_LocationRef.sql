CREATE PROCEDURE [dbo].[Report_Location_From_LocationRef]
	--@PropertyId VARCHAR(2)
AS
BEGIN
	SELECT		code, description
	FROM		Location_Ref
	WHERE		(Active = 1) --AND PropertyId=@PropertyId
	ORDER BY	description
END

GO

