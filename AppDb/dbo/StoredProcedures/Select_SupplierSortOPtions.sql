-- =============================================
-- Author:	ISURU PRAMODYA
-- Create date: 2025-05-15
-- Description:	Loading Supplier Sort OPtions
--  [dbo].[Select_SupplierSortOPtions] -999
-- =============================================
CREATE PROCEDURE [dbo].[Select_SupplierSortOPtions]
	@ID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID,Name
	FROM SupplierSortOPtions
	WHERE IsActive =1
	AND ID = CASE WHEN @ID = -999 THEN ID ELSE @ID END
	ORDER BY Seq

    
END

GO

