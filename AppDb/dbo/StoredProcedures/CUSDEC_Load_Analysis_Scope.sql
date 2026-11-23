-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-02-12
-- Description:	SELECT PARAMETERS FOR CUSDEC Ananlysis report
-- =============================================
CREATE PROCEDURE [dbo].[CUSDEC_Load_Analysis_Scope]
	@ID INT

AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT ID, Name, Type, IsActive,
	ISNULL(ParamItem,0) ParamItem,
	ISNULL(ParamSupplier,0) ParamSupplier, 
	ISNULL(ParamProvince,0) ParamProvince,
	ISNULL(ParamDistrict,0) ParamDistrict,
	ISNULL(ParamDS,0) ParamDS, 
	ISNULL(ParamGN,0) ParamGN,
	ISNULL(ParamFromDate,0) ParamFromDate,
	ISNULL(ParamToDate,0) ParamToDate,
	ReportName, ReportDisplayName
	FROM     CUSDEC_Analysis_Scope
	WHERE ID = CASE WHEN @ID = -999 THEN ID ELSE @ID END

   

END

GO

