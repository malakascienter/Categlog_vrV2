CREATE TABLE [dbo].[POCancellationLog] (
    [ID]            INT      IDENTITY (1, 1) NOT NULL,
    [PoHeaderId]    INT      NULL,
    [UserProfileID] INT      NULL,
    [SysDate]       DATETIME NULL
);


GO

