CREATE TABLE [dbo].[Category_History] (
    [SysDate]                DATETIME     CONSTRAINT [DF_Category_History_SysDate] DEFAULT (getdate()) NOT NULL,
    [Code]                   CHAR (3)     NOT NULL,
    [Description]            VARCHAR (25) NOT NULL,
    [Prefix]                 VARCHAR (3)  NULL,
    [Acc]                    NCHAR (12)   NULL,
    [ID]                     CHAR (1)     NOT NULL,
    [Colour]                 VARCHAR (9)  NOT NULL,
    [Seq]                    INT          NOT NULL,
    [CatType]                CHAR (2)     NOT NULL,
    [Active]                 BIT          NOT NULL,
    [IsUpload]               BIT          NOT NULL,
    [CatgId]                 INT          NULL,
    [PropertyId]             INT          NULL,
    [CreatedUserId]          INT          NULL,
    [CreatedDateTime]        DATETIME     NULL,
    [ModifiedUserId]         INT          NULL,
    [ModifiedDateTime]       DATETIME     NULL,
    [IsEButlerCategory]      BIT          DEFAULT ((0)) NOT NULL,
    [PopularityThreshold]    MONEY        DEFAULT ((0)) NOT NULL,
    [ProfitabilityThreshold] MONEY        DEFAULT ((0)) NOT NULL,
    [Classification01Id]     BIGINT       DEFAULT ((0)) NOT NULL,
    [Classification02Id]     BIGINT       DEFAULT ((0)) NOT NULL,
    [WebUpload]              BIT          DEFAULT ((0)) NOT NULL
);


GO

