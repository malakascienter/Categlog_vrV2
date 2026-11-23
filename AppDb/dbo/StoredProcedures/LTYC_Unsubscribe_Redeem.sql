/*  Opt a member out from an unsubscribe link.

    Takes the hash, never the token. An unknown hash returns Found = 0 and
    changes nothing - it must NOT throw, because this is reached from a public
    endpoint and an error page would tell a prober that they had guessed wrong
    in a different way from a valid-but-used link.

    Redeeming does not clear the hash. The same link pressed twice must report
    the same "you are unsubscribed" rather than failing the second time - people
    forward these emails, and mail clients pre-fetch links.                      */
CREATE PROCEDURE dbo.LTYC_Unsubscribe_Redeem
    @TokenHash varchar(200)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @MemberId   int;
    DECLARE @PropertyId int;
    DECLARE @Channel    varchar(20);
    DECLARE @WasOptedIn bit;

    SELECT TOP (1) @MemberId = MemberId, @PropertyId = PropertyId,
                   @Channel  = Channel,  @WasOptedIn = IsOptedIn
    FROM   dbo.LTYC_MemberConsent
    WHERE  UnsubscribeTokenHash = @TokenHash;

    IF (@MemberId IS NULL)
    BEGIN
        SELECT Found        = CAST(0 AS bit),
               AlreadyOptedOut = CAST(0 AS bit),
               MemberId     = CAST(NULL AS int),
               Channel      = CAST(NULL AS varchar(20));
        RETURN;
    END

    UPDATE dbo.LTYC_MemberConsent
    SET    IsOptedIn = 0,
           Source    = 'UNSUB_LINK',
           ChangedAt = SYSUTCDATETIME(),
           ChangedBy = NULL
    WHERE  MemberId = @MemberId AND Channel = @Channel;

    /*  The audit trail is the evidence that an opt-out was honoured, which is the
        one thing a regulator would ask for.

        Only logged when the value actually changed. A link pressed twice - or
        pre-fetched by a mail client, which happens constantly - must not fill the
        log with identical rows that make a single opt-out look like a campaign
        of them.                                                                 */
    IF (@WasOptedIn = 1)
        INSERT INTO dbo.LTYC_ConsentLog (MemberId, PropertyId, Channel, OldValue, NewValue, Source, Notes, CreatedDate)
        VALUES (@MemberId, @PropertyId, @Channel, 1, 0, 'UNSUB_LINK',
                N'Opted out through the unsubscribe link.', SYSUTCDATETIME());

    SELECT Found           = CAST(1 AS bit),
           -- Lets the page say "you were already unsubscribed" rather than
           -- implying the press did something.
           AlreadyOptedOut = CASE WHEN @WasOptedIn = 1 THEN CAST(0 AS bit) ELSE CAST(1 AS bit) END,
           MemberId        = @MemberId,
           Channel         = @Channel;
END

GO

