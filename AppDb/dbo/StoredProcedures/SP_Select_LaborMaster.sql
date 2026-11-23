
CREATE PROCEDURE [dbo].[SP_Select_LaborMaster] 
	@SuppId int
AS
BEGIN
	
SELECT        LM.Id AS LaborMasterID, LM.LaborTypeId, LT.LabourCode AS LabourTypeCode, LT.LabourName AS LabourTypeName, LM.LaborUnitId, LU.LaborUnitName, LM.price AS Price
FROM            dbo.LaborMasters AS LM INNER JOIN
                         dbo.LaborUnits AS LU ON LM.LaborUnitId = LU.Id INNER JOIN
                         dbo.LabourTypes as LT ON LM.LaborTypeId = LT.Id
WHERE        (LM.SupplierId = @SuppId) 


END

GO

