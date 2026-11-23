CREATE TABLE [dbo].[POSItemTypes_History] (
    [Id]              INT          NOT NULL,
    [Code]            CHAR (1)     NOT NULL,
    [Name]            VARCHAR (50) NOT NULL,
    [SysDate]         DATETIME     CONSTRAINT [DF_POSItemTypes_History_SysDate] DEFAULT (getdate()) NOT NULL,
    [IsActive]        BIT          CONSTRAINT [DF_POSItemTypes_History_IsActive] DEFAULT ((0)) NOT NULL,
    [PropertyId]      INT          NULL,
    [IsUpload]        BIT          CONSTRAINT [DF_POSItemTypes_History_IsUpload] DEFAULT ((0)) NOT NULL,
    [CreatedUserId]   INT          NULL,
    [CreatedDateTime] DATETIME     NULL,
    [UpdatedUserId]   INT          NULL,
    [UpdatedDateTime] DATETIME     NULL
);


GO

