/*  Record the hash of an unsubscribe token for a member and channel.

    The caller generates the token and passes only its hash. This procedure never
    sees the plain value, which is the point: the consent table can be read in
    full without yielding a single working unsubscribe link.

    A consent row is created opted-IN if none exists. That is not an assumption
    about the member's wishes - a token is only ever issued while composing a
    message the gateway has already agreed to send, so a row reaching this
    procedure has passed the consent check by some other route. Without the row
    there would be nowhere to hang the hash.                                     */
CREATE PROCEDURE dbo.LTYC_Unsubscribe_IssueToken
    @MemberId   int,
    @PropertyId int,
    @Channel    varchar(20),
    @TokenHash  varchar(200)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF (NULLIF(LTRIM(RTRIM(@TokenHash)), '') IS NULL)
        THROW 50413, 'A token hash is required.', 1;

    IF (@Channel NOT IN ('EMAIL','PUSH','SMS','INAPP'))
        THROW 50414, 'Channel must be EMAIL, PUSH, SMS or INAPP.', 1;

    MERGE dbo.LTYC_MemberConsent AS t
    USING (SELECT @MemberId AS MemberId, @Channel AS Channel) AS s
       ON  t.MemberId = s.MemberId AND t.Channel = s.Channel
     WHEN MATCHED THEN
          UPDATE SET UnsubscribeTokenHash = @TokenHash
     WHEN NOT MATCHED BY TARGET THEN
          INSERT (MemberId, PropertyId, Channel, IsOptedIn, Source, UnsubscribeTokenHash, ChangedAt)
          VALUES (@MemberId, @PropertyId, @Channel, 1, 'ADMIN', @TokenHash, SYSUTCDATETIME());

    SELECT Issued = 1;
END

GO

