-- =============================================
-- Author:		Nivesh
-- Create date: 2025-02-17
-- Description:	Delete old temp excel data
-- =============================================
CREATE PROCEDURE [dbo].[sp_Delete_TempExcel_Old_Records]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	begin transaction
    DELETE FROM Temp_ValidateExcelRowData
    WHERE CAST(logDate AS DATE) < DATEADD(DAY, -4, CAST(GETDATE() AS DATE));

    PRINT CONCAT('Deleted Records Count: ', @@ROWCOUNT);
    DELETE FROM temp_CommonExcelGetData
    WHERE CAST(logDate AS DATE) < DATEADD(DAY, -4, CAST(GETDATE() AS DATE));
	
    DELETE FROM CommonExcelUploadData
    WHERE CAST(Date AS DATE) < DATEADD(DAY, -4, CAST(GETDATE() AS DATE));

	DELETE FROM ValidateExcelRowAllData
    WHERE CAST(logDate AS DATE) < DATEADD(DAY, -4, CAST(GETDATE() AS DATE));
	
	commit transaction
END

GO

