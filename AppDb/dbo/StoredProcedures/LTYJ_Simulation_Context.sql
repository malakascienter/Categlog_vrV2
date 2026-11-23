/*  Everything a dry run needs about one member, read in a single trip.

    Read-only by construction: there is no INSERT, UPDATE or DELETE in this
    procedure and there must never be one. A test run that wrote anything would
    be a test run that could not safely be pointed at a real member, which
    defeats the point of it.

    The reachability columns are what make a simulation worth reading. "This
    member would reach step 4" is mildly interesting; "this member would reach
    step 4 and then be suppressed because they never opted in" is the answer
    somebody actually needed.                                                    */
CREATE PROCEDURE dbo.LTYJ_Simulation_Context
    @MemberId   int,
    @PropertyId int,
    /*  DENY | ALLOW, for a member with nothing recorded either way.

        Defaults to DENY, and deliberately does not read the worker's own
        setting. A simulation that assumed ALLOW would tell an author a member is
        reachable when the real send may suppress them; assuming DENY can only
        err the other way, and an author who is told "this member would be
        suppressed" checks, whereas one told "this would send" does not.         */
    @UnknownDefault varchar(10) = 'DENY'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
        m.MemberId,
        m.MembershipCode,
        MemberName   = LTRIM(RTRIM(ISNULL(m.FirstName, N'') + N' ' + ISNULL(m.LastName, N''))),
        m.Email,
        m.PrimaryMobileNo,
        m.BirthDay,
        m.TierId,
        m.TimeZoneId,
        m.IsActive,
        -- Reachability, per channel. NULL email is a different failure from
        -- "opted out", and the trace says which.
        HasEmail     = CASE WHEN NULLIF(LTRIM(RTRIM(m.Email)), N'')  IS NULL THEN CAST(0 AS bit) ELSE CAST(1 AS bit) END,
        HasMobile    = CASE WHEN NULLIF(LTRIM(RTRIM(m.PrimaryMobileNo)), N'') IS NULL THEN CAST(0 AS bit) ELSE CAST(1 AS bit) END,
        HasDeviceToken = CASE WHEN EXISTS (SELECT 1 FROM dbo.LTYC_DeviceToken AS dt
                                           WHERE dt.MemberId = m.MemberId AND dt.IsActive = 1)
                              THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END,
        /*  The gateway's own opt-in function, so the simulation cannot disagree
            with what a real send would decide.

            Its signature is (@MemberId, @Channel, @UnknownDefault) - there is NO
            PropertyId parameter. An earlier version of this procedure passed
            (@PropertyId, m.MemberId, 'EMAIL'), which silently evaluated consent
            for the wrong member on a channel named after a member id. It did not
            error, because int converts to varchar, and it returned 0 - which
            looked like a correct "not opted in" and was luck.

            A member is unique to one property, so the missing PropertyId costs
            nothing here.                                                        */
        OptedInEmail = dbo.FN_LTYC_IsOptedIn(m.MemberId, 'EMAIL', @UnknownDefault),
        OptedInPush  = dbo.FN_LTYC_IsOptedIn(m.MemberId, 'PUSH',  @UnknownDefault),
        OptedInInApp = dbo.FN_LTYC_IsOptedIn(m.MemberId, 'INAPP', @UnknownDefault)
    FROM   dbo.LTY_Member AS m
    WHERE  m.MemberId = @MemberId
      AND  m.PropertyId = @PropertyId;
END

GO

