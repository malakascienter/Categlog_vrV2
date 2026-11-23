
CREATE   PROCEDURE [dbo].[LTYM_Member_Profile_Update]
    @MemberId    INT,
    @FirstName   VARCHAR(100),
    @LastName    VARCHAR(100) = NULL,
    @CallingName NVARCHAR(100) = NULL,
    @DOB         NVARCHAR(50) = NULL,
    @Anniversary NVARCHAR(50) = NULL,
    @ModifyBy    INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- PropertyId is not part of this module's interface; it comes from the member row.
    DECLARE @PropertyId INT = (SELECT TOP (1) PropertyId FROM dbo.LTY_Member WHERE MemberId = @MemberId);
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Birthday DATE = TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(ISNULL(@DOB, ''))), ''), 23);

        UPDATE dbo.LTY_Member
        SET    FirstName  = @FirstName,
               LastName   = ISNULL(@LastName, ''),
               BirthDay   = ISNULL(@Birthday, BirthDay),
               ModifyBy   = @ModifyBy,
               ModifyDate = GETDATE()
        WHERE  MemberId   = @MemberId
          AND  PropertyId = @PropertyId;

        IF @@ROWCOUNT = 0
            THROW 52020, 'Member not found.', 1;

        IF EXISTS (SELECT 1 FROM dbo.LTYM_MemberProfileExt WHERE MemberId = @MemberId)
            UPDATE dbo.LTYM_MemberProfileExt
            SET    CallingName = @CallingName,
                   Anniversary = @Anniversary,
                   UpdatedAt   = SYSUTCDATETIME()
            WHERE  MemberId    = @MemberId;
        ELSE
            INSERT INTO dbo.LTYM_MemberProfileExt (MemberId, CallingName, Anniversary)
            VALUES (@MemberId, @CallingName, @Anniversary);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

