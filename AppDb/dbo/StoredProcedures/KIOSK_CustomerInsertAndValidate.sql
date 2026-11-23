-- =============================================
-- Author:      Ravindu
-- Create date: 2026-10-19
-- Description: Customer save / lookup for Kiosk.
-- =============================================
CREATE   PROCEDURE dbo.KIOSK_CustomerInsertAndValidate
    @CustomerName  NVARCHAR(200)  = NULL,
    @MobileNo      NVARCHAR(30)   = NULL,
    @CurrencyID    INT            = 1,
    @CompanyId     INT            = 1,
    @LocationId    INT            = 1,
    @UserID        INT            = 1,
    @CreditLimit   DECIMAL(18,2)  = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @MobileNo     = LTRIM(RTRIM(ISNULL(@MobileNo,     N'')));
    SET @CustomerName = LTRIM(RTRIM(ISNULL(@CustomerName, N'')));

    IF @MobileNo = N''
        THROW 50001, 'Mobile number is required.', 1;

    DECLARE @Tail VARCHAR(9) =
        RIGHT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
            @MobileNo, '+', ''), ' ', ''), '-', ''), '(', ''), ')', ''), '.', ''), 9);

    IF @Tail = ''
        THROW 50001, 'Mobile number is required.', 1;

    IF @CustomerName = N''
    BEGIN
        DECLARE @ExistingId   INT            = NULL;
        DECLARE @ExistingName NVARCHAR(200)  = NULL;

        SELECT TOP 1
               @ExistingId   = c.Id,
               @ExistingName = c.CustomerName
        FROM   dbo.Customers AS c
        CROSS APPLY (VALUES (c.Tele1), (c.Tele2), (c.Tele3)) AS t(Tele)
        WHERE  ISNULL(t.Tele, N'') <> N''
          AND  RIGHT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                   t.Tele, '+', ''), ' ', ''), '-', ''), '(', ''), ')', ''), '.', ''), 9) = @Tail
        ORDER BY c.Id;

        SELECT CAST(CASE WHEN @ExistingId IS NULL THEN 0 ELSE 1 END AS BIT) AS IsExisting,
               ISNULL(@ExistingId, 0)                                       AS CustomerId,
               @ExistingName                                                AS CustomerName;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (
            SELECT 1
            FROM   dbo.Customers AS c WITH (UPDLOCK, HOLDLOCK)
            CROSS APPLY (VALUES (c.Tele1), (c.Tele2), (c.Tele3)) AS t(Tele)
            WHERE  ISNULL(t.Tele, N'') <> N''
              AND  RIGHT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                       t.Tele, '+', ''), ' ', ''), '-', ''), '(', ''), ')', ''), '.', ''), 9) = @Tail
        )
        BEGIN
            THROW 50003, 'This mobile number already exists.', 1;
        END

        INSERT INTO dbo.Customers
        (
            CustomerName, Tele1,
            CurrencyID, IsActive,
            CreatedUserID, LastModUserID,
            CreatedDate, LastModDate,
            CompanyId, LocationId,
            IsVat, CreditLimit
        )
        VALUES
        (
            @CustomerName, @MobileNo,
            @CurrencyID, 1,
            @UserID, @UserID,
            GETDATE(), GETDATE(),
            @CompanyId, @LocationId,
            0, @CreditLimit
        );

        DECLARE @NewCustomerId INT = CAST(SCOPE_IDENTITY() AS INT);

        COMMIT TRANSACTION;

        SELECT CAST(0 AS BIT)  AS IsExisting,
               @NewCustomerId  AS CustomerId,
               @CustomerName   AS CustomerName;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

