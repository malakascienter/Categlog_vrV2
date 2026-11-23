-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 02 Feb 2023
-- Modified by:	Nivesh
-- Modified date: 2026-01-14
-- Description:	Select Comanies Data
-- EXEC [dbo].[Select_CompanyByPropertyID] 1
-- =============================================
CREATE PROCEDURE [dbo].[Select_CompanyByPropertyID]
	@propertyId int
AS
BEGIN
--------------------------------------------------------------------------------
BEGIN TRY
	SELECT DecimalPlaces,Name,PropertyDatabase,ISNULL(IsDeliverydateforRequest,0) IsDeliverydateforRequest,ISNULL(DisablePrice,0) DisablePrice,ISNULL(IsDeliverydateforIssueRequest,0) IsDeliverydateforIssueRequest,IsRetail,IsSSRSReports,IsAutoTransferGRN,IsDepartmentWiseItemForPR,isPOApprovalForPrintPreview,isPOType,
	ISNULL(IsOutSideAPIConnect,0) IsOutSideAPIConnect,ISNULL(IsReOrderEnable,0) IsReOrderEnable,ISNULL(IsCategoryLevels,0) IsCategoryLevels,ISNULL(IsBudgetGRN,0) IsBudgetGRN,ISNULL(IsAllowIncreaseCostPrice,0) IsAllowIncreaseCostPrice
	,ISNULL(IsBatchTransactionEnable,0) IsBatchTransactionEnable, ISNULL(IsCommonExcel,0) IsCommonExcel,
	POSTGL,ISNULL(IsContractedSupplier,0) IsContractedSupplier,ISNULL(IsQuantityInHand,0) IsQuantityInHand,ISNULL(IsSupplierEvaluate,0) IsSupplierEvaluate
	,ISNULL(ShortExpDates,0) ShortExpDates,ISNULL(IsShortExpireVisible,0) IsShortExpireVisible,
	ISNULL(IsQuantityInHandFromCurrentLocation,0) IsQuantityInHandFromCurrentLocation,ISNULL(IsTransactionTypeTemplates,0) IsTransactionTypeTemplates,ISNULL(IsRequestedQuantityExceed,0) IsRequestedQuantityExceed
	,ISNULL(IsTransferOutGridEdit,0) IsTransferOutGridEdit,
	ISNULL(IsPaxCount,0) IsPaxCount,ISNULL(UnitPriceThreshhold,-1) UnitPriceThreshhold,
	ISNULL(IsGRNUnitChange,0) AS IsGRNUnitChange,ISNULL(IsSupplierCategoryEnable,0) IsSupplierCategoryEnable,ISNULL(IsNotificationPanel,0) IsNotificationPanel
	,ISNULL(IsAutoProduction,0) IsAutoProduction,ISNULL(IsDamageRequestCategory,0) IsDamageRequestCategory,ISNULL(IsSupplierDocAttached,0) IsSupplierDocAttached,
	ISNULL(IsDeleteRequestBasedTransaction,0) AS IsDeleteRequestBasedTransaction,ISNULL(IsQuatoationRequest,0) AS IsQuatoationRequest
	,ISNULL(IsRecipeLocationMaintain,1) IsRecipeLocationMaintain,ISNULL(IsAllLocationForApprovals,0) IsAllLocationForApprovals
	,ISNULL(IsGRNApprovalModification,0) IsGRNApprovalModification,ISNULL(IsPrintCopyDocLimit,0) IsPrintCopyDocLimit,
	ISNULL(IsInventoryReorderNotification,0) AS IsInventoryReorderNotification,
	ISNULL(IsCountrySelection,0) IsCountrySelection
	,ISNULL(IsCUSDECSelection,0) IsCUSDECSelection
	,ISNULL(IsInvoiceValueValidation,0) IsInvoiceValueValidation
	,ISNULL(IsUnitPriceThreshHoldExceed,0) IsUnitPriceThreshHoldExceed
	,ISNULL(IsPOApprovalQtyExceed,0) IsPOApprovalQtyExceed
	,ISNULL(IsEditInvoiceDetailsInGrnApproval,0) IsEditInvoiceDetailsInGrnApproval   --Added by Tharuka 2026-04-02--
	,ISNULL(IsDisplayAsMobileNumber,0) IsDisplayAsMobileNumber   --Added by Tharuka 2026-04-02--
	,ISNULL(IsLastGRNPriceForPO,0) IsLastGRNPriceForPO
	,ISNULL(IsDocumentEditInApproval,0) IsDocumentEditInApproval
	,SupplierId
	,ISNULL(IsInvoiceGRNAllow,0) IsInvoiceGRNAllow
	,ISNULL(IsRangeWiseApproval,0) IsRangeWiseApproval  --Added by Tharuka 2026-06-19--
	,ISNULL(IsProductionWithoutRecipe,0) IsProductionWithoutRecipe -- Added by Tharuka 2026-07-17 --
	,ISNULL(IsDisableGRNUnitPrice,0) IsDisableGRNUnitPrice -- Added by Tharuka 2026-07-27 --
	,ISNULL(IsDepartmentWisePOApproval, 0) AS IsDepartmentWisePOApproval
	,ISNULL(IsDisableTRUnit,0) IsDisableTRUnit -- Added by Tharuka 2026-08-17 --
	,ISNULL(IsFranchiseInvoiceEnable,0) IsFranchiseInvoiceEnable -- Added by Tharuka 2026-09-10 --
	,ISNULL(IsLocationHoldingDays,0) IsLocationHoldingDays -- Added by Isuru 2026-09-24 --
	,ISNULL(DirectGRNUnitPriceThreshhold,-1) DirectGRNUnitPriceThreshhold --Added by Isuru 2026-09-28
	,ISNULL(IsDirectGRNUnitPriceThreshHoldExceed,1) IsDirectGRNUnitPriceThreshHoldExceed --Added by Isuru 2026-09-28
	FROM Companies
	WHERE CompanyID = @propertyId
END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;
--------------------------------------------------------------------------------

	

END

GO

