

CREATE PROCEDURE [dbo].[BatchWise_Location_M_Select]
	@BatchLocation	VARCHAR(MAX),
	@UserId INT,
	@PropertyId INT
AS
BEGIN

	SELECT L.code,L.description 
	FROM BatchLocationDetails BLD INNER JOIN BatchLocation BL ON BLD.BatchLocationCode = BL.BatchLocationCode AND BLD.PropertyId = BL.PropertyId
	INNER JOIN Location_Ref L ON BLD.Outlet = L.code AND BLD.PropertyId = L.PropertyId
	WHERE BL.BatchLocationCode IN (SELECT * FROM STRING_SPLIT(@BatchLocation,','))  AND L.PropertyId = @PropertyId 
	AND  BLD.PropertyId = @PropertyId AND BL.PropertyId = @PropertyId
	GROUP BY L.code,L.description
END

GO

