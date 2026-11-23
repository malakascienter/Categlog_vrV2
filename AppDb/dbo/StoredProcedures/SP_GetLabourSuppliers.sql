

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 2018-05-15
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_GetLabourSuppliers
	
AS
BEGIN
	SELECT * FROM dbo.Suppliers WHERE IsLabor=1
END

GO

