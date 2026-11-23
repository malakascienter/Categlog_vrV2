CREATE TABLE [dbo].[POStatusUpdate_Log] (
    [ID]         INT          IDENTITY (1, 1) NOT NULL,
    [PropertyID] INT          NULL,
    [PoHeaderID] INT          NULL,
    [Status]     VARCHAR (10) NULL,
    [Module]     VARCHAR (50) NULL,
    [SysDate]    DATETIME     NULL,
    [UserID]     INT          NULL
);


GO

