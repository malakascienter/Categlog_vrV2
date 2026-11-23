CREATE PROCEDURE [dbo].[SP_TableCount]
AS
	BEGIN	

	IF OBJECT_ID(N'tempdb..#TempTableCount') IS NOT NULL
	BEGIN
	DROP TABLE #TempTableCount
	END


CREATE TABLE #TempTableCount(
	[Companiescount] [int] NOT NULL,
	[AdditionalChargesDetailscount] [int] NOT NULL,
	[ApprovalTypescount] [int] NOT NULL,
	[AutoGenerateInfoescount] [int] NOT NULL,
	[BrokerMasterscount] [int] NOT NULL,
	[Categoriescount] [int] NOT NULL,
	[CurrencyMasterscount] [int] NOT NULL,
	[Customerscount] [int] NOT NULL,
	[Departmentscount] [int] NOT NULL,
	[Employeescount] [int] NOT NULL,
	[Locationscount] [int] NOT NULL,
	[Loginscount] [int] NOT NULL,
	[PaymentTermscount] [int] NOT NULL,
	[RequestDetailscount] [int] NOT NULL,
	[RequestHeaderscount] [int] NOT NULL,
	[SalesContractWiseExtrachargescount] [int] NOT NULL,
	[StockItemAttributescount] [int] NOT NULL,
	[StockItemClassificationDetailscount] [int] NOT NULL,
	[StockItemClassificationHeaderscount] [int] NOT NULL,
	[StockItemDetailscount] [int] NOT NULL,
	[StockItemHeaderscount] [int] NOT NULL,
	[StockItemReferencescount] [int] NOT NULL,
	[StockItemWiseAttributescount] [int] NOT NULL,
	[StockItemWiseClassificationDetailscount] [int] NOT NULL,
	[SubCategoriescount] [int] NOT NULL,
	[SupplierPaymentAgreementscount] [int] NOT NULL,
	[Supplierscount] [int] NOT NULL,
	[SupplierWiseItemDetailscount] [int] NOT NULL,
	[TransactionRightscount] [int] NOT NULL,
	[TransactionTypescount] [int] NOT NULL,
	[UnitConversionscount] [int] NOT NULL,
	[Unitscount] [int] NOT NULL,
	[UserGroupPrivilegescount] [int] NOT NULL,
	[UserGroupscount] [int] NOT NULL,
	[UserMasterscount] [int] NOT NULL,
	[UserPrivilegescount] [int] NOT NULL,
	[UserPrivilegesLocationscount] [int] NOT NULL,
)




		DECLARE 
		@Companiescount INT, @AdditionalChargesDetailscount INT, @ApprovalTypescount INT, @AutoGenerateInfoescount INT, @BrokerMasterscount INT, @Categoriescount INT,
		@CurrencyMasterscount INT,	@Customerscount INT,	@Departmentscount INT,	@Employeescount INT,	@Locationscount INT,	@Loginscount INT,	@PaymentTermscount INT,
		@RequestDetailscount INT, @RequestHeaderscount INT,	@SalesContractWiseExtrachargescount INT,	@StockItemAttributescount INT,	@StockItemClassificationDetailscount INT,
		@StockItemClassificationHeaderscount INT, @StockItemDetailscount INT, @StockItemHeaderscount INT, @StockItemReferencescount INT, @StockItemWiseAttributescount INT,
		@StockItemWiseClassificationDetailscount INT, @SubCategoriescount INT,	@SupplierPaymentAgreementscount INT, @Supplierscount INT,	@SupplierWiseItemDetailscount INT,
		@TransactionRightscount INT, @TransactionTypescount INT, @UnitConversionscount INT,	@Unitscount INT, @UserGroupPrivilegescount INT, @UserGroupscount INT,
		@UserMasterscount INT, @UserPrivilegescount INT, @UserPrivilegesLocationscount INT
		
		SELECT @AdditionalChargesDetailscount = COUNT(*) FROM dbo.AdditionalChargesDetails WITH(NOLOCK)      --company 
		SELECT @Companiescount = COUNT(*) FROM dbo.Companies WITH(NOLOCK)   
		SELECT @ApprovalTypescount = COUNT(*) FROM dbo.ApprovalTypes WITH(NOLOCK)   
		SELECT @AutoGenerateInfoescount = COUNT(*) FROM dbo.AutoGenerateInfoes  WITH(NOLOCK)   
		SELECT @BrokerMasterscount = COUNT(*) FROM dbo.BrokerMasters  WITH(NOLOCK)   
		SELECT @Categoriescount = COUNT(*) FROM dbo.Categories WITH(NOLOCK)    --company
		SELECT @CurrencyMasterscount = COUNT(*) FROM dbo.CurrencyMasters  WITH(NOLOCK)   
		SELECT @Customerscount = COUNT(*) FROM dbo.Customers  WITH(NOLOCK)    -- company, location
		SELECT @Departmentscount = COUNT(*) FROM dbo.Departments  WITH(NOLOCK)   -- company
		SELECT @Employeescount = COUNT(*) FROM dbo.Employees WITH(NOLOCK)    -- company, location, department
		SELECT @Locationscount = COUNT(*) FROM dbo.Locations WITH(NOLOCK)    -- company
		SELECT @Loginscount = COUNT(*) FROM dbo.Logins  WITH(NOLOCK)   
		SELECT @PaymentTermscount = COUNT(*) FROM dbo.PaymentTerms  WITH(NOLOCK)   -- company
		SELECT @RequestDetailscount = COUNT(*) FROM dbo.RequestDetails  WITH(NOLOCK)   
		SELECT @RequestHeaderscount = COUNT(*) FROM dbo.RequestHeaders  WITH(NOLOCK)   -- company, location, department
		SELECT @SalesContractWiseExtrachargescount = COUNT(*) FROM dbo.SalesContractWiseExtracharges  WITH(NOLOCK)   
		SELECT @StockItemAttributescount = COUNT(*) FROM dbo.StockItemAttributes  WITH(NOLOCK)   
		SELECT @StockItemClassificationDetailscount = COUNT(*) FROM dbo.StockItemClassificationDetails  WITH(NOLOCK)   -- company, location 
		SELECT @StockItemClassificationHeaderscount = COUNT(*) FROM dbo.StockItemClassificationHeaders WITH(NOLOCK)    -- company, location
		SELECT @StockItemDetailscount = COUNT(*) FROM dbo.StockItemDetails WITH(NOLOCK)    -- company, location
		SELECT @StockItemHeaderscount = COUNT(*) FROM dbo.StockItemHeaders WITH(NOLOCK)    -- company, location
		SELECT @StockItemReferencescount = COUNT(*) FROM dbo.StockItemReferences  WITH(NOLOCK)    -- company
		SELECT @StockItemWiseAttributescount = COUNT(*) FROM dbo.StockItemWiseAttributes WITH(NOLOCK)     
		SELECT @StockItemWiseClassificationDetailscount = COUNT(*) FROM dbo.StockItemWiseClassificationDetails   WITH(NOLOCK)   
		SELECT @SubCategoriescount = COUNT(*) FROM dbo.SubCategories WITH(NOLOCK)     -- company
		SELECT @SupplierPaymentAgreementscount = COUNT(*) FROM dbo.SupplierPaymentAgreements   WITH(NOLOCK)   
		SELECT @Supplierscount = COUNT(*) FROM dbo.Suppliers  WITH(NOLOCK)   -- company
		SELECT @SupplierWiseItemDetailscount = COUNT(*) FROM dbo.SupplierWiseItemDetails WITH(NOLOCK)     -- company, location
		SELECT @TransactionRightscount = COUNT(*) FROM dbo.AutoGenerateRights WITH(NOLOCK)    
		SELECT @TransactionTypescount = COUNT(*) FROM dbo.TransactionTypes WITH(NOLOCK)    -- company, location
		SELECT @UnitConversionscount = COUNT(*) FROM dbo.UnitConversions  WITH(NOLOCK)    -- company, location
		SELECT @Unitscount = COUNT(*) FROM dbo.Units  WITH(NOLOCK)    -- company, location
		SELECT @UserGroupPrivilegescount = COUNT(*) FROM dbo.AutoGenerateUserPrivileges   WITH(NOLOCK)   
		SELECT @UserGroupscount = COUNT(*) FROM dbo.UserGroups  WITH(NOLOCK)   
		SELECT @UserMasterscount = COUNT(*) FROM dbo.UserMasters  WITH(NOLOCK)   -- company, location
		SELECT @UserPrivilegescount = COUNT(*) FROM dbo.UserPrivilegesLocations  WITH(NOLOCK)    
		SELECT @UserPrivilegesLocationscount = COUNT(*) FROM dbo.UserPrivilegesLocations WITH(NOLOCK)   
		
		--INSERT INTO dbo.Temp_TableCount
		--        ( Companiescount ,
		--          AdditionalChargesDetailscount ,
		--          ApprovalTypescount ,
		--          AutoGenerateInfoescount ,
		--          BrokerMasterscount ,
		--          Categoriescount ,
		--          CurrencyMasterscount ,
		--          Customerscount ,
		--          Departmentscount ,
		--          Employeescount ,
		--          Locationscount ,
		--          Loginscount ,
		--          PaymentTermscount ,
		--          RequestDetailscount ,
		--          RequestHeaderscount ,
		--          SalesContractWiseExtrachargescount ,
		--          StockItemAttributescount ,
		--          StockItemClassificationDetailscount ,
		--          StockItemClassificationHeaderscount ,
		--          StockItemDetailscount ,
		--          StockItemHeaderscount ,
		--          StockItemReferencescount ,
		--          StockItemWiseAttributescount ,
		--          StockItemWiseClassificationDetailscount ,
		--          SubCategoriescount ,
		--          SupplierPaymentAgreementscount ,
		--          Supplierscount ,
		--          SupplierWiseItemDetailscount ,
		--          TransactionRightscount ,
		--          TransactionTypescount ,
		--          UnitConversionscount ,
		--          Unitscount ,
		--          UserGroupPrivilegescount ,
		--          UserGroupscount ,
		--          UserMasterscount ,
		--          UserPrivilegescount ,
		--          UserPrivilegesLocationscount
		--        )
		
		--VALUES  ( @Companiescount  , -- Companiescount - int
		--		  @AdditionalChargesDetailscount  , -- AdditionalChargesDetailscount - int
		--          @ApprovalTypescount , -- ApprovalTypescount - int
		--          @AutoGenerateInfoescount , -- AutoGenerateInfoescount - int
		--          @BrokerMasterscount , -- BrokerMasterscount - int
		--          @Categoriescount , -- Categoriescount - int
		--          @CurrencyMasterscount , -- CurrencyMasterscount - int
		--          @Customerscount , -- Customerscount - int
		--          @Departmentscount , -- Departmentscount - int
		--          @Employeescount , -- Employeescount - int
		--          @Locationscount , -- Locationscount - int
		--          @Loginscount , -- Loginscount - int
		--          @PaymentTermscount , -- PaymentTermscount - int
		--          @RequestDetailscount , -- RequestDetailscount - int
		--          @RequestHeaderscount , -- RequestHeaderscount - int
		--          @SalesContractWiseExtrachargescount , -- SalesContractWiseExtrachargescount - int
		--          @StockItemAttributescount , -- StockItemAttributescount - int
		--          @StockItemClassificationDetailscount , -- StockItemClassificationDetailscount - int
		--          @StockItemClassificationHeaderscount , -- StockItemClassificationHeaderscount - int
		--          @StockItemDetailscount , -- StockItemDetailscount - int
		--          @StockItemHeaderscount , -- StockItemHeaderscount - int
		--          @StockItemReferencescount , -- StockItemReferencescount - int
		--          @StockItemWiseAttributescount , -- StockItemWiseAttributescount - int
		--          @StockItemWiseClassificationDetailscount , -- StockItemWiseClassificationDetailscount - int
		--          @SubCategoriescount , -- SubCategoriescount - int
		--		  @SupplierPaymentAgreementscount,
		--		  @Supplierscount,
		--          @SupplierWiseItemDetailscount , -- SupplierWiseItemDetailscount - int
		--          @TransactionRightscount , -- TransactionRightscount - int
		--          @TransactionTypescount , -- TransactionTypescount - int
		--          @UnitConversionscount , -- UnitConversionscount - int
		--          @Unitscount , -- Unitscount - int
		--          @UserGroupPrivilegescount , -- UserGroupPrivilegescount - int
		--          @UserGroupscount , -- UserGroupscount - int
		--          @UserMasterscount , -- UserMasterscount - int
		--          @UserPrivilegescount , -- UserPrivilegescount - int
		--          @UserPrivilegesLocationscount  -- UserPrivilegesLocationscount - int,
		--        )
        

		INSERT INTO #TempTableCount
		        ( Companiescount ,
		          AdditionalChargesDetailscount ,
		          ApprovalTypescount ,
		          AutoGenerateInfoescount ,
		          BrokerMasterscount ,
		          Categoriescount ,
		          CurrencyMasterscount ,
		          Customerscount ,
		          Departmentscount ,
		          Employeescount ,
		          Locationscount ,
		          Loginscount ,
		          PaymentTermscount ,
		          RequestDetailscount ,
		          RequestHeaderscount ,
		          SalesContractWiseExtrachargescount ,
		          StockItemAttributescount ,
		          StockItemClassificationDetailscount ,
		          StockItemClassificationHeaderscount ,
		          StockItemDetailscount ,
		          StockItemHeaderscount ,
		          StockItemReferencescount ,
		          StockItemWiseAttributescount ,
		          StockItemWiseClassificationDetailscount ,
		          SubCategoriescount ,
		          SupplierPaymentAgreementscount ,
		          Supplierscount ,
		          SupplierWiseItemDetailscount ,
		          TransactionRightscount ,
		          TransactionTypescount ,
		          UnitConversionscount ,
		          Unitscount ,
		          UserGroupPrivilegescount ,
		          UserGroupscount ,
		          UserMasterscount ,
		          UserPrivilegescount ,
		          UserPrivilegesLocationscount
		        )
		
		VALUES  ( @Companiescount  , -- Companiescount - int
				  @AdditionalChargesDetailscount  , -- AdditionalChargesDetailscount - int
		          @ApprovalTypescount , -- ApprovalTypescount - int
		          @AutoGenerateInfoescount , -- AutoGenerateInfoescount - int
		          @BrokerMasterscount , -- BrokerMasterscount - int
		          @Categoriescount , -- Categoriescount - int
		          @CurrencyMasterscount , -- CurrencyMasterscount - int
		          @Customerscount , -- Customerscount - int
		          @Departmentscount , -- Departmentscount - int
		          @Employeescount , -- Employeescount - int
		          @Locationscount , -- Locationscount - int
		          @Loginscount , -- Loginscount - int
		          @PaymentTermscount , -- PaymentTermscount - int
		          @RequestDetailscount , -- RequestDetailscount - int
		          @RequestHeaderscount , -- RequestHeaderscount - int
		          @SalesContractWiseExtrachargescount , -- SalesContractWiseExtrachargescount - int
		          @StockItemAttributescount , -- StockItemAttributescount - int
		          @StockItemClassificationDetailscount , -- StockItemClassificationDetailscount - int
		          @StockItemClassificationHeaderscount , -- StockItemClassificationHeaderscount - int
		          @StockItemDetailscount , -- StockItemDetailscount - int
		          @StockItemHeaderscount , -- StockItemHeaderscount - int
		          @StockItemReferencescount , -- StockItemReferencescount - int
		          @StockItemWiseAttributescount , -- StockItemWiseAttributescount - int
		          @StockItemWiseClassificationDetailscount , -- StockItemWiseClassificationDetailscount - int
		          @SubCategoriescount , -- SubCategoriescount - int
				  @SupplierPaymentAgreementscount,
				  @Supplierscount,
		          @SupplierWiseItemDetailscount , -- SupplierWiseItemDetailscount - int
		          @TransactionRightscount , -- TransactionRightscount - int
		          @TransactionTypescount , -- TransactionTypescount - int
		          @UnitConversionscount , -- UnitConversionscount - int
		          @Unitscount , -- Unitscount - int
		          @UserGroupPrivilegescount , -- UserGroupPrivilegescount - int
		          @UserGroupscount , -- UserGroupscount - int
		          @UserMasterscount , -- UserMasterscount - int
		          @UserPrivilegescount , -- UserPrivilegescount - int
		          @UserPrivilegesLocationscount  -- UserPrivilegesLocationscount - int,
		        )
        


		END
        		
		SELECT * FROM #TempTableCount


	IF OBJECT_ID(N'tempdb..#TempTableCount') IS NOT NULL
	BEGIN
	DROP TABLE #TempTableCount
	END

GO

