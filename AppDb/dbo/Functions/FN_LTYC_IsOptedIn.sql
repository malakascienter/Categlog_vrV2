/*  Consent as a function, so both LTYC_Consent_Resolve and
    LTYC_Dispatch_Evaluate can use it.

    A function rather than one procedure calling the other, because T-SQL forbids
    nesting INSERT ... EXEC: LTYC_Dispatch_Evaluate would become uncallable from
    any caller that itself captures a result set that way, which includes every
    test script and any future procedure that wraps it.

    Scalar, and that is fine here - it is evaluated once per message, never once
    per row. (Contrast LTYM_fn_MemberPointsBalance, which must NOT be used in
    set-based segment SQL for exactly that reason.)                              */
CREATE FUNCTION dbo.FN_LTYC_IsOptedIn
(
    @MemberId       int,
    @Channel        varchar(20),
    -- DENY | ALLOW. Applied only when nothing has been recorded either way.
    @UnknownDefault varchar(10)
)
RETURNS bit
AS
BEGIN
    DECLARE @isOptedIn bit = NULL;

    -- LTYC_MemberConsent is the authority.
    SELECT TOP (1) @isOptedIn = c.IsOptedIn
    FROM   dbo.LTYC_MemberConsent AS c
    WHERE  c.MemberId = @MemberId AND c.Channel = @Channel;

    -- Fallback for members who predate the consent table.
    IF (@isOptedIn IS NULL)
    BEGIN
        SELECT TOP (1)
               @isOptedIn = CASE @Channel
                                WHEN 'EMAIL' THEN s.EmailNotifications
                                WHEN 'SMS'   THEN s.SmsNotifications
                                WHEN 'INAPP' THEN s.PromoMessages
                                ELSE NULL       -- no push column exists
                            END
        FROM   dbo.LTYM_MemberSettings AS s
        WHERE  s.MemberId = @MemberId;
    END

    IF (@isOptedIn IS NULL)
        SET @isOptedIn = CASE WHEN @UnknownDefault = 'ALLOW' THEN 1 ELSE 0 END;

    RETURN @isOptedIn;
END

GO

