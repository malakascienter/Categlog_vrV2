/*  The member's current preferences, one row per channel.

    Every channel is returned whether or not a row exists, with IsOptedIn NULL
    where nothing has been recorded. The preferences screen must be able to show
    "you have not chosen yet" as its own state - rendering an unset channel as
    "off" would silently claim the member declined something they were never
    asked about.                                                                 */
CREATE PROCEDURE dbo.LTYM_Consent_Select
    @MemberId int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ch.Channel,
           c.IsOptedIn,
           c.Source,
           c.ChangedAt
    FROM   (VALUES ('EMAIL'), ('PUSH'), ('SMS'), ('INAPP')) AS ch(Channel)
    LEFT  JOIN dbo.LTYC_MemberConsent AS c
            ON c.MemberId = @MemberId AND c.Channel = ch.Channel
    ORDER BY CASE ch.Channel WHEN 'EMAIL' THEN 1 WHEN 'PUSH' THEN 2 WHEN 'INAPP' THEN 3 ELSE 4 END;
END

GO

