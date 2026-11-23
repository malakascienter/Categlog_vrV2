/*  Run one queued message through every gateway stage and return a verdict.

    Returns exactly one row:

        Decision       SEND | SUPPRESS | DEFER
        SuppressReason why it was stopped, when SUPPRESS
        DeferUntil     when to try again, when DEFER
        Recipient      the resolved address, when SEND

    Transactional messages (SourceType = 'TXN') skip consent and frequency
    capping. Capping a password reset or an OTP would be a defect, not
    compliance. They still respect nothing else - a transactional message goes
    immediately, including at 3am, because that is what the member just asked for.
    ============================================================================ */
CREATE PROCEDURE dbo.LTYC_Dispatch_Evaluate
    @DispatchId          bigint,
    @UnknownDefault      varchar(10) = 'DENY',
    -- Used when the member has no timezone and the property has no policy default.
    @FallbackTimeZone    varchar(64) = 'UTC'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PropertyId int, @MemberId int, @Channel varchar(20), @SourceType varchar(20);

    SELECT @PropertyId = d.PropertyId,
           @MemberId   = d.MemberId,
           @Channel    = d.Channel,
           @SourceType = d.SourceType
    FROM   dbo.LTYC_Dispatch AS d
    WHERE  d.DispatchId = @DispatchId;

    IF (@MemberId IS NULL)
    BEGIN
        SELECT 'SUPPRESS' AS Decision, 'NO_MEMBER' AS SuppressReason,
               CAST(NULL AS datetime2(3)) AS DeferUntil, CAST(NULL AS nvarchar(300)) AS Recipient;
        RETURN;
    END

    DECLARE @isTransactional bit = CASE WHEN @SourceType = 'TXN' THEN 1 ELSE 0 END;

    ---- 1. consent ----------------------------------------------------------
    IF (@isTransactional = 0)
    BEGIN
        IF (dbo.FN_LTYC_IsOptedIn(@MemberId, @Channel, @UnknownDefault) = 0)
        BEGIN
            SELECT 'SUPPRESS' AS Decision, 'NO_CONSENT' AS SuppressReason,
                   CAST(NULL AS datetime2(3)) AS DeferUntil, CAST(NULL AS nvarchar(300)) AS Recipient;
            RETURN;
        END
    END

    ---- 2. reachability -----------------------------------------------------
    DECLARE @Recipient nvarchar(300) = NULL;

    IF (@Channel = 'EMAIL')
    BEGIN
        -- Portal credentials first: that address was verified at registration.
        -- LTY_Member.Email is the POS-captured one and may be stale or blank.
        SELECT TOP (1) @Recipient = mc.Email
        FROM   dbo.LTYM_MemberCredentials AS mc
        WHERE  mc.MemberId = @MemberId AND NULLIF(LTRIM(RTRIM(mc.Email)), '') IS NOT NULL;

        IF (@Recipient IS NULL)
            SELECT TOP (1) @Recipient = m.Email
            FROM   dbo.LTY_Member AS m
            WHERE  m.MemberId = @MemberId AND NULLIF(LTRIM(RTRIM(m.Email)), '') IS NOT NULL;

        IF (@Recipient IS NULL)
        BEGIN
            SELECT 'SUPPRESS' AS Decision, 'NO_ADDRESS' AS SuppressReason,
                   CAST(NULL AS datetime2(3)) AS DeferUntil, CAST(NULL AS nvarchar(300)) AS Recipient;
            RETURN;
        END
    END
    ELSE IF (@Channel = 'PUSH')
    BEGIN
        /*  No registered device means nothing to send to. This is the expected
            outcome until a member client exists to register tokens (Q7), and it
            is recorded rather than reported as sent.                            */
        IF NOT EXISTS (SELECT 1 FROM dbo.LTYC_DeviceToken AS t
                       WHERE t.MemberId = @MemberId AND t.IsActive = 1)
        BEGIN
            SELECT 'SUPPRESS' AS Decision, 'NO_DEVICE_TOKEN' AS SuppressReason,
                   CAST(NULL AS datetime2(3)) AS DeferUntil, CAST(NULL AS nvarchar(300)) AS Recipient;
            RETURN;
        END

        SET @Recipient = CONCAT('device:', @MemberId);
    END
    ELSE IF (@Channel = 'INAPP')
    BEGIN
        -- The in-app inbox always exists for a member; nothing to resolve.
        SET @Recipient = CONCAT('inbox:', @MemberId);
    END

    ---- 3. frequency cap ----------------------------------------------------
    IF (@isTransactional = 0)
    BEGIN
        DECLARE @now datetime2(3) = SYSUTCDATETIME();

        DECLARE @CapReason varchar(40) = NULL;

        /*  Every active cap that applies to this channel, most specific first.
            A channel-specific policy outranks an all-channel one at the same
            priority.                                                            */
        SELECT TOP (1) @CapReason =
               CASE
                   WHEN p.MaxCount IS NOT NULL AND sent.SentCount >= p.MaxCount THEN 'FREQUENCY_CAP'
                   WHEN p.MinGapMinutes IS NOT NULL AND gap.LastSentAt IS NOT NULL
                        AND DATEDIFF(minute, gap.LastSentAt, @now) < p.MinGapMinutes THEN 'MIN_GAP'
                   ELSE NULL
               END
        FROM   dbo.LTYC_Policy AS p
        CROSS APPLY (
            SELECT COUNT(*) AS SentCount
            FROM   dbo.LTYC_Dispatch AS d2
            WHERE  d2.MemberId = @MemberId
              AND  d2.Status   = 'SENT'
              AND  d2.SourceType <> 'TXN'
              AND  (p.Channel IS NULL OR d2.Channel = p.Channel)
              AND  d2.SentAt >= CASE p.WindowUnit
                                    WHEN 'DAY'   THEN DATEADD(day,   -1, @now)
                                    WHEN 'WEEK'  THEN DATEADD(day,   -7, @now)
                                    WHEN 'MONTH' THEN DATEADD(month, -1, @now)
                                    ELSE DATEADD(day, -1, @now)
                                END
        ) AS sent
        CROSS APPLY (
            SELECT MAX(d3.SentAt) AS LastSentAt
            FROM   dbo.LTYC_Dispatch AS d3
            WHERE  d3.MemberId = @MemberId
              AND  d3.Status   = 'SENT'
              AND  d3.SourceType <> 'TXN'
              AND  (p.Channel IS NULL OR d3.Channel = p.Channel)
        ) AS gap
        WHERE  p.PropertyId = @PropertyId
          AND  p.PolicyType = 'FREQ_CAP'
          AND  p.IsActive   = 1
          AND  (p.Channel IS NULL OR p.Channel = @Channel)
          AND  (
                 (p.MaxCount IS NOT NULL AND sent.SentCount >= p.MaxCount)
              OR (p.MinGapMinutes IS NOT NULL AND gap.LastSentAt IS NOT NULL
                  AND DATEDIFF(minute, gap.LastSentAt, @now) < p.MinGapMinutes)
               )
        ORDER BY p.Priority, CASE WHEN p.Channel IS NULL THEN 1 ELSE 0 END;

        IF (@CapReason IS NOT NULL)
        BEGIN
            SELECT 'SUPPRESS' AS Decision, @CapReason AS SuppressReason,
                   CAST(NULL AS datetime2(3)) AS DeferUntil, @Recipient AS Recipient;
            RETURN;
        END
    END

    ---- 4. quiet hours ------------------------------------------------------
    /*  In-app messages are never deferred: they sit in an inbox until the member
        opens the app, so there is no such thing as delivering one at a bad hour. */
    IF (@isTransactional = 0 AND @Channel <> 'INAPP')
    BEGIN
        DECLARE @QuietStart time(0), @QuietEnd time(0), @PolicyTz varchar(64);

        SELECT TOP (1) @QuietStart = p.QuietStart, @QuietEnd = p.QuietEnd, @PolicyTz = p.TimeZoneId
        FROM   dbo.LTYC_Policy AS p
        WHERE  p.PropertyId = @PropertyId
          AND  p.PolicyType = 'QUIET_HOURS'
          AND  p.IsActive   = 1
          AND  (p.Channel IS NULL OR p.Channel = @Channel)
        ORDER BY p.Priority, CASE WHEN p.Channel IS NULL THEN 1 ELSE 0 END;

        IF (@QuietStart IS NOT NULL AND @QuietEnd IS NOT NULL)
        BEGIN
            DECLARE @Tz varchar(64) = COALESCE(
                (SELECT m.TimeZoneId FROM dbo.LTY_Member m WHERE m.MemberId = @MemberId),
                @PolicyTz, @FallbackTimeZone);

            DECLARE @LocalNow datetime2(3);

            /*  An unknown timezone name must not throw and lose the message.
                Fall back to UTC and carry on - a message sent an hour early is a
                far smaller problem than one that disappears.                     */
            BEGIN TRY
                SET @LocalNow = CAST(SYSUTCDATETIME() AT TIME ZONE 'UTC' AT TIME ZONE @Tz AS datetime2(3));
            END TRY
            BEGIN CATCH
                SET @LocalNow = SYSUTCDATETIME();
                SET @Tz = 'UTC';
            END CATCH

            DECLARE @LocalTime time(0) = CAST(@LocalNow AS time(0));

            DECLARE @InQuiet bit =
                CASE
                    -- window crossing midnight, e.g. 22:00 -> 08:00
                    WHEN @QuietStart > @QuietEnd
                         AND (@LocalTime >= @QuietStart OR @LocalTime < @QuietEnd) THEN 1
                    -- same-day window, e.g. 01:00 -> 06:00
                    WHEN @QuietStart <= @QuietEnd
                         AND @LocalTime >= @QuietStart AND @LocalTime < @QuietEnd THEN 1
                    ELSE 0
                END;

            IF (@InQuiet = 1)
            BEGIN
                /*  Resume at the end of the window, in the member's local day,
                    converted back to UTC. Never dropped - held and rescheduled.  */
                DECLARE @LocalResume datetime2(3) =
                    CASE
                        WHEN @LocalTime < @QuietEnd
                            THEN DATETIME2FROMPARTS(YEAR(@LocalNow), MONTH(@LocalNow), DAY(@LocalNow),
                                                    DATEPART(hour, @QuietEnd), DATEPART(minute, @QuietEnd), 0, 0, 3)
                        ELSE DATEADD(day, 1,
                                     DATETIME2FROMPARTS(YEAR(@LocalNow), MONTH(@LocalNow), DAY(@LocalNow),
                                                        DATEPART(hour, @QuietEnd), DATEPART(minute, @QuietEnd), 0, 0, 3))
                    END;

                DECLARE @UtcResume datetime2(3) =
                    CAST(@LocalResume AT TIME ZONE @Tz AT TIME ZONE 'UTC' AS datetime2(3));

                SELECT 'DEFER' AS Decision, CAST(NULL AS varchar(40)) AS SuppressReason,
                       @UtcResume AS DeferUntil, @Recipient AS Recipient;
                RETURN;
            END
        END
    END

    ---- 5. clear to send ----------------------------------------------------
    SELECT 'SEND' AS Decision, CAST(NULL AS varchar(40)) AS SuppressReason,
           CAST(NULL AS datetime2(3)) AS DeferUntil, @Recipient AS Recipient;
END

GO

