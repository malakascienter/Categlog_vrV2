/*  Everything known about one member, as a single JSON document.

    One procedure and one round trip rather than seven, because the screen is a
    single popup: seven endpoints would each pay the connection and the tenant
    check, and would let the panels disagree with each other by arriving at
    different moments. Shaped after LTY_GetPromotion, which already answers this
    way and whose JsonElement handling the API reuses unchanged.

    The sections, and where each genuinely comes from:

      profile       LTY_Member + LTY_Tier
      custom        LTYC_MemberAttribute joined to that member's answers, so a
                    field defined but never answered still shows, empty
      points        LTYC_MemberMetrics for the rollup, with the balance taken
                    from LTYM_fn_MemberPointsBalance -- the same function the
                    member portal reports, so the two cannot disagree
      expiry        unexpired earned points grouped by the month they lapse in.
                    Earn rows only: a redemption has no expiry to show, and
                    including it would net the timeline down to nonsense
      transactions  LTY_MemberWisePointTransaction, newest first
      redemptions   coupons issued to the member, with the usage row when spent
      offers        promotions live for this member right now, by the same gates
                    LTY_GetMatchingPromotion applies at the till: active, in
                    date, tier, birthday, new-member and segment
      journeys      LTYJ_Run joined to the journey it belongs to
      audit         LTYJ_AuditLog for this member, plus the create and modify
                    stamps on the member row itself, which predate that log

    Read-only throughout. Capped where a list could grow without bound, and each
    cap is reported next to its section so a truncated list cannot be mistaken
    for a short one.                                                             */
CREATE PROCEDURE dbo.LTY_GetMember360
    @MemberId   int,
    @PropertyId int,
    /*  How many rows each unbounded history returns. The popup shows recent
        activity; the full ledger is a report.                                   */
    @HistoryTake int = 50
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.LTY_Member
                       WHERE MemberId = @MemberId AND PropertyId = @PropertyId)
        BEGIN
            RAISERROR('This member no longer exists.', 16, 1);
            RETURN;
        END

        SET @HistoryTake = CASE WHEN ISNULL(@HistoryTake, 0) BETWEEN 1 AND 500
                                THEN @HistoryTake ELSE 50 END;

        DECLARE @Today date = CONVERT(date, GETDATE());
        DECLARE @Now datetime = GETDATE();
        DECLARE @Balance decimal(18,2) = dbo.LTYM_fn_MemberPointsBalance(@MemberId, @PropertyId);

        DECLARE @Birthday datetime, @MemberSince datetime, @TierId int;
        SELECT @Birthday = BirthDay, @MemberSince = CreatedDate, @TierId = TierId
        FROM   dbo.LTY_Member WHERE MemberId = @MemberId;

        DECLARE @IsBirthdayToday bit =
            CASE WHEN @Birthday IS NOT NULL
                  AND MONTH(@Birthday) = MONTH(@Today) AND DAY(@Birthday) = DAY(@Today)
                 THEN 1 ELSE 0 END;
        DECLARE @IsBirthdayMonth bit =
            CASE WHEN @Birthday IS NOT NULL AND MONTH(@Birthday) = MONTH(@Today) THEN 1 ELSE 0 END;

        DECLARE @Json nvarchar(max);

        SELECT @Json =
        (
            SELECT
                -- ---- profile -------------------------------------------------
                m.MemberId,
                m.MembershipCode,
                m.PropertyId,
                m.Salutation,
                m.FirstName,
                m.LastName,
                LTRIM(RTRIM(ISNULL(m.FirstName, '') + ' ' + ISNULL(m.LastName, ''))) AS FullName,
                m.Email,
                m.PrimaryMobileNo,
                m.SecondaryMobileNo,
                m.Address,
                m.BirthDay,
                m.RegisterOutlet,
                m.TimeZoneId,
                m.IsActive,
                m.TierId,
                t.TierName,
                m.CreatedDate    AS MemberSince,
                DATEDIFF(DAY, m.CreatedDate, @Now) AS MemberSinceDays,
                m.CreatedBy,
                m.ModifyBy,
                m.ModifyDate,
                @IsBirthdayToday AS IsBirthdayToday,
                @IsBirthdayMonth AS IsBirthdayMonth,

                -- ---- custom profile attributes -------------------------------
                /*  Every active definition, whether or not this member has
                    answered it. A field that renders only once populated is a
                    field nobody discovers, and the popup doubles as the prompt
                    to capture it.                                               */
                JSON_QUERY(ISNULL((
                    SELECT a.AttributeCode,
                           a.DisplayName,
                           a.DataType,
                           a.InputType,
                           JSON_QUERY(a.OptionsJson)     AS Options,
                           v.ValueText                   AS [Value],
                           a.IsSegmentable,
                           a.IsPersonalisable,
                           CASE WHEN a.IsPersonalisable = 1
                                THEN '{{' + a.AttributeCode + '}}' END AS Token,
                           v.ModifiedDate                AS AnsweredAt
                    FROM   dbo.LTYC_MemberAttribute AS a
                    LEFT   JOIN dbo.LTYC_MemberAttributeValue AS v
                           ON v.AttributeId = a.AttributeId AND v.MemberId = m.MemberId
                    WHERE  a.PropertyId = @PropertyId AND a.IsDeleted = 0 AND a.IsActive = 1
                    ORDER BY a.SortOrder, a.DisplayName
                    FOR JSON PATH, INCLUDE_NULL_VALUES
                ), '[]')) AS CustomAttributes,

                -- ---- points --------------------------------------------------
                JSON_QUERY((
                    SELECT @Balance                          AS Balance,
                           ISNULL(x.PointsEarned, 0)         AS Earned,
                           ISNULL(x.PointsRedeemed, 0)       AS Redeemed,
                           ISNULL(x.PointsExpired, 0)        AS Expired,
                           ISNULL(x.PointsExpiring30d, 0)    AS ExpiringIn30Days,
                           ISNULL(x.TransactionCount, 0)     AS TransactionCount,
                           ISNULL(x.TotalSpend, 0)           AS TotalSpend,
                           ISNULL(x.AvgTransactionValue, 0)  AS AvgTransactionValue,
                           x.FirstPurchaseAt,
                           x.LastPurchaseAt,
                           x.LastOutletCode,
                           x.LastRedemptionAt,
                           /*  When the rollup was last computed. Shown because
                               the metrics refresh is a scheduled job -- a figure
                               with no age reads as live when it is not.         */
                           x.ComputedAt
                    FROM (SELECT 1 AS One) AS anchor
                    LEFT JOIN dbo.LTYC_MemberMetrics AS x ON x.MemberId = @MemberId
                    FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
                )) AS Points,

                -- ---- expiry timeline -----------------------------------------
                /*  Earned points that have not lapsed yet, by the month they
                    lapse in. Rows with no ExpireDate never expire and are
                    excluded rather than bucketed under a guessed date.          */
                JSON_QUERY(ISNULL((
                    SELECT TOP (24)
                           CONVERT(char(7), pt.ExpireDate, 126)          AS [Month],
                           MIN(CONVERT(date, pt.ExpireDate))             AS FirstExpiry,
                           SUM(pt.NoPoints)                              AS Points,
                           COUNT(*)                                      AS Batches
                    FROM   dbo.LTY_MemberWisePointTransaction AS pt
                    WHERE  pt.MemberId    = @MemberId
                      AND  pt.PropertyId  = @PropertyId
                      AND  pt.TransactionType = 'G'
                      AND  pt.ExpireDate IS NOT NULL
                      AND  pt.ExpireDate >= @Now
                    GROUP BY CONVERT(char(7), pt.ExpireDate, 126)
                    ORDER BY [Month]
                    FOR JSON PATH
                ), '[]')) AS PointExpiry,

                -- ---- transaction history -------------------------------------
                JSON_QUERY(ISNULL((
                    SELECT TOP (@HistoryTake)
                           pt.Id,
                           pt.TxnDate,
                           pt.TransactionType                       AS TypeCode,
                           tt.TransactionType                       AS TypeName,
                           pt.NoPoints,
                           pt.PointsBefore,
                           pt.PointsBalance,
                           pt.BillValue,
                           pt.OutletCode,
                           pt.OrderNo,
                           pt.Remark,
                           pt.ExpireDate
                    FROM   dbo.LTY_MemberWisePointTransaction AS pt
                    LEFT   JOIN dbo.LTY_PointTransactionType AS tt ON tt.Code = pt.TransactionType
                    WHERE  pt.MemberId = @MemberId AND pt.PropertyId = @PropertyId
                    ORDER BY pt.TxnDate DESC, pt.Id DESC
                    FOR JSON PATH, INCLUDE_NULL_VALUES
                ), '[]')) AS Transactions,

                -- ---- redemption history --------------------------------------
                /*  Coupons issued to this member. Status carries the lifecycle;
                    the usage row is what says where and when it was actually
                    spent, so it is joined rather than inferred from Status.     */
                JSON_QUERY(ISNULL((
                    SELECT TOP (@HistoryTake)
                           cm.Id                AS CouponId,
                           cm.DocumentNo,
                           cm.Outlet            AS IssuedOutlet,
                           cm.IsPerecentage     AS IsPercentage,
                           cm.Value,
                           cm.ExpireDate,
                           cm.Status,
                           cm.StatusReason,
                           cm.CreatedDate       AS IssuedDate,
                           cu.OrderNo           AS UsedOrderNo,
                           cu.OrderDate         AS UsedDate,
                           cu.Outlet            AS UsedOutlet,
                           CASE WHEN cu.Id IS NOT NULL THEN CONVERT(bit, 1) ELSE CONVERT(bit, 0) END AS IsUsed,
                           CASE WHEN cu.Id IS NULL AND cm.ExpireDate < @Now
                                THEN CONVERT(bit, 1) ELSE CONVERT(bit, 0) END AS IsExpired
                    FROM   dbo.LTY_CouponMaster AS cm
                    LEFT   JOIN dbo.LTY_CouponUsage AS cu
                           ON cu.CouponId = cm.Id AND cu.IsUse = 1
                    WHERE  cm.MemberId = @MemberId AND cm.PropertyId = @PropertyId
                    ORDER BY cm.CreatedDate DESC, cm.Id DESC
                    FOR JSON PATH, INCLUDE_NULL_VALUES
                ), '[]')) AS Redemptions,

                -- ---- active offers -------------------------------------------
                /*  What this member could walk in and use today. The gates are
                    the ones LTY_GetMatchingPromotion applies, minus the ones that
                    need an actual basket -- outlet, bill value, day and time of
                    the transaction -- because there is no transaction here. So
                    this answers "is this promotion available to this person",
                    not "would it apply to that order".                          */
                JSON_QUERY(ISNULL((
                    SELECT p.PromotionId,
                           p.PromotionName,
                           p.Description,
                           p.StartDate,
                           p.EndDate,
                           CONVERT(varchar(8), p.StartTime, 108) AS StartTime,
                           CONVERT(varchar(8), p.EndTime, 108)   AS EndTime,
                           p.MinBillAmount,
                           p.MaxBillAmount,
                           p.IsDiscountPercentage,
                           p.Discount,
                           p.ImageURL,
                           p.IsBirthdayDate,
                           p.IsBirthdayMonth,
                           p.IsNewMember,
                           p.NewMemberDayCount,
                           /*  Why this member sees it, so the popup can say
                               "because they are Gold" rather than listing
                               promotions with no explanation.                   */
                           JSON_QUERY(ISNULL((
                               SELECT s.Name
                               FROM dbo.LTY_SegmentWisePromotion AS sw
                               INNER JOIN dbo.LTYC_Segment AS s ON s.SegmentId = sw.SegmentId
                               WHERE sw.PromotionId = p.PromotionId AND sw.PropertyId = @PropertyId
                               FOR JSON PATH
                           ), '[]')) AS Segments
                    FROM   dbo.LTY_Promotion AS p
                    WHERE  p.PropertyId = @PropertyId
                      AND  p.IsActive   = 1
                      AND  @Today BETWEEN p.StartDate AND p.EndDate
                      AND  EXISTS (SELECT 1 FROM dbo.LTY_TierWisePromotion AS tw
                                   WHERE tw.PromotionId = p.PromotionId AND tw.TierId = @TierId)
                      AND  ((p.IsBirthdayDate = 0 AND p.IsBirthdayMonth = 0)
                            OR (p.IsBirthdayDate = 1 AND @IsBirthdayToday = 1)
                            OR (p.IsBirthdayMonth = 1 AND @IsBirthdayMonth = 1))
                      AND  (ISNULL(p.IsNewMember, 0) = 0
                            OR (@MemberSince IS NOT NULL AND p.NewMemberDayCount IS NOT NULL
                                AND DATEDIFF(DAY, @MemberSince, @Now) BETWEEN 0 AND p.NewMemberDayCount))
                      -- The Segment validation mode, read the same way the till reads it.
                      AND  (NOT EXISTS (SELECT 1 FROM dbo.LTY_SegmentWisePromotion AS sw
                                        WHERE sw.PromotionId = p.PromotionId AND sw.PropertyId = @PropertyId)
                            OR EXISTS (SELECT 1 FROM dbo.LTY_SegmentWisePromotion AS sw
                                       INNER JOIN dbo.LTYC_SegmentMember AS sm
                                          ON sm.SegmentId = sw.SegmentId
                                         AND sm.MemberId = @MemberId
                                         AND sm.PropertyId = @PropertyId
                                       WHERE sw.PromotionId = p.PromotionId AND sw.PropertyId = @PropertyId))
                    ORDER BY p.EndDate, p.PromotionName
                    FOR JSON PATH, INCLUDE_NULL_VALUES
                ), '[]')) AS ActiveOffers,

                -- ---- segment membership --------------------------------------
                /*  Which audiences this member currently sits in. Not asked for
                    by name, but it is the answer to "why did they get that
                    message", and it is one join.                                */
                JSON_QUERY(ISNULL((
                    SELECT s.SegmentId,
                           s.Name,
                           s.RefreshMode,
                           sm.AddedAt,
                           s.LastRefreshedAt
                    FROM   dbo.LTYC_SegmentMember AS sm
                    INNER  JOIN dbo.LTYC_Segment AS s ON s.SegmentId = sm.SegmentId
                    WHERE  sm.MemberId = @MemberId AND sm.PropertyId = @PropertyId
                      AND  s.IsDeleted = 0
                    ORDER BY s.Name
                    FOR JSON PATH, INCLUDE_NULL_VALUES
                ), '[]')) AS Segments,

                -- ---- journey membership --------------------------------------
                JSON_QUERY(ISNULL((
                    SELECT TOP (@HistoryTake)
                           r.RunId,
                           r.JourneyId,
                           j.Name           AS JourneyName,
                           r.Status,
                           r.CurrentNodeKey,
                           r.EnteredAt,
                           r.EndedAt,
                           r.ExitReason,
                           r.NextRunAt,
                           jv.VersionNo
                    FROM   dbo.LTYJ_Run AS r
                    LEFT   JOIN dbo.LTYJ_Journey AS j ON j.JourneyId = r.JourneyId
                    LEFT   JOIN dbo.LTYJ_JourneyVersion AS jv ON jv.VersionId = r.VersionId
                    WHERE  r.MemberId = @MemberId AND r.PropertyId = @PropertyId
                    ORDER BY r.EnteredAt DESC
                    FOR JSON PATH, INCLUDE_NULL_VALUES
                ), '[]')) AS Journeys,

                -- ---- audit trail ---------------------------------------------
                /*  The audit log for this member, with the member row's own
                    create and modify stamps folded in. Those two are not in the
                    log -- the member module predates it -- and leaving them out
                    would show a record that appeared from nowhere.              */
                JSON_QUERY(ISNULL((
                    SELECT TOP (@HistoryTake) *
                    FROM (
                        SELECT al.CreatedDate  AS [At],
                               al.Action,
                               al.EntityType,
                               al.ActorUserId,
                               al.ActorIp,
                               al.Notes
                        FROM   dbo.LTYJ_AuditLog AS al
                        WHERE  al.PropertyId = @PropertyId
                          AND  al.EntityType = 'MEMBER'
                          AND  al.EntityId   = @MemberId

                        UNION ALL

                        SELECT m2.CreatedDate, 'CREATE', 'MEMBER', m2.CreatedBy, NULL,
                               'Member record created'
                        FROM   dbo.LTY_Member AS m2
                        WHERE  m2.MemberId = @MemberId

                        UNION ALL

                        SELECT m3.ModifyDate, 'UPDATE', 'MEMBER', m3.ModifyBy, NULL,
                               'Member record updated'
                        FROM   dbo.LTY_Member AS m3
                        WHERE  m3.MemberId = @MemberId AND m3.ModifyDate IS NOT NULL
                    ) AS a
                    ORDER BY a.[At] DESC
                    FOR JSON PATH, INCLUDE_NULL_VALUES
                ), '[]')) AS Audit,

                -- The cap that was applied, so a full-looking list can be
                -- recognised as a truncated one.
                @HistoryTake AS HistoryTake

            FROM   dbo.LTY_Member AS m
            LEFT   JOIN dbo.LTY_Tier AS t ON t.TierId = m.TierId AND t.PropertyId = m.PropertyId
            WHERE  m.MemberId = @MemberId AND m.PropertyId = @PropertyId
            FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
        );

        SELECT @Json AS Member360Json;
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg nvarchar(4000) = ERROR_MESSAGE();
        DECLARE @ErrSev int = ERROR_SEVERITY();
        DECLARE @ErrState int = ERROR_STATE();
        RAISERROR(@ErrMsg, @ErrSev, @ErrState);
    END CATCH
END

GO

