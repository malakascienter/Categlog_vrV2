CREATE PROCEDURE [dbo].[Sync_spGetPOSImage]
@PropertyId INT,
@Code VARCHAR(10),
@DataType VARCHAR(3)
AS
SET NOCOUNT ON

SELECT	TOP 1 Code, DataType, ItemImage
FROM	POS_Image
WHERE	Code = @Code AND DataType = @DataType AND PropertyId IN (@PropertyId, 0)
ORDER BY CASE WHEN PropertyId = @PropertyId THEN 0 ELSE 1 END

GO

