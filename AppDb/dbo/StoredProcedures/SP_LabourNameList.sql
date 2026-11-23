CREATE PROCEDURE [dbo].[SP_LabourNameList]
 @PropertyID INT = 1
as
SELECT ID AS id, Name as text 
FROM dbo.Suppliers 
WHERE IsLabor = 1 AND PropertyID = @PropertyID

GO

