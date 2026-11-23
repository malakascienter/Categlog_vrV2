CREATE TABLE [dbo].[POSKDSCategory] (
    [Id]              INT          IDENTITY (1, 1) NOT NULL,
    [Code]            CHAR (1)     NOT NULL,
    [Name]            VARCHAR (50) NOT NULL,
    [Active]          BIT          CONSTRAINT [DF_POSKDSCategory_Active] DEFAULT ((1)) NOT NULL,
    [PropertyId]      INT          NULL,
    [IsUpload]        BIT          CONSTRAINT [DF_POSKDSCategory_IsUpload] DEFAULT ((0)) NOT NULL,
    [CreatedUserId]   INT          NULL,
    [CreatedDateTime] DATETIME     NULL,
    [UpdatedUserId]   INT          NULL,
    [UpdatedDateTime] DATETIME     NULL
);


GO

