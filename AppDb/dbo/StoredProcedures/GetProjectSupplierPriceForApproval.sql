
CREATE Procedure [dbo].[GetProjectSupplierPriceForApproval] @ProjectId INT
AS
BEGIN
SELECT DISTINCT PW.SupplierID,S.Name from Suppliers as S 
INNER join ProjectWiseSupplierPrices as PW on  S.ID=PW.SupplierID 
WHERE PW.ProjectID=@ProjectID AND(PW.Status IS NULL OR PW.Status = 'P') ORDER BY PW.SupplierID

ENd

GO

