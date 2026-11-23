CREATE PROCEDURE [dbo].[SP_GetLaborMasterData] 
AS

BEGIN
	SELECT S.ID AS SupplierID , S.Name AS SupplierName , LT.Id AS LaborTypeId ,
		   LT.LabourName  AS LabourTypeName,LU.Id AS LaborUnitId , LU.LaborUnitName ,
		    LM.price,s.PropertyID AS PropertyID , LU.LaborUnitCode  AS LaborUnitCode
 FROM LaborMasters LM INNER JOIN LaborUnits LU ON LM.LaborUnitId=LU.Id
INNER JOIN  LabourTypes LT ON LM.LaborTypeId=LT.Id
INNER JOIN Suppliers  S ON LM.SupplierId = S.Id
END

GO

