/*  Open a run and enqueue one item per member of the segment.

    Members are enqueued as SKIPPED with a reason rather than omitted, so the run
    accounts for every member of the segment. A run reporting 11,900 of 12,540
    sent should be able to say what happened to the other 640.

    @ExternalIdAttribute names the loyalty field used as Braze's external_id.
    Only MembershipCode and MemberId are permitted -- an arbitrary field would
    let a run key profiles on something that is not unique or not stable.        */
CREATE PROCEDURE dbo.LTYC_BrazeSync_Start
    @SegmentId           int,
    @PropertyId          int,
    @Mode                varchar(10)  = 'MOCK',
    @ExternalIdAttribute varchar(60)  = 'MembershipCode',
    @RequireConsent      bit          = 1,
    @ConsentChannel      varchar(20)  = 'EMAIL',
    @UnknownConsentDefault varchar(10) = 'DENY',
    @TriggeredBy         int          = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF (@Mode NOT IN ('MOCK','LIVE'))
            THROW 50601, 'The sync mode must be MOCK or LIVE.', 1;

        IF (@ExternalIdAttribute NOT IN ('MembershipCode','MemberId'))
            THROW 50602, 'The external id must be MembershipCode or MemberId.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.LTYC_Segment
                       WHERE SegmentId = @SegmentId AND PropertyId = @PropertyId AND IsDeleted = 0)
            THROW 50603, 'This segment no longer exists.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.LTYC_SegmentMember WHERE SegmentId = @SegmentId)
            THROW 50604, 'This segment has no members. Refresh it before syncing.', 1;

        -- A second run while one is still going would post the same members
        -- twice and make the counts meaningless.
        IF EXISTS (SELECT 1 FROM dbo.LTYC_BrazeSync
                   WHERE SegmentId = @SegmentId AND Status IN ('QUEUED','RUNNING'))
            THROW 50605, 'A sync is already running for this segment.', 1;

        DECLARE @snapshot int = ISNULL((SELECT SnapshotVersion FROM dbo.LTYC_Segment WHERE SegmentId = @SegmentId), 0);

        INSERT INTO dbo.LTYC_BrazeSync
              (PropertyId, SegmentId, Status, Mode, ExternalIdAttribute, SnapshotVersion, StartedAt, TriggeredBy)
        VALUES(@PropertyId, @SegmentId, 'RUNNING', @Mode, @ExternalIdAttribute, @snapshot, SYSUTCDATETIME(), @TriggeredBy);

        DECLARE @SyncId int = SCOPE_IDENTITY();

        INSERT INTO dbo.LTYC_BrazeSyncItem (SyncId, MemberId, ExternalId, Status, SkipReason)
        SELECT @SyncId,
               sm.MemberId,
               CASE @ExternalIdAttribute
                   WHEN 'MembershipCode' THEN NULLIF(LTRIM(RTRIM(m.MembershipCode)), '')
                   ELSE CONVERT(nvarchar(100), sm.MemberId)
               END,
               CASE
                   WHEN CASE @ExternalIdAttribute
                            WHEN 'MembershipCode' THEN NULLIF(LTRIM(RTRIM(m.MembershipCode)), '')
                            ELSE CONVERT(nvarchar(100), sm.MemberId)
                        END IS NULL THEN 'SKIPPED'
                   -- Consent first: an opted-out member is never exported.
                   WHEN @RequireConsent = 1
                        AND dbo.FN_LTYC_IsOptedIn(sm.MemberId, @ConsentChannel, @UnknownConsentDefault) = 0
                        THEN 'SKIPPED'
                   ELSE 'PENDING'
               END,
               CASE
                   WHEN CASE @ExternalIdAttribute
                            WHEN 'MembershipCode' THEN NULLIF(LTRIM(RTRIM(m.MembershipCode)), '')
                            ELSE CONVERT(nvarchar(100), sm.MemberId)
                        END IS NULL THEN 'NO_EXTERNAL_ID'
                   WHEN @RequireConsent = 1
                        AND dbo.FN_LTYC_IsOptedIn(sm.MemberId, @ConsentChannel, @UnknownConsentDefault) = 0
                        THEN 'NO_CONSENT'
                   ELSE NULL
               END
        FROM   dbo.LTYC_SegmentMember AS sm
        INNER JOIN dbo.LTY_Member     AS m ON m.MemberId = sm.MemberId
        WHERE  sm.SegmentId = @SegmentId
          AND  m.IsActive   = 1;

        DECLARE @total   int = (SELECT COUNT(*) FROM dbo.LTYC_BrazeSyncItem WHERE SyncId = @SyncId);
        DECLARE @skipped int = (SELECT COUNT(*) FROM dbo.LTYC_BrazeSyncItem WHERE SyncId = @SyncId AND Status = 'SKIPPED');

        UPDATE dbo.LTYC_BrazeSync
        SET    TotalCount = @total, SkippedCount = @skipped
        WHERE  SyncId = @SyncId;

        INSERT INTO dbo.LTYJ_AuditLog (PropertyId, EntityType, EntityId, Action, ActorUserId, AfterJson)
        VALUES (@PropertyId, 'BRAZE_SYNC', @SyncId, 'SYNC', @TriggeredBy,
                (SELECT @SegmentId AS segmentId, @Mode AS mode, @ExternalIdAttribute AS externalIdAttribute,
                        @total AS total, @skipped AS skipped
                 FOR JSON PATH, WITHOUT_ARRAY_WRAPPER));

        COMMIT TRANSACTION;

        SELECT @SyncId AS SyncId, @total AS TotalCount, @skipped AS SkippedCount;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

