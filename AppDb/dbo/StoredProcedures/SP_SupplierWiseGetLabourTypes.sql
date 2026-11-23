

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 2018-05-15
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_SupplierWiseGetLabourTypes

@SupplierID INT 	

AS
BEGIN
	SELECT DISTINCT LM.LaborTypeId,LT.LabourName 
	FROM dbo.LaborMasters LM 
	INNER JOIN dbo.LabourTypes LT ON LM.LaborTypeId=LT.Id 
	WHERE SupplierId=@SupplierID
END

GO

