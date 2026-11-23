
CREATE PROCEDURE [dbo].[SP_Save_SuppliersRequest]
    @ID int,
    @PropertyID int,
    @Code nvarchar(10),
    @Name nvarchar(100),
    @Address1 nvarchar(100),
    @BillingAddress nvarchar(100),
    @Email nvarchar(255),
    @Telephone1 nvarchar(15),
    @Telephone2 nvarchar(15),
    @FaxNo nvarchar(15),
    @ContactPerson nvarchar(50),
    @CountryID int,
    @Remarks nvarchar(max),
    @CreditLimit decimal(18, 2),
    @CreditPeriod real,
    @PaymentTermID int,
    @CurrencyID int,
    @NameOnCheque nvarchar(max),
    @SupplierGradingID int,
    @IsDefaultSupplier bit,
    @IsActive bit,
    @IsLabor bit,
    @IPAddress nvarchar(max),
    @CreatedUserID int,
    @LastModUserID int,
    @CreatedDate datetime,
    @LastModDate datetime,
    @Action INT,
    @TempSupplierId int,
    @status INT OUTPUT,
    @NewId INT OUTPUT,
    @VatNo varchar(100),
    @DefaultPayType INT,
    @BankCode VARCHAR(5),
    @BranchCode VARCHAR(5),
    @CommAcc VARCHAR(12),
    @AccountNo VARCHAR(20),
    @PaymentGracePeriod MONEY,
    @DeductionCon BIT,
    @CreditorTypeID int,
    @IsConsigments bit = '',
    @isApprove bit = '',
	@IsPettyCash BIT =0,
    @SupplierCategoryID INT,
	@Email2 nvarchar(255),
    @message NVARCHAR(max) OUTPUT
AS
BEGIN
    DECLARE @statusIN INT
    SET @statusIN = 0;
	SET  @NewId =0
    SET @message = ''
	
	

    BEGIN TRY
        BEGIN TRANSACTION

        IF @Action = 1
            IF EXISTS (SELECT 1 FROM SuppliersRequest WHERE ID = @ID)
            BEGIN
				EXEC Inventry_AuditTail_WriteToLog 'SuppliersRequest', @ID, 'INV', 'SRU', 'U', @LastModUserID,@PropertyID, '', ''	
                EXEC InsertMasterFileChangeLog 'Supplier Request', @CreatedUserID, 'U', @Name

                UPDATE SuppliersRequest
                SET Name = @Name, Address1 = @Address1, Email = @Email,Email2 = @Email2, Telephone1 = @Telephone1, LastModUserID = @LastModUserID,
                    LastModDate = GETDATE(), VatNo = @VatNo, BillingAddress = @BillingAddress, FaxNo = @FaxNo, Telephone2 = @Telephone2,
                    ContactPerson = @ContactPerson, NameOnCheque = @NameOnCheque, Remarks = @Remarks, CreditPeriod = @CreditPeriod, CreditLimit = @CreditLimit,
                    CurrencyID = @CurrencyID, CommissionAcc = @CommAcc, DefaultPaymentType = @DefaultPayType, BankCode = @BankCode, BranchCode = @BranchCode,
                    AccountNo = @AccountNo, GracePeriod = @PaymentGracePeriod, DeductionControl = @DeductionCon,CreditorTypeID = @CreditorTypeID
                WHERE ID = @ID
                SET @statusIN = 2

                -----------newly added 14.02.2024---------------------------------
                IF (@LastModUserID = 0)
                BEGIN
                    RAISERROR('User ID Invalid, Please Log In Again', 16, 1)
                    ROLLBACK TRANSACTION
                END
                --------------------------------------------------------------------
            END
            ELSE
            BEGIN
                EXEC InsertMasterFileChangeLog 'Supplier Request', @CreatedUserID, 'I', @Name

                INSERT INTO SuppliersRequest (PropertyID, Name, Address1, Email,Email2, Telephone1, IsApprove, CreatedUserID, LastModUserID, CreatedDate, LastModDate, VatNo,
                    BillingAddress, FaxNo, Telephone2, ContactPerson, NameOnCheque, Remarks, CreditPeriod, CreditLimit, CurrencyID, CommissionAcc,
                    DefaultPaymentType, BankCode, BranchCode, AccountNo, GracePeriod, DeductionControl,CreditorTypeID)
                VALUES (@PropertyID, @Name, @Address1, @Email,@Email2, @Telephone1, 0, @CreatedUserID, @LastModUserID, GETDATE(), GETDATE(), @VatNo,
                    @BillingAddress, @FaxNo, @Telephone2, @ContactPerson, @NameOnCheque, @Remarks, @CreditPeriod, @CreditLimit, @CurrencyID, @CommAcc,
                    @DefaultPayType, @BankCode, @BranchCode, @AccountNo, @PaymentGracePeriod, @DeductionCon,@CreditorTypeID)
                SET @status = 1
				SET @NewId = SCOPE_IDENTITY() 
				
                --------------newly added 14.02.2024---------------------------------
                IF (@CreatedUserID = 0)
                BEGIN
                    RAISERROR('User ID Invalid, Please Log In Again', 16, 1)
                    ROLLBACK TRANSACTION
                END
                --------------------------------------------------------------------
				EXEC Inventry_AuditTail_WriteToLog 'SuppliersRequest', @NewId, 'INV', 'SRI', 'I', @CreatedUserID,@PropertyID, '', ''
				

				--Added by isuru 2025-07-02
				DECLARE @IsSupplierCreationMail BIT
				SELECT @IsSupplierCreationMail = ISNULL(IsSupplierCreationMail,0)
				FROM Companies
				WHERE CompanyID =  @PropertyID

				IF(@IsSupplierCreationMail =1)
				BEGIN
				EXEC [dbo].[SendTransactionWiseEmailS] 'SC',@NewId,0,@PropertyID,'C'
				END
				--end
            END


 ELSE IF @Action = 2

	 IF Exists ( Select * from SuppliersRequest where id = @ID)
 Begin
	 EXEC Inventry_AuditTail_WriteToLog 'SuppliersRequest', @ID, 'INV', 'SRD', 'D', @CreatedUserID,@PropertyID, '', ''	
	DELETE [SuppliersRequest] WHERE Id = @ID
	SET @statusIN = 3
 End

 else
 
 begin
 
	raiserror('Delete Id not found',16,1)
	ROLLBACK TRANSACTION
 end

        

        COMMIT TRAN -- Transaction Success!
		SET @status = @statusIN
		SET @NewId = -1

    END TRY
    BEGIN CATCH
	SET @statusIN = -1
        ROLLBACK TRANSACTION

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);

    END CATCH
END --SP ENDS

GO

