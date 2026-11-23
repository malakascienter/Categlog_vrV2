

-- =============================================
-- Author:		Yasiru	
-- Create date: 2017/12/11
-- Description:	Select AlertTypes by Id
-- =============================================
CREATE PROCEDURE [dbo].[Property_M_Select_ById] 
@Id		INT
AS
BEGIN
	SET NOCOUNT ON;
	--SELECT *	FROM Property 
	--use this company table to link with inventory Db(catelog_crv)
	--SELECT * FROM Companies
	--WHERE CompanyID = @Id


	--Comment quary for only jetwing

--SELECT [CompanyID]
--      ,[GroupofcompanyID]
--      ,[Code]
--      ,[Name]
--      ,[IsActive]
--      ,[OtherBusinessName1]
--      ,[Address1]
--      ,[Address2]
--      ,[Address3]
--      ,[Telephone1]
--      ,[Telephone2]
--      ,[Mobile]
--      ,[FaxNo]
--      ,[Email]
--      ,[WebAddress]
--      ,[ContactPerson]
--      ,[TaxID1]
--      ,[TaxID2]
--      ,[TaxID3]
--      ,[TaxRegistrationNumber1]
--      ,[TaxRegistrationNumber2]
--      ,[TaxRegistrationNumber3]
--      ,[StartOfFiscalYear]
--      ,[CostingMethod]
--      ,[IsVat]
--      ,[IPAddress]
--      ,[CreatedUserID]
--      ,[LastModUserID]
--      ,[CreatedDate]
--      ,[LastModDate]
--      ,[IsTaxOrSellPrice]
--      ,[IsFirstOne]
--      ,[IsSettlementSeparate]
--      ,[NativeCurrency]
--      ,[CompanyType]
--      ,[ThresholdPercentage]
--      ,[AutoStockItemCode]
--      ,[GrnBlockID]
--      ,[LogoURL]
--      ,[ViewAdditionalRate]
--      ,[PropertyServer]
--      ,[PropertyDatabase]
--      ,[IsTenderBoardApplicable]
--      ,[AllowIncreasePRqty]
--      ,[PRqtyThreshold]
--      ,[MASTERID]
--      ,[ReconMaxBackDate]
--      ,[POSTGL]
--      ,[CompanySeparator]
--      ,[SessionTimeInMinutes]
--      ,[IsDepartmentWiseItems]
--      ,[IsSupplierForAllProperty]
--      ,[IsApprovalForGRN]
--      ,[IsAutoTransferIn]
--      ,[IsApprovalForIssueReturn]
--      ,[IsMailNotification]
--      ,[IScentrallogin]
--      ,[POSTGLTYPE]
--      ,[RoomPostingServer]
--      ,[RoomPostingDatabase]
--      ,[IsDayEndFrontOfficeEnabled]
--      ,[IsDayEndPOSEnabled]
--      ,[IsDayEndGLEnabled]
--      ,[POSDataBaseServerName]
--      ,[POSDataBaseName]
--      ,[POSDataBaseUsername]
--      ,[POSDataBasePassword]
--      ,[InvPropertyId]
--      ,[IsDayEndInventoryEnabled]
--      ,[IsDayEndBanquetEnabled]
--      ,[IsDayEndBackOfficeEnabled]
--      ,[HotelDataBase]
--      ,[IsGRNDocUpload]
--      ,[IsBudgetPo]
--      ,[IsAllowPriceChange]
--      ,[IsPaymentTypeEnable]
--      ,[IsRestaurant]
--      ,[IsGLConnected]
--      ,[GLCOMPCODE]
--      ,[IsGroupLocationProperty]
--      ,[GroupLocationCode]
--      ,CurrentDate
--      ,[IsLocationWiseDayendEnable]
--      ,[EnableOutletWisePaymentType]
--      ,[IsEnableOutletWisePaymentType]
--      ,[DecimalPlaces]
--      ,[IsCompleteRequests]
--      ,[DayEndModuleId]
--      ,[IsEnableKitchenWiseStock]
--      ,[IsGLSupplierUpdate]
--      ,[IsDeliverydateforRequest]
--      ,[ImageUrl]
--     -- ,[IsEnableNoSaleValidation]
--      ,[IsEnableMiniBar]
--      ,[DisablePrice]
--      ,[LimitDocumentLoading]
--      ,[GRNDocValidDates]
--      ,[IsDeliverydateforIssueRequest]
--      ,[IsSSRSReports]
--      ,[IsQuantityInHand]
--      ,[IsRetail]
--      ,[IsHotelConnect]
--      ,[IsHotelPostAPI]
--      ,[HotelPostAPIUser]
--      ,[HotelPostAPIPassword]
--      ,[IsBanquetConnect]
--      ,[IsAccConnect]
--      ,[IsAutoTransferGRN]
--      ,[IsFiscalEnable]
--      ,[IsDepartmentWiseItemForPR]
--      ,[IsSupplierNotification]
--      ,[isPOApprovalForPrintPreview]
--      ,[PosAPIUrl]
--      ,[IsCostPriceTypeEnable]
--      ,[IsEnablePrinterLocationWiseKitchenIssue]
--      ,[isPOPrepModification]
--      ,[isPOType]
--      ,[BaseCurr]
--      ,[LocalCurr]
--	  ,[CompanyID] AS Id
--  FROM [dbo].[Companies]
--  WHERE CompanyID = @Id

  SELECT *
	  ,[CompanyID] AS Id
  FROM [dbo].[Companies]
  WHERE CompanyID = @Id


END

GO

