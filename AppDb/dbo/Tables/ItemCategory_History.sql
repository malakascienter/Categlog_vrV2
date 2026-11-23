CREATE TABLE [dbo].[ItemCategory_History] (
    [Id]              INT          NOT NULL,
    [SysDate]         DATETIME     CONSTRAINT [DF_ItemCategory_History_SysDate] DEFAULT (getdate()) NOT NULL,
    [Code]            VARCHAR (3)  NOT NULL,
    [Name]            VARCHAR (50) NOT NULL,
    [IsActive]        BIT          NULL,
    [PropertyId]      INT          NULL,
    [IsUpload]        BIT          CONSTRAINT [DF_ItemCategory_History_IsUpload] DEFAULT ((0)) NOT NULL,
    [CreatedUserId]   INT          NULL,
    [CreatedDateTime] DATETIME     NULL,
    [UpdatedUserId]   INT          NULL,
    [UpdatedDateTime] DATETIME     NULL
);


GO

