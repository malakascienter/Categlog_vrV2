CREATE TABLE [dbo].[POS_Classification01] (
    [Id]               BIGINT       IDENTITY (1, 1) NOT NULL,
    [Name]             VARCHAR (20) CONSTRAINT [DF_Classification01_Name] DEFAULT ('') NOT NULL,
    [PropertyId]       INT          NOT NULL,
    [IsUpload]         BIT          CONSTRAINT [DF_Classification01_IsUpload] DEFAULT ((0)) NOT NULL,
    [CreatedUserId]    INT          NULL,
    [CreatedDateTime]  DATETIME     NULL,
    [ModifiedUserId]   INT          NULL,
    [ModifiedDateTime] DATETIME     NULL,
    [Active]           BIT          DEFAULT ((0)) NOT NULL,
    [Prefix]           VARCHAR (2)  DEFAULT ('') NOT NULL,
    [NextNo]           INT          DEFAULT ((1)) NOT NULL,
    [Length]           INT          DEFAULT ((4)) NOT NULL,
    CONSTRAINT [PK_Classification01] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

