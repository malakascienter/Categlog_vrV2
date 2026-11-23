CREATE TABLE [dbo].[TempAvgUpdateItemLog] (
    [Id]          BIGINT   IDENTITY (1, 1) NOT NULL,
    [StockItemId] BIGINT   NOT NULL,
    [LocationId]  INT      NOT NULL,
    [Trandate]    DATETIME NOT NULL,
    [sysDate]     DATETIME CONSTRAINT [DF_TempAvgUpdateItemLog_sysDate] DEFAULT (getdate()) NOT NULL
);


GO

