
CREATE PROCEDURE [dbo].[GroupOutlets_M_Select_All]
@PropertyId INT = 1
AS
BEGIN
    
    SET NOCOUNT ON;  
    SELECT * from  GroupLocation WHERE IsActive = 1 AND PropertyId = @PropertyId
END

GO

