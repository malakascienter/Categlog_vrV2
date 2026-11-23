/*  Is this member opted in on this channel?

    LTYC_MemberConsent is the authority. LTYM_MemberSettings is consulted only as
    a fallback for members who predate the consent table - it is the member
    portal's own preference store and currently holds zero rows.

    @UnknownDefault decides what happens when NEITHER has a record, and it is a
    parameter rather than a constant on purpose. The production answer is a
    business and legal decision that has not been made (Q4 in the development
    plan), so the code refuses to assume one. Callers pass the configured
    setting, which ships as DENY.                                                */
CREATE PROCEDURE dbo.LTYC_Consent_Resolve
    @MemberId       int,
    @Channel        varchar(20),
    -- DENY | ALLOW. What to do for a member with no recorded preference.
    @UnknownDefault varchar(10) = 'DENY'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT dbo.FN_LTYC_IsOptedIn(@MemberId, @Channel, @UnknownDefault) AS IsOptedIn,
           CASE
               WHEN EXISTS (SELECT 1 FROM dbo.LTYC_MemberConsent
                            WHERE MemberId = @MemberId AND Channel = @Channel) THEN 'CONSENT_TABLE'
               WHEN EXISTS (SELECT 1 FROM dbo.LTYM_MemberSettings
                            WHERE MemberId = @MemberId) THEN 'MEMBER_SETTINGS'
               ELSE 'DEFAULT_' + @UnknownDefault
           END AS Source;
END

GO

