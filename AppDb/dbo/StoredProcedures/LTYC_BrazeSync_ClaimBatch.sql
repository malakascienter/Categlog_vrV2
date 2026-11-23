/*  Take the next batch of pending members, with everything needed to build the
    payload.

    A fixed wide row rather than a dynamically shaped one: the columns are the
    registry fields flagged IsBrazeSyncable, and LTYC_BrazeAttributeMap only
    renames them on the way out. Renaming is a serialisation concern, so it
    belongs in the application, and keeping this query static means it can be
    read, planned and indexed like any other.

    @BatchSize defaults to 75 because that is Braze's documented maximum number
    of attribute objects per /users/track request.                               */
CREATE PROCEDURE dbo.LTYC_BrazeSync_ClaimBatch
    @SyncId    int,
    @BatchSize int = 75
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Claimed TABLE (ItemId bigint, MemberId int, ExternalId nvarchar(100));

    UPDATE TOP (@BatchSize) i WITH (READPAST, ROWLOCK)
    SET    i.Status = 'SENDING', i.AttemptCount = i.AttemptCount + 1
    OUTPUT inserted.ItemId, inserted.MemberId, inserted.ExternalId INTO @Claimed
    FROM   dbo.LTYC_BrazeSyncItem AS i
    WHERE  i.SyncId = @SyncId AND i.Status = 'PENDING';

    SELECT c.ItemId,
           c.MemberId,
           c.ExternalId,
           m.MembershipCode,
           m.FirstName,
           m.LastName,
           NULLIF(LTRIM(RTRIM(m.Email)), '')                       AS Email,
           CONVERT(date, m.BirthDay)                               AS Birthday,
           m.IsActive                                              AS MemberStatus,
           m.RegisterOutlet,
           t.TierName,
           CAST(ISNULL(x.PointBalance, 0)      AS decimal(18,2))   AS PointBalance,
           CAST(ISNULL(x.PointsEarned, 0)      AS decimal(18,2))   AS PointsEarned,
           CAST(ISNULL(x.PointsExpiring30d, 0) AS decimal(18,2))   AS PointsExpiring30d,
           x.LastPurchaseAt                                        AS LastPurchaseDate,
           DATEDIFF(day, x.LastPurchaseAt, SYSUTCDATETIME())       AS DaysSinceLastPurchase,
           ISNULL(x.TransactionCount, 0)                           AS TransactionCount,
           CAST(ISNULL(x.TotalSpend, 0)        AS decimal(18,4))   AS TotalSpend,
           ISNULL(x.VouchersRedeemed, 0)                           AS VouchersRedeemed,
           CASE WHEN ISNULL(x.VouchersUnused, 0) > 0 THEN 1 ELSE 0 END AS HasUnusedVoucher
    FROM   @Claimed AS c
    INNER JOIN dbo.LTY_Member          AS m ON m.MemberId = c.MemberId
    LEFT  JOIN dbo.LTY_Tier            AS t ON t.TierId   = m.TierId
    LEFT  JOIN dbo.LTYC_MemberMetrics  AS x ON x.MemberId = c.MemberId
    ORDER BY c.ItemId;
END

GO

