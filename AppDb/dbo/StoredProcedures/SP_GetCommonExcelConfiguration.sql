-- =============================================
-- Author:		Nivesh
-- Create date: 2025-02-05
-- Description:	Get Excel Column Configuaration
-- =============================================
-- SP_GetCommonExcelConfiguration'PR'

CREATE PROCEDURE [dbo].[SP_GetCommonExcelConfiguration] 
	@TranType VARCHAR(5)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT Id, TranType, columnconfiguration,DropDownConfiguration, CheckBoxConfiguration,SP_Name,IsActive FROM
	excelcolumnconfiguration
	WHERE trantype =@TranType

END

GO

