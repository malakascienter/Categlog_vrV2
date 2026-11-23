CREATE TABLE [dbo].[LTY_CouponUsage] (
    [Id]         INT          IDENTITY (1, 1) NOT NULL,
    [PropertyId] INT          NOT NULL,
    [Outlet]     VARCHAR (20) NOT NULL,
    [OrderNo]    VARCHAR (50) NOT NULL,
    [OrderDate]  DATETIME     NOT NULL,
    [CouponId]   INT          NOT NULL,
    [IsUse]      BIT          CONSTRAINT [DF_LTY_CouponUsage_IsUse] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_LTY_CouponUsage] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO


CREATE TRIGGER dbo.TR_LTY_CouponUsage_JourneyOutbox
ON dbo.LTY_CouponUsage
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted WHERE IsUse = 1)
        RETURN;

    INSERT INTO dbo.LTYJ_EventOutbox (EventType, MemberId, PropertyId, EntityId, PayloadJson, OccurredAt)
    SELECT 'VOUCHER_USED',
           cm.MemberId,
           i.PropertyId,
           i.CouponId,
           (SELECT i.CouponId   AS couponId,
                   i.OrderNo    AS orderNo,
                   i.Outlet     AS outlet,
                   i.OrderDate  AS orderDate
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),
           SYSUTCDATETIME()
    FROM   inserted AS i
    LEFT JOIN dbo.LTY_CouponMaster AS cm
           ON cm.Id = i.CouponId
    WHERE  i.IsUse = 1;
END

GO

