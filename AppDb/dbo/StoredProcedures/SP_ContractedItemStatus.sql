-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-09-03
-- Description:	Loading Contracted Supplier item Status
-- =============================================
CREATE PROCEDURE [dbo].[SP_ContractedItemStatus]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID id,Name text ,ReportName,IsReportNameChange
	FROM     Report_ContractedSupplierStatus
	WHERE IsActive=1

   
END

GO

