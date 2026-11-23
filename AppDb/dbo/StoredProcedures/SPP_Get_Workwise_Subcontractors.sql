CREATE  PROCEDURE [dbo].[SPP_Get_Workwise_Subcontractors]
    @ProjectID INT ,
    @BOQID INT ,
    @SectionID INT ,
    @WorkID INT
AS
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION 
            SELECT  S.Id ,
                    PropertyID ,
                    Code Name ,
                    Address1 ,
                    BillingAddress ,
                    Email ,
                    Telephone1 ,
                    Telephone2 ,
                    FaxNo ,
                    ContactPerson ,
                    CountryID ,
                    Remarks ,
                    CreditLimit ,
                    CreditPeriod ,
                    PaymentTermID ,
                    CurrencyID ,
                    NameOnCheque ,
                    SupplierGradingID ,
                    IsDefaultSupplier ,
                    IsActive ,
                    IsLabor ,
                    S.IPAddress ,
                    S.CreatedUserID ,
                    S.LastModUserID ,
                    S.LastModDate
            FROM    SubContractors AS S
                    INNER JOIN dbo.ProjectWiseSubcontractors AS PS ON S.ID = PS.SubcontractorID
            WHERE   PS.ProjectID = @ProjectID
                    AND PS.BOQID = @BOQID
                    AND PS.MainWorkID = @SectionID
                    AND PS.WorkID = @WorkID

			
            COMMIT TRANSACTION


        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRAN --RollBack in case of Error
        END CATCH 





    END

	--[dbo].[SPP_Get_Workwise_Subcontractors] 
	--SELECT * FROM dbo.ProjectWiseSubcontractors

GO

