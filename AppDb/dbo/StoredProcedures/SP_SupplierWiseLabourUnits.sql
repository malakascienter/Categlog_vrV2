

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 2018-05-15
-- Description:	<Description,,>
-- =============================================
--SP_SupplierWiseLabourUnits 4,1
CREATE PROCEDURE SP_SupplierWiseLabourUnits 

@SupplierID INT, 	
@LaborTypeId INT 

AS
BEGIN
	select distinct LM.LaborTypeId,LM.SupplierId,LM.LaborUnitId,LU.LaborUnitName,LM.price AS Price
	from LaborMasters LM 
	INNER JOIN dbo.LaborUnits LU ON LU.Id = LM.LaborUnitId 
	WHERE SupplierId =@SupplierID and LaborTypeId = @LaborTypeId 
END

GO

