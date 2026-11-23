
-- GetProjectSupplierPrice 2

CREATE Procedure [dbo].[GetProjectSupplierPrice] @ProjectId INT
AS
BEGIN

SELECT DISTINCT PW.SupplierID,S.Name from Suppliers as S 
INNER join ProjectWiseSupplierPrices as PW on  S.ID=PW.SupplierID 
WHERE PW.ProjectID=@ProjectID AND(PW.Status IS NULL OR PW.Status = 'X') ORDER BY PW.SupplierID


ENd

GO

