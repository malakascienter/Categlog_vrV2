/*  Soft delete. The captured answers are LEFT IN PLACE: a field retired by
    mistake is restored by clearing the flag, and deleting a column's worth of
    customer-supplied data on a click is not recoverable. The registry row is
    deactivated so the builder stops offering it.                                */
CREATE PROCEDURE dbo.LTYC_MemberAttribute_Delete
    @AttributeId int,
    @PropertyId  int,
    @ActionBy    int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.LTYC_MemberAttribute
                       WHERE AttributeId = @AttributeId AND PropertyId = @PropertyId AND IsDeleted = 0)
        BEGIN
            THROW 50608, 'This attribute no longer exists.', 1;
        END

        UPDATE dbo.LTYC_MemberAttribute
        SET    IsDeleted = 1, IsActive = 0, ModifiedBy = @ActionBy, ModifiedDate = SYSUTCDATETIME()
        WHERE  AttributeId = @AttributeId;

        EXEC dbo.LTYC_MemberAttribute_SyncRegistry @AttributeId = @AttributeId;

        INSERT INTO dbo.LTYJ_AuditLog (PropertyId, EntityType, EntityId, Action, ActorUserId)
        VALUES (@PropertyId, 'MEMBER_ATTRIBUTE', @AttributeId, 'DELETE', @ActionBy);

        COMMIT TRANSACTION;

        SELECT @AttributeId AS AttributeId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

