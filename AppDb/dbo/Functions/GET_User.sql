
CREATE FUNCTION  [dbo].[GET_User](@UserID INT)
RETURNS VARCHAR(200)
AS
BEGIN
	DECLARE  @UserName Varchar(200)
	DECLARE  @TempPOReqTable TABLE(
	name varchar(200)
	)
	INSERT INTO @TempPOReqTable 
	SELECT DISTINCT TOP(1) UserName FROM [dbo].[CentralUsers]
	WHERE Id =@UserID
	UNION ALL
	SELECT DISTINCT TOP(1) UserName FROM [dbo].[UserMasters]
	WHERE Id =@UserID 

	SELECT TOP 1 @UserName = name FROM @TempPOReqTable

	RETURN @UserName

END

GO

