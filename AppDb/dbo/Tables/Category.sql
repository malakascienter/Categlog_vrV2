CREATE TABLE [dbo].[Category] (
    [CatgId]                 INT          IDENTITY (1, 1) NOT NULL,
    [Code]                   CHAR (3)     NOT NULL,
    [Description]            VARCHAR (25) NOT NULL,
    [Prefix]                 VARCHAR (3)  NULL,
    [Acc]                    NCHAR (12)   NULL,
    [ID]                     CHAR (1)     CONSTRAINT [DF_Category_ID] DEFAULT ('I') NOT NULL,
    [Colour]                 VARCHAR (9)  CONSTRAINT [DF_Category_Colour] DEFAULT ((0)) NULL,
    [Seq]                    INT          NOT NULL,
    [CatType]                CHAR (2)     CONSTRAINT [DF_Category_CatType] DEFAULT ('B') NOT NULL,
    [Active]                 BIT          CONSTRAINT [DF_Category_Active] DEFAULT ((1)) NOT NULL,
    [IsUpload]               BIT          CONSTRAINT [DF_Category_IsUpload_1] DEFAULT ((0)) NOT NULL,
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
    [WebUpload]              BIT          DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED ([CatgId] ASC, [Code] ASC)
);


GO

