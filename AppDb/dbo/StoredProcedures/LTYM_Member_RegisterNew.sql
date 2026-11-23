
CREATE   PROCEDURE dbo.LTYM_Member_RegisterNew
    @FirstName    VARCHAR(100),
    @LastName     VARCHAR(100)  = NULL,
    @Salutation   NVARCHAR(8)   = N'',
    @Birthday     DATE          = NULL,
    @TelNo        VARCHAR(15),
    @Email        VARCHAR(150),
    @PasswordHash NVARCHAR(200),
    @CreatedBy    INT           = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- PropertyId is not part of this module's interface; the portal is single-property.
    DECLARE @PropertyId INT = dbo.LTYM_fn_DefaultPropertyId();
    SET XACT_ABORT ON;

    DECLARE @TransactionType VARCHAR(5) = 'MS';
    DECLARE @LocationCode    VARCHAR(20);
    DECLARE @DocNo           NVARCHAR(300);
    DECLARE @MembershipCode  VARCHAR(50);

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @LockResult INT;
        EXEC @LockResult = sp_getapplock
             @Resource    = 'LTYM_Member_RegisterNew',
             @LockOwner   = 'Transaction',
             @LockMode    = 'Exclusive',
             @LockTimeout = 5000,
             @DbPrincipal = 'public';

        IF @LockResult < 0
            THROW 52051, 'Registration is busy; please retry.', 1;

        DECLARE @TelAlt VARCHAR(15) = dbo.LTYM_fn_TelNoAlternate(@TelNo);

        IF EXISTS (SELECT 1 FROM dbo.LTY_Member
                   WHERE PropertyId = @PropertyId AND PrimaryMobileNo IN (@TelNo, @TelAlt))
            THROW 52050, 'This phone number already belongs to a loyalty member. Please register as an existing member instead.', 1;

        IF EXISTS (SELECT 1 FROM dbo.LTYM_MemberCredentials WHERE Email = @Email)
            THROW 52002, 'This email address is already registered.', 1;

        SET @LocationCode = dbo.LTY_GetSettingValue(1, @PropertyId);

        SELECT @DocNo = dbo.FN_LTY_GetNextDocumentNumber(@PropertyId, @LocationCode, @TransactionType);
        IF (@DocNo IS NULL)
        BEGIN
            EXEC dbo.LTY_InsertDocumentNumber @PropertyId, @LocationCode, @TransactionType;
            SELECT @DocNo = dbo.FN_LTY_GetNextDocumentNumber(@PropertyId, @LocationCode, @TransactionType);
        END

        SET @MembershipCode = CONCAT(TRIM(@TransactionType), '/', @LocationCode, '/', @DocNo);

        INSERT INTO dbo.LTY_Member
              (MembershipCode, PropertyId, Salutation, FirstName, LastName, Email,
               PrimaryMobileNo, SecondaryMobileNo, Address, BirthDay, IsActive,
               RegisterOutlet, TierId, CreatedBy, CreatedDate)
        VALUES (@MembershipCode, @PropertyId, ISNULL(@Salutation, N''), @FirstName, ISNULL(@LastName, ''), @Email,
                @TelNo, '', '', ISNULL(@Birthday, '19000101'), 1,
                @LocationCode, NULL, @CreatedBy, GETDATE());

        DECLARE @MemberId INT = SCOPE_IDENTITY();

        UPDATE dbo.LTY_TransactionTypeWiseNextNumbers
        SET    NextNumber = NextNumber + 1
        WHERE  PropertyID      = @PropertyId
          AND  LocationCode    = @LocationCode
          AND  TransactionType = @TransactionType;

        INSERT INTO dbo.LTYM_MemberCredentials (MemberId, Email, PasswordHash, IsVerified)
        VALUES (@MemberId, @Email, @PasswordHash, 1);

        COMMIT TRANSACTION;

        SELECT @MemberId AS MemberId, @MembershipCode AS MembershipNo;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

