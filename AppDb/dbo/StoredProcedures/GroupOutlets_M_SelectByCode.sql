
CREATE PROCEDURE [dbo].[GroupOutlets_M_SelectByCode]
@PropertyId INT = 1,
@Code VARCHAR(3)
AS
BEGIN
    
    SET NOCOUNT ON;  
    SELECT * from  GroupLocation WHERE IsActive = 1 AND GroupLocationCode = @Code
END

GO

