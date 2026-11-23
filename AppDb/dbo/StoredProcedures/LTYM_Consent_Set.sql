/*  The member changing their own communication preferences.

    Source is PORTAL, which matters: the consent log distinguishes a member's own
    choice from an admin edit, an import and an unsubscribe link, and only the
    first of those is evidence of consent rather than of processing.             */
CREATE PROCEDURE dbo.LTYM_Consent_Set
    @MemberId  int,
    @Channel   varchar(20),
    @IsOptedIn bit
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @PropertyId int = (SELECT PropertyId FROM dbo.LTY_Member WHERE MemberId = @MemberId);

    IF (@PropertyId IS NULL)
        THROW 52410, 'That member does not exist.', 1;

    IF (@Channel NOT IN ('EMAIL','PUSH','SMS','INAPP'))
        THROW 52411, 'Unknown communication channel.', 1;

    DECLARE @WasOptedIn bit =
        (SELECT IsOptedIn FROM dbo.LTYC_MemberConsent WHERE MemberId = @MemberId AND Channel = @Channel);

    MERGE dbo.LTYC_MemberConsent AS t
    USING (SELECT @MemberId AS MemberId, @Channel AS Channel) AS s
       ON  t.MemberId = s.MemberId AND t.Channel = s.Channel
     WHEN MATCHED THEN
          UPDATE SET IsOptedIn = @IsOptedIn, Source = 'PORTAL',
                     ChangedAt = SYSUTCDATETIME(), ChangedBy = @MemberId
     WHEN NOT MATCHED BY TARGET THEN
          INSERT (MemberId, PropertyId, Channel, IsOptedIn, Source, ChangedAt, ChangedBy)
          VALUES (@MemberId, @PropertyId, @Channel, @IsOptedIn, 'PORTAL', SYSUTCDATETIME(), @MemberId);

    -- Logged only on a real change, so the audit trail records decisions rather
    -- than every visit to the preferences screen.
    IF (@WasOptedIn IS NULL OR @WasOptedIn <> @IsOptedIn)
        INSERT INTO dbo.LTYC_ConsentLog
            (MemberId, PropertyId, Channel, OldValue, NewValue, Source, ActorUserId, Notes, CreatedDate)
        VALUES
            (@MemberId, @PropertyId, @Channel, @WasOptedIn, @IsOptedIn, 'PORTAL', @MemberId,
             N'Changed by the member in the portal.', SYSUTCDATETIME());

    SELECT Channel = @Channel, IsOptedIn = @IsOptedIn;
END

GO

