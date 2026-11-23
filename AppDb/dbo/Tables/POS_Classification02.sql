CREATE TABLE [dbo].[POS_Classification02] (
    [Id]                 BIGINT       IDENTITY (1, 1) NOT NULL,
    [Classification01Id] BIGINT       NOT NULL,
    [Name]               VARCHAR (20) CONSTRAINT [DF_Classification02_Name] DEFAULT ('') NOT NULL,
    [PropertyId]         INT          NOT NULL,
    [IsUpload]           BIT          CONSTRAINT [DF_Classification02_IsUpload] DEFAULT ((0)) NOT NULL,
    [CreatedUserId]      INT          NULL,
    [CreatedDateTime]    DATETIME     NULL,
    [ModifiedUserId]     INT          NULL,
    [ModifiedDateTime]   DATETIME     NULL,
    [Active]             BIT          DEFAULT ((0)) NOT NULL,
    [Prefix]             VARCHAR (2)  DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_Classification02] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

