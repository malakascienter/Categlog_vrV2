CREATE TABLE [dbo].[ReservationWiseTable] (
    [Id]            BIGINT   IDENTITY (1, 1) NOT NULL,
    [ReservationNo] BIGINT   NOT NULL,
    [PropertyId]    INT      NOT NULL,
    [TableID]       BIGINT   NOT NULL,
    [CreateDate]    DATETIME NULL,
    [CreateUserId]  INT      NULL
);


GO

