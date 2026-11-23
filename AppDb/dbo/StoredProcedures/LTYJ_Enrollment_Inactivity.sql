/*  Enrol members whose last purchase was exactly @InactiveDays ago - the
    win-back trigger.

    Note "exactly", not "at least". An equality on the boundary day means a member
    enters once, on day 30. "<= 30 days ago" would re-enrol them every day
    afterwards, which is the classic way this trigger goes wrong.

    IMPORTANT - what "purchase" means here.

    The only member-linked record of a sale in this database is
    LTY_MemberWisePointTransaction, and a row exists only when the purchase EARNED
    POINTS. A member who buys below the earning threshold, or who is not scanned
    at the till, leaves no trace and will look lapsed. POS_InvoiceHeader carries
    no member column, so there is nothing to fall back on.

    The trigger is therefore honestly "30 days since the last points-earning
    transaction", and the builder UI must say so rather than implying a precision
    the data cannot support.

    Members with no transactions at all are excluded: never-purchased is a
    different audience from lapsed, and mixing them is how a win-back voucher ends
    up with someone who has never bought anything.                                */
CREATE PROCEDURE dbo.LTYJ_Enrollment_Inactivity
    @JourneyId         int,
    @VersionId         int,
    @PropertyId        int,
    @StartNodeKey      varchar(50),
    @InactiveDays      int         = 30,
    @BusinessDate      date        = NULL,
    @ReEntryPolicy     varchar(20) = 'ONCE_PER_PERIOD',
    @ReEntryPeriodDays int         = 180
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @BusinessDate = ISNULL(@BusinessDate, CAST(SYSUTCDATETIME() AS date));

    DECLARE @now    datetime2(3) = SYSUTCDATETIME();
    DECLARE @target date = DATEADD(day, -@InactiveDays, @BusinessDate);
    DECLARE @cutoff date = DATEADD(day, -ISNULL(@ReEntryPeriodDays, 180), @BusinessDate);

    ;WITH LastPurchase AS
    (
        SELECT t.MemberId,
               CAST(MAX(t.TxnDate) AS date) AS LastPurchaseDate
        FROM   dbo.LTY_MemberWisePointTransaction AS t
        WHERE  t.PropertyId      = @PropertyId
          AND  t.TransactionType = 'G'
          AND  ISNULL(t.OrderNo, '') <> ''
        GROUP BY t.MemberId
    )
    INSERT INTO dbo.LTYJ_Run
          (JourneyId, VersionId, MemberId, PropertyId, Status, CurrentNodeKey, NextRunAt, EnteredDate, ContextJson)
    SELECT @JourneyId, @VersionId, m.MemberId, m.PropertyId, 'ACTIVE', @StartNodeKey, @now, @BusinessDate,
           (SELECT lp.LastPurchaseDate AS lastPurchaseDate FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
    FROM   dbo.LTY_Member AS m
    INNER JOIN LastPurchase AS lp ON lp.MemberId = m.MemberId
    WHERE  m.PropertyId = @PropertyId
      AND  m.IsActive   = 1
      AND  lp.LastPurchaseDate = @target
      AND  NOT EXISTS (
             SELECT 1 FROM dbo.LTYJ_Run AS r
             WHERE  r.JourneyId = @JourneyId
               AND  r.MemberId  = m.MemberId
               AND  (
                      @ReEntryPolicy = 'ONCE_EVER'
                   OR (@ReEntryPolicy = 'ONCE_PER_PERIOD' AND r.EnteredDate > @cutoff)
                   OR (@ReEntryPolicy = 'ALWAYS'          AND r.EnteredDate = @BusinessDate)
                    )
           );

    SELECT @@ROWCOUNT AS Enrolled;
END

GO

