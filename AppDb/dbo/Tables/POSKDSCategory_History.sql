CREATE TABLE [dbo].[POSKDSCategory_History] (
    [Id]              INT          NOT NULL,
    [Code]            CHAR (1)     NOT NULL,
    [Name]            VARCHAR (50) NOT NULL,
    [Active]          BIT          NOT NULL,
    [SysDate]         DATETIME     CONSTRAINT [DF_POSKDSCategory_History_SysDate] DEFAULT (getdate()) NOT NULL,
    [CreatedUserId]   INT          NULL,
    [CreatedDateTime] DATETIME     NULL,
    [UpdatedUserId]   INT          NULL,
    [UpdatedDateTime] DATETIME     NULL,
    [PropertyId]      INT          NULL,
    [IsUpload]        BIT          NULL
);


GO

