CREATE TABLE [dbo].[BatchLocation] (
    [Id]                BIGINT       IDENTITY (1, 1) NOT NULL,
    [BatchLocationCode] VARCHAR (10) NOT NULL,
    [Description]       VARCHAR (50) NOT NULL,
    [CreatedUserId]     INT          NULL,
    [CreatedDateTime]   DATETIME     NULL,
    [UpdateUserId]      INT          NULL,
    [UpdatedDateTime]   DATETIME     NULL,
    [PropertyId]        INT          NULL,
    [IsUpload]          BIT          CONSTRAINT [DF_BatchLocation_IsUpload] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_BatchLocation] PRIMARY KEY CLUSTERED ([BatchLocationCode] ASC)
);


GO

