
CREATE PROCEDURE Sys_InitializeData
	
	@password nvarchar(20)

AS
BEGIN


BEGIN TRY
	BEGIN TRANSACTION

/*********************************************************************************************************************************************************/

if(@password <>'asdqwe123#')
begin
	
	RAISERROR ('invalied password',8,2) 

end
else
begin
-- truncate all Master Data
--TRUNCATE TABLE  approvaltypes
TRUNCATE TABLE  AdditionalChargesDetails
TRUNCATE TABLE  ApprovalLogs
TRUNCATE TABLE  AltItemGroups
TRUNCATE TABLE  AltItemGroupDetails
TRUNCATE TABLE  [dbo].[BrokerMasters]
TRUNCATE TABLE  [dbo].[Categories]
TRUNCATE TABLE  [dbo].[Clients]
TRUNCATE TABLE  [dbo].[Companies]
TRUNCATE TABLE  [dbo].[CostTypes]
--TRUNCATE TABLE  [dbo].[CurrencyMasters]
TRUNCATE TABLE  [dbo].[Customers]
TRUNCATE TABLE  [dbo].[DeliveryAddressDetails]
TRUNCATE TABLE  [dbo].[Departments]
TRUNCATE TABLE  [dbo].[Employees]
TRUNCATE TABLE  [dbo].[LaborTypeMasterFiles]
TRUNCATE TABLE  [dbo].[Locations]
TRUNCATE TABLE  [dbo].[LocationWiseTransactionTypes]
TRUNCATE TABLE  [dbo].[Logins] 
TRUNCATE TABLE  [dbo].[PaymentTerms]
TRUNCATE TABLE  [dbo].[PaymentTermsDetails]
TRUNCATE TABLE  [dbo].[Suppliers]
--TRUNCATE TABLE  [dbo].[TaxDetails]
--TRUNCATE TABLE  [dbo].[TaxGroupDetails] 
--TRUNCATE TABLE  [dbo].[TaxGroups]
TRUNCATE TABLE  [dbo].[UnitConversions]
TRUNCATE TABLE  [dbo].[Units]
TRUNCATE TABLE  [dbo].[UserGroupPrivileges]
TRUNCATE TABLE  [dbo].[UserGroups]
TRUNCATE TABLE  [dbo].[UserMasters]
TRUNCATE TABLE  [dbo].[UserPrivileges]
TRUNCATE TABLE  [dbo].[UserPrivilegesLocations]
TRUNCATE TABLE  [dbo].[UserProfiles]
TRUNCATE TABLE  [dbo].[UserWise_Location]
TRUNCATE TABLE  [dbo].[UserWiseApproveLevels]
TRUNCATE TABLE  [dbo].[UserWiseCompanies]


--BOQ details 
TRUNCATE TABLE  [dbo].[ProjectDetails]
TRUNCATE TABLE  BOQHeaders
TRUNCATE TABLE  BOQMainWorkAllocations
TRUNCATE TABLE  BOQRateanalysisAllocationDetails
TRUNCATE TABLE  BOQRateanalysisAllocationHeaders
TRUNCATE TABLE  BOQSubWorkAllocations
TRUNCATE TABLE  [dbo].[RateAnalysisHeaders]
TRUNCATE TABLE  [dbo].[RateAnalysisDetails]
TRUNCATE TABLE  [dbo].[WorkHeaders]
TRUNCATE TABLE  [dbo].[WorkDoneRegistries]
TRUNCATE TABLE  [dbo].[WorkDetails]

--MRN Related Data
TRUNCATE TABLE  [dbo].[MRNItemRegistries]
TRUNCATE TABLE  [dbo].[MRNPOBalances]
TRUNCATE TABLE  [dbo].[MRNRegistries]
TRUNCATE TABLE  [dbo].[MRNRegistryDetails]


--Process Data
TRUNCATE TABLE  PoDetails
TRUNCATE TABLE  PoHeaders
TRUNCATE TABLE  PoWisePRs
--TRUNCATE TABLE  [dbo].[POtypes]
TRUNCATE TABLE  [dbo].[POwiseTaxes]
TRUNCATE TABLE  [dbo].[ProfomaInvoiceHeaders]
TRUNCATE TABLE  [dbo].[ProformaInvoiceDetails]
TRUNCATE TABLE  [dbo].[RequestHeaders]
TRUNCATE TABLE  [dbo].[RequestDetails]
TRUNCATE TABLE  [dbo].[SalesContractWiseExtracharges]
TRUNCATE TABLE  [dbo].[StockItemAttributes]
TRUNCATE TABLE  [dbo].[StockItemClassificationDetails]
TRUNCATE TABLE  [dbo].[StockItemClassificationHeaders]
TRUNCATE TABLE  [dbo].[StockItemDetails]
TRUNCATE TABLE  [dbo].[StockItemHeaders]
TRUNCATE TABLE  [dbo].[StockItemReferences]
TRUNCATE TABLE  [dbo].[StockItemWiseAttributes]
TRUNCATE TABLE  [dbo].[StockItemWiseClassificationDetails]
TRUNCATE TABLE  [dbo].[StockItemWiseEXPDateIns]
TRUNCATE TABLE  [dbo].[StockTransactionDetails]
TRUNCATE TABLE  [dbo].[StockTransactionHeaders]
TRUNCATE TABLE  [dbo].[StockTransactionwiseCharges]
TRUNCATE TABLE  [dbo].[StockTransactionwiseTaxes]
TRUNCATE TABLE  [dbo].[SubCategories]
TRUNCATE TABLE  [dbo].[SupplierGradingDetails]
TRUNCATE TABLE  [dbo].[SupplierPaymentAgreements]
TRUNCATE TABLE  [dbo].[SupplierWiseItemDetails]
TRUNCATE TABLE  [dbo].[TransactionRights]
TRUNCATE TABLE  [dbo].[TransactionTypeWiseNextNumbers]
TRUNCATE TABLE  [dbo].[TransactionWiseApprovalTypes]


--insert Employee
INSERT INTO [dbo].[Employees]
           ([CompanyID],[LocationID],[DepartmentID],[Code],[Title],[Name],[Designation],[Gender],[Remark],[Address1],[Address2],[Address3],[Email],[Telephone],[Mobile],[Image],[IsActive],[MinimumDiscount],[CrLimit],[PchLimit],[AccCredit],[AccPch],[IsDelete],[CostCenterID],[IPAddress],[CreatedUserID],[LastModUserID],[CreatedDate],[LastModDate])
VALUES     (1,1,1,'E0001','MR','System','-','-','-','-','-','-','-','-','-',null,1,0,0,0,0,0,0,0,'',1,1,GETDATE(),GETDATE())

--User groups 
INSERT INTO [dbo].[UserGroups]
           ([UserGroupName],[IsActive],[IPAddress],[CreatedUserID],[LastModUserID],[CreatedDate],[LastModDate])
VALUES ('Administrators',1,'-',1,1,GETDATE(),GETDATE())

--Insert System And Admin
INSERT INTO [dbo].[UserMasters]
           ([CompanyID],[LocationID],[UserName],[UserDescription],[Password],[UserGroupID],[IsActive],[IsUserCantChangePassword],[IsUserMustChangePassword],[IsDelete],[EmployeeId],[IPAddress],[CreatedUserID],[LastModUserID],[CreatedDate],[LastModDate])
VALUES     (1,1,'System','System Administrator','asdqwe123#',1,1,1,0,0,1,'-',1,1,GETDATE(),GETDATE())

INSERT INTO [dbo].[UserMasters]
           ([CompanyID],[LocationID],[UserName],[UserDescription],[Password],[UserGroupID],[IsActive],[IsUserCantChangePassword],[IsUserMustChangePassword],[IsDelete],[EmployeeId],[IPAddress],[CreatedUserID],[LastModUserID],[CreatedDate],[LastModDate])
VALUES     (1,1,'Admin','Administrator','asdqwe123#',1,1,1,0,0,1,'-',1,1,GETDATE(),GETDATE())

INSERT INTO [dbo].[UserMasters]
           ([CompanyID],[LocationID],[UserName],[UserDescription],[Password],[UserGroupID],[IsActive],[IsUserCantChangePassword],[IsUserMustChangePassword],[IsDelete],[EmployeeId],[IPAddress],[CreatedUserID],[LastModUserID],[CreatedDate],[LastModDate])
VALUES     (1,1,'Sceinter','Sceinter Administrator','asdqwe123#',1,1,1,0,0,1,'-',1,1,GETDATE(),GETDATE())

--Insert Default Company
INSERT INTO [dbo].[Companies]
           ([GroupofcompanyID],[Code],[Name],[IsActive],[OtherBusinessName1],[Address1],[Address2],[Address3],[Telephone1],[Telephone2]
           ,[Mobile],[FaxNo],[Email],[WebAddress],[ContactPerson],[TaxID1],[TaxID2],[TaxID3],[TaxRegistrationNumber1],[TaxRegistrationNumber2]
           ,[TaxRegistrationNumber3],[StartOfFiscalYear],[CostingMethod],[IsVat],[IPAddress],[CreatedUserID],[LastModUserID],[CreatedDate],[LastModDate])
VALUES     (1,'C001','Default Company',1,'-','-','-','-','-','-','-','-','-','-','-', '-','-','-','-','-','-',2018,'-',0,'-',1,1,GETDATE(),GETDATE())


--Insert Location
INSERT INTO [dbo].[Locations]
           ([CompanyID],[Code],[Name],[IsActive] ,[IPAddress],[CreatedUserID],[LastModUserID],[CreatedDate],[LastModDate])
VALUES(1,'L001','Head Office', 1 ,'-',1,1,GETDATE(),GETDATE())

--Insert Default Department
INSERT INTO [dbo].[Departments]
           ([LocationID],[Code],[Name],[IsApplyForFO] ,[IsApplyForInv],[IsApplyForBan],[IsActive],[IPAddress],[CreatedUserID],[LastModUserID],[CreatedDate],[LastModDate],[PropertyID])
VALUES (1,'D001','Adminstrative',1,1,1,1,'-',1,1,GETDATE(),GETDATE(),1)


--insert UserWiseCompanies
----For System
INSERT INTO [dbo].[UserWiseCompanies]
           ([UserId],[CompnayId],[IPAddress],[CreatedUserID],[LastModUserID],[CreatedDate],[LastModDate])
VALUES		(1,1,'-',1,1,GETDATE(),GETDATE())
----For Admin
INSERT INTO [dbo].[UserWiseCompanies]
           ([UserId],[CompnayId],[IPAddress],[CreatedUserID],[LastModUserID],[CreatedDate],[LastModDate])
VALUES		(2,1,'-',1,1,GETDATE(),GETDATE())
----Scienter administrator
INSERT INTO [dbo].[UserWiseCompanies]
           ([UserId],[CompnayId],[IPAddress],[CreatedUserID],[LastModUserID],[CreatedDate],[LastModDate])
VALUES		(3,1,'-',1,1,GETDATE(),GETDATE())


	
select 'Transaction Completed!..'	   

end



/*********************************************************************************************************************************************************/


COMMIT TRAN -- Transaction Success!
END TRY
BEGIN CATCH
	return CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH

END

GO

