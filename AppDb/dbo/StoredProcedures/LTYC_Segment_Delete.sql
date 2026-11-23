/*  Soft delete, and the materialised membership goes with it -- there is no
    reason to keep rows nobody can reach, and they would otherwise be counted by
    the member-side "which segments am I in?" lookup the Braze sync uses.        */
CREATE PROCEDURE dbo.LTYC_Segment_Delete
    @SegmentId  int,
    @PropertyId int,
    @ActionBy   int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.LTYC_Segment
                       WHERE SegmentId = @SegmentId AND PropertyId = @PropertyId AND IsDeleted = 0)
            THROW 50501, 'This segment no longer exists.', 1;

        UPDATE dbo.LTYC_Segment
        SET    IsDeleted = 1, IsActive = 0,
               ModifiedBy = @ActionBy, ModifiedDate = SYSUTCDATETIME()
        WHERE  SegmentId = @SegmentId;

        DELETE FROM dbo.LTYC_SegmentMember WHERE SegmentId = @SegmentId;

        INSERT INTO dbo.LTYJ_AuditLog (PropertyId, EntityType, EntityId, Action, ActorUserId)
        VALUES (@PropertyId, 'SEGMENT', @SegmentId, 'DELETE', @ActionBy);

        COMMIT TRANSACTION;

        SELECT @SegmentId AS SegmentId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

