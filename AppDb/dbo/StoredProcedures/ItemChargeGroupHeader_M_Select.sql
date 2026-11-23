
CREATE PROCEDURE [dbo].[ItemChargeGroupHeader_M_Select]  --1,2
@isActive INT=2,
@PropertyId INT
AS  
BEGIN   

SELECT * FROM Gen_ItemChargeGroupHeader

END

GO

