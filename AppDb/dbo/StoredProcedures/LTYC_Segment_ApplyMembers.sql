/*  Apply a computed membership as a delta.

    The application runs the compiled segment SQL, bulk-loads the resulting ids
    into #SegmentResult, and calls this. Splitting it that way keeps the dynamic
    half in one audited compiler and the durable half here, where it can be read
    and reasoned about.

    Requires a temp table created by the caller:

        CREATE TABLE #SegmentResult (MemberId int NOT NULL PRIMARY KEY);

    Only genuine changes are written, so AddedAt keeps meaning "when this member
    joined" rather than "when the job last ran".                                 */
CREATE PROCEDURE dbo.LTYC_Segment_ApplyMembers
    @SegmentId  int,
    @PropertyId int,
    @ElapsedMs  int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF OBJECT_ID('tempdb..#SegmentResult') IS NULL
        THROW 50507, 'The caller must create #SegmentResult before applying membership.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @now datetime2(3) = SYSUTCDATETIME();
        DECLARE @snapshot int =
            ISNULL((SELECT SnapshotVersion FROM dbo.LTYC_Segment WHERE SegmentId = @SegmentId), 0) + 1;

        DELETE sm
        FROM   dbo.LTYC_SegmentMember AS sm
        WHERE  sm.SegmentId = @SegmentId
          AND  NOT EXISTS (SELECT 1 FROM #SegmentResult AS r WHERE r.MemberId = sm.MemberId);

        DECLARE @removed int = @@ROWCOUNT;

        INSERT INTO dbo.LTYC_SegmentMember (SegmentId, MemberId, PropertyId, AddedAt, SnapshotVersion)
        SELECT @SegmentId, r.MemberId, @PropertyId, @now, @snapshot
        FROM   #SegmentResult AS r
        WHERE  NOT EXISTS (SELECT 1 FROM dbo.LTYC_SegmentMember AS sm
                           WHERE sm.SegmentId = @SegmentId AND sm.MemberId = r.MemberId);

        DECLARE @added int = @@ROWCOUNT;
        DECLARE @total int = (SELECT COUNT(*) FROM dbo.LTYC_SegmentMember WHERE SegmentId = @SegmentId);

        UPDATE dbo.LTYC_Segment
        SET    LastRefreshedAt    = @now,
               LastRefreshMs      = @ElapsedMs,
               LastEstimatedCount = @total,
               LastEstimatedAt    = @now,
               SnapshotVersion    = @snapshot
        WHERE  SegmentId = @SegmentId;

        COMMIT TRANSACTION;

        SELECT @added AS Added, @removed AS Removed, @total AS TotalMembers, @snapshot AS SnapshotVersion;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

