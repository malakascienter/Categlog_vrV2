/*  Four result sets: summary, per step, per channel, and why messages were
    suppressed.

    @VersionId NULL means every version. That is the right default for "how is
    this journey doing" - a journey republished twice would otherwise report only
    the newest slice and look like it had lost most of its members.

    @FromDate / @ToDate filter on when the member ENTERED, not on when a step
    ran. Filtering on step time would count a member who entered in March and
    received a reminder in April as an April entrant in one result set and a
    March entrant in another, and the two panels would disagree.                 */
CREATE PROCEDURE dbo.LTYJ_Journey_Analytics
    @JourneyId  int,
    @PropertyId int,
    @VersionId  int  = NULL,
    @FromDate   date = NULL,
    @ToDate     date = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.LTYJ_Journey
                   WHERE JourneyId = @JourneyId AND PropertyId = @PropertyId AND IsDeleted = 0)
        THROW 50401, 'This journey no longer exists.', 1;

    /*  Exclusive upper bound on the day after @ToDate: EnteredAt is a datetime2
        and "<= @ToDate" would silently drop everyone who entered after midnight
        on the last day of the range.                                            */
    DECLARE @ToExclusive datetime2(3) =
        CASE WHEN @ToDate IS NULL THEN NULL ELSE DATEADD(day, 1, CAST(@ToDate AS datetime2(3))) END;

    DECLARE @FromAt datetime2(3) =
        CASE WHEN @FromDate IS NULL THEN NULL ELSE CAST(@FromDate AS datetime2(3)) END;

    -- The runs in scope, resolved once. Every result set below joins to this.
    DECLARE @Runs TABLE
    (
        RunId       bigint      NOT NULL PRIMARY KEY,
        MemberId    int         NOT NULL,
        VersionId   int         NOT NULL,
        Status      varchar(20) NOT NULL,
        EnteredAt   datetime2(3)    NULL,
        EndedAt     datetime2(3)    NULL,
        ExitReason  varchar(100)    NULL
    );

    INSERT INTO @Runs (RunId, MemberId, VersionId, Status, EnteredAt, EndedAt, ExitReason)
    SELECT r.RunId, r.MemberId, r.VersionId, r.Status, r.EnteredAt, r.EndedAt, r.ExitReason
    FROM   dbo.LTYJ_Run AS r
    WHERE  r.JourneyId  = @JourneyId
      AND  r.PropertyId = @PropertyId
      AND  (@VersionId IS NULL OR r.VersionId = @VersionId)
      AND  (@FromAt      IS NULL OR r.EnteredAt >= @FromAt)
      AND  (@ToExclusive IS NULL OR r.EnteredAt <  @ToExclusive);

    ------------------------------------------------------------------
    -- 1. Summary
    ------------------------------------------------------------------
    SELECT
        TotalEntrants  = COUNT(*),
        -- ACTIVE and WAITING are both "still in the journey"; the difference is
        -- only whether a timer is running, which no marketer asks about.
        InJourney      = SUM(CASE WHEN Status IN ('ACTIVE','WAITING') THEN 1 ELSE 0 END),
        Completed      = SUM(CASE WHEN Status = 'COMPLETED' THEN 1 ELSE 0 END),
        Exited         = SUM(CASE WHEN Status = 'EXITED'    THEN 1 ELSE 0 END),
        Failed         = SUM(CASE WHEN Status = 'FAILED'    THEN 1 ELSE 0 END),
        Cancelled      = SUM(CASE WHEN Status = 'CANCELLED' THEN 1 ELSE 0 END),
        /*  Average time to finish, over finished runs only. Including runs still
            in flight would make a journey look faster the longer it ran, because
            every unfinished member would count as zero.                         */
        AvgHoursToFinish =
            AVG(CASE WHEN Status IN ('COMPLETED','EXITED') AND EndedAt IS NOT NULL
                     THEN CAST(DATEDIFF(minute, EnteredAt, EndedAt) AS decimal(18,2)) / 60.0 END),
        DistinctMembers = COUNT(DISTINCT MemberId)
    FROM @Runs;

    ------------------------------------------------------------------
    -- 2. Per step
    ------------------------------------------------------------------
    /*  Driven from the node rows of the version(s) in scope rather than from the
        executions, so a step nobody has reached yet appears with zeros instead of
        vanishing. A step that is missing from the report reads as "not built",
        which is a different and much more alarming thing than "not reached".     */
    SELECT
        n.NodeKey,
        n.NodeType,
        n.Label,
        n.VersionId,
        SortOrder   = MIN(n.NodeId),
        Entered     = COUNT(DISTINCT se.RunId),
        Succeeded   = COUNT(DISTINCT CASE WHEN se.Status = 'SUCCESS' THEN se.RunId END),
        Skipped     = COUNT(DISTINCT CASE WHEN se.Status = 'SKIPPED' THEN se.RunId END),
        Failed      = COUNT(DISTINCT CASE WHEN se.Status = 'FAILED'  THEN se.RunId END),
        -- Only meaningful on a condition; NULL elsewhere so the client does not
        -- draw a 0/0 split on a step that never branches.
        YesCount    = CASE WHEN n.NodeType = 'CONDITION'
                           THEN COUNT(DISTINCT CASE WHEN se.BranchTaken = 'YES' THEN se.RunId END) END,
        NoCount     = CASE WHEN n.NodeType = 'CONDITION'
                           THEN COUNT(DISTINCT CASE WHEN se.BranchTaken = 'NO'  THEN se.RunId END) END,
        -- Members parked on this step right now.
        StillHere   = (SELECT COUNT(*) FROM @Runs AS cur
                       WHERE cur.Status IN ('ACTIVE','WAITING')
                         AND EXISTS (SELECT 1 FROM dbo.LTYJ_Run AS rr
                                     WHERE rr.RunId = cur.RunId AND rr.CurrentNodeKey = n.NodeKey))
    FROM   dbo.LTYJ_Node AS n
    INNER JOIN dbo.LTYJ_JourneyVersion AS v
            ON v.VersionId = n.VersionId
           AND v.JourneyId = @JourneyId
           AND (@VersionId IS NULL OR v.VersionId = @VersionId)
    LEFT  JOIN dbo.LTYJ_StepExecution AS se
            ON se.NodeKey   = n.NodeKey
           AND se.VersionId = n.VersionId
           AND se.RunId IN (SELECT RunId FROM @Runs)
    GROUP BY n.NodeKey, n.NodeType, n.Label, n.VersionId
    ORDER BY n.VersionId, MIN(n.NodeId);

    ------------------------------------------------------------------
    -- 3. Per channel
    ------------------------------------------------------------------
    /*  HasProviderEvents is the honesty switch. Delivered / Opened / Clicked
        only exist when a provider reports them, and the logging and mock
        providers report nothing. Without this flag a channel with no reporting
        would show "0 opened", which reads as "nobody opened it" rather than
        "nobody measured it" - the plan forbids exactly that.                    */
    /*  The status counts and the event counts are aggregated SEPARATELY and then
        joined, which is not a stylistic choice.

        Counting both across one LEFT JOIN to LTYC_DeliveryEvent inflates every
        status: a dispatch with three events contributes three rows, so a channel
        with two sent messages and five events between them reported "5 sent".
        Test 181_T caught exactly that. COUNT(DISTINCT DispatchId) survives the
        fan-out; SUM(CASE...) does not.                                          */
    WITH scoped AS
    (
        SELECT d.DispatchId, d.Channel, d.Status
        FROM   dbo.LTYC_Dispatch AS d
        WHERE  d.RunId IN (SELECT RunId FROM @Runs)
    ),
    status_counts AS
    (
        SELECT Channel,
               Queued     = SUM(CASE WHEN Status = 'QUEUED'     THEN 1 ELSE 0 END),
               Deferred   = SUM(CASE WHEN Status = 'DEFERRED'   THEN 1 ELSE 0 END),
               Sent       = SUM(CASE WHEN Status = 'SENT'       THEN 1 ELSE 0 END),
               Failed     = SUM(CASE WHEN Status = 'FAILED'     THEN 1 ELSE 0 END),
               Suppressed = SUM(CASE WHEN Status = 'SUPPRESSED' THEN 1 ELSE 0 END)
        FROM   scoped
        GROUP BY Channel
    ),
    event_counts AS
    (
        /*  DISTINCT DispatchId throughout: a member who opens one email three
            times is one opened message, not three.                              */
        SELECT s.Channel,
               Delivered    = COUNT(DISTINCT CASE WHEN ev.EventType = 'DELIVERED'    THEN ev.DispatchId END),
               Opened       = COUNT(DISTINCT CASE WHEN ev.EventType = 'OPENED'       THEN ev.DispatchId END),
               Clicked      = COUNT(DISTINCT CASE WHEN ev.EventType = 'CLICKED'      THEN ev.DispatchId END),
               Bounced      = COUNT(DISTINCT CASE WHEN ev.EventType = 'BOUNCED'      THEN ev.DispatchId END),
               Unsubscribed = COUNT(DISTINCT CASE WHEN ev.EventType = 'UNSUBSCRIBED' THEN ev.DispatchId END)
        FROM   scoped AS s
        INNER JOIN dbo.LTYC_DeliveryEvent AS ev ON ev.DispatchId = s.DispatchId
        GROUP BY s.Channel
    )
    SELECT
        sc.Channel,
        sc.Queued,
        sc.Deferred,
        sc.Sent,
        sc.Failed,
        sc.Suppressed,
        -- A channel with no row in event_counts has no reporting at all, which is
        -- what the flag says. INNER JOIN above is what makes that true.
        HasProviderEvents = CASE WHEN ec.Channel IS NULL THEN CAST(0 AS bit) ELSE CAST(1 AS bit) END,
        Delivered    = ISNULL(ec.Delivered, 0),
        Opened       = ISNULL(ec.Opened, 0),
        Clicked      = ISNULL(ec.Clicked, 0),
        Bounced      = ISNULL(ec.Bounced, 0),
        Unsubscribed = ISNULL(ec.Unsubscribed, 0)
    FROM   status_counts AS sc
    LEFT  JOIN event_counts AS ec ON ec.Channel = sc.Channel
    ORDER BY sc.Channel;

    ------------------------------------------------------------------
    -- 4. Why messages were suppressed
    ------------------------------------------------------------------
    /*  The most operationally useful panel on the screen: it is the difference
        between "the journey is not working" and "nobody has consented".         */
    SELECT
        d.Channel,
        Reason = ISNULL(d.SuppressReason, 'UNKNOWN'),
        Total  = COUNT(*)
    FROM   dbo.LTYC_Dispatch AS d
    WHERE  d.RunId IN (SELECT RunId FROM @Runs)
      AND  d.Status = 'SUPPRESSED'
    GROUP BY d.Channel, ISNULL(d.SuppressReason, 'UNKNOWN')
    ORDER BY COUNT(*) DESC;
END

GO

