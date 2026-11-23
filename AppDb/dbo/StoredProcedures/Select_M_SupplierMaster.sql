
-- =============================================
-- Author:		Banu
-- Create date: 23/11/2018
-- Description:	Select all records from Supplier Master
-- =============================================
CREATE PROCEDURE [dbo].[Select_M_SupplierMaster] 	 
AS
BEGIN  
	SELECT * FROM SupplierMaster Order By SuppName
END

GO

