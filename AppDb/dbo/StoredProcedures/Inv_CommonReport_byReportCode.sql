-- =============================================
-- Author:		ISURU PRAMODYA 2023
-- Create date: 18 May 2023
-- Description:	SELECT PARAMETERS FOR COMMON REPORT

-- [dbo].[Inv_CommonReport_byReportCode] 'PrintTransferNoteReport',1
-- =============================================
CREATE PROCEDURE [dbo].[Inv_CommonReport_byReportCode]
	@ReportCode VARCHAR(MAX),
	@PropertyID INT 
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReportName VARCHAR(max)

	IF EXISTS(SELECT 1 FROM PropertyWise_Inventory_Reports WHERE ReportCode=@ReportCode AND PropertyID = @PropertyID)
	BEGIN
	SELECT @ReportName =ReportName FROM PropertyWise_Inventory_Reports WHERE ReportCode=@ReportCode AND PropertyID = @PropertyID
	END
		
	--SELECT @ReportName
	SELECT ReportID, ReportCode,CASE WHEN @ReportName IS NULL THEN ReportName ELSE @ReportName END AS ReportName,ReportURL, DisplayName, ReportCategory, ReportPrameterCategory, Active, ParamFromDate, ParamToDate, ParamCompany, ParamLocation, ParamItem, ParamCategory, 
    ParamTransactionType, ParamSubCategory, ParamSupplier,ParamByValue,ParamDepartment,ParamType,ParamZeroBalance,ParamDate,ParamSortBy,ParamSummaryReport,LTRIM(RTRIM(ReportDropDownType)) ReportDropDownType,ParamSubCategory2
	,ParamSubAccount,ParamIsSupplierAcive,ParamMultipleLocation,ParamItemMoving, ParamNoofItems,ParamIsConsigmentSuppliers,
	ParamIsPOReportTypes,ParamPeriodType,ParamValueType,ISNULL(ParamSortOption,0) ParamSortOption,ISNULL(ParamDropDown,0) ParamDropDown,ISNULL(DropDownSP,'') DropDownSP
	, ISNULL(ParamFromLocation,0) ParamFromLocation, ISNULL(ParamToLocation,0) ParamToLocation, ISNULL(ParamAllLocation,0) ParamAllLocation,
	ISNULL(ParamDispatchDate,0) ParamDispatchDate



	FROM   InvenTory_ReportDetails
	WHERE ReportCode = @ReportCode

END

GO

