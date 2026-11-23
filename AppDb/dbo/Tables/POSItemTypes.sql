CREATE TABLE [dbo].[POSItemTypes] (
    [Id]              INT          IDENTITY (1, 1) NOT NULL,
    [Code]            CHAR (1)     NOT NULL,
    [Name]            VARCHAR (50) NOT NULL,
    [IsActive]        BIT          CONSTRAINT [DF_POSItemTypes_IsActive_1] DEFAULT ((0)) NULL,
    [PropertyId]      INT          NULL,
    [IsUpload]        BIT          CONSTRAINT [DF_POSItemTypes_IsUpload] DEFAULT ((0)) NOT NULL,
    [CreatedUserId]   INT          NULL,
    [CreatedDateTime] DATETIME     NULL,
    [UpdatedUserId]   INT          NULL,
    [UpdatedDateTime] DATETIME     NULL,
    [FromTime]        TIME (7)     DEFAULT ('00:00:00') NOT NULL,
    [ToTime]          TIME (7)     DEFAULT ('23:59:59') NOT NULL,
    CONSTRAINT [PK_POSItemTypes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

