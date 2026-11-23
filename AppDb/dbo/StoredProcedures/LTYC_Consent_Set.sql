/*  Record a consent decision and append to the history.

    Both writes happen in one transaction: a current state without its log entry
    would be an unauditable claim about a member's preference.                    */
CREATE PROCEDURE dbo.LTYC_Consent_Set
    @MemberId    int,
    @PropertyId  int,
    @Channel     varchar(20),
    @IsOptedIn   bit,
    @Source      varchar(30),
    @ActorUserId int            = NULL,
    @ActorIp     varchar(45)    = NULL,
    @DispatchId  bigint         = NULL,
    @UnsubscribeTokenHash varchar(200) = NULL,
    @Notes       nvarchar(500)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @old bit = (SELECT IsOptedIn FROM dbo.LTYC_MemberConsent
                            WHERE MemberId = @MemberId AND Channel = @Channel);

        MERGE dbo.LTYC_MemberConsent AS t
        USING (SELECT @MemberId AS MemberId, @Channel AS Channel) AS s
           ON t.MemberId = s.MemberId AND t.Channel = s.Channel
         WHEN MATCHED THEN
              UPDATE SET IsOptedIn = @IsOptedIn,
                         Source    = @Source,
                         ChangedAt = SYSUTCDATETIME(),
                         ChangedBy = @ActorUserId,
                         UnsubscribeTokenHash = ISNULL(@UnsubscribeTokenHash, t.UnsubscribeTokenHash)
         WHEN NOT MATCHED BY TARGET THEN
              INSERT (MemberId, PropertyId, Channel, IsOptedIn, Source, UnsubscribeTokenHash, ChangedBy)
              VALUES (@MemberId, @PropertyId, @Channel, @IsOptedIn, @Source, @UnsubscribeTokenHash, @ActorUserId);

        INSERT INTO dbo.LTYC_ConsentLog
              (MemberId, PropertyId, Channel, OldValue, NewValue, Source, ActorUserId, ActorIp, DispatchId, Notes)
        VALUES(@MemberId, @PropertyId, @Channel, @old, @IsOptedIn, @Source, @ActorUserId, @ActorIp, @DispatchId, @Notes);

        COMMIT TRANSACTION;

        SELECT @old AS OldValue, @IsOptedIn AS NewValue;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

